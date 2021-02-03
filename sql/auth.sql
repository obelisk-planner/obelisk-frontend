-- Mostly copied from the postgREST docs.

CREATE EXTENSION IF NOT EXISTS "pgjwt" CASCADE;

DROP SCHEMA IF EXISTS auth CASCADE;
CREATE SCHEMA auth;

CREATE TABLE IF NOT EXISTS auth.users (
    role NAME NOT NULL,
    password VARCHAR NOT NULL,
    is_editor BOOL NOT NULL
);

CREATE OR REPLACE FUNCTION auth.check_role_exists() RETURNS TRIGGER AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles AS r WHERE r.rolname = new.role) THEN
    RAISE foreign_key_violation USING MESSAGE =
      'unknown database role: ' || new.role;
    RETURN null;
  END IF;
  RETURN new;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS ensure_user_role_exists ON auth.users;
CREATE CONSTRAINT TRIGGER ensure_user_role_exists
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW
  EXECUTE PROCEDURE auth.check_role_exists();

CREATE OR REPLACE FUNCTION auth.user_role(rol VARCHAR, pass VARCHAR) RETURNS NAME AS $$
BEGIN
  RETURN (
  SELECT ROLE FROM auth.users
   WHERE users.role = user_role.rol
     and users.password = crypt(user_role.pass, users.password)
  );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION auth.make_editor(selected_user VARCHAR) RETURNS VOID AS $$
DECLARE
  add_string NAME;
BEGIN
  UPDATE auth.users SET is_editor = TRUE WHERE role = selected_user;
  add_string = 'GRANT editors TO ' || selected_user;
  EXECUTE add_string;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION auth.remove_editor(selected_user VARCHAR) RETURNS VOID AS $$
DECLARE
  add_string NAME;
BEGIN
  UPDATE auth.users SET is_editor = FALSE WHERE role = selected_user;
  add_string = 'REVOKE editors FROM ' || selected_user;
  EXECUTE add_string;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.are_they_editor(selected_user VARCHAR) RETURNS BOOL AS $$
  SELECT is_editor FROM auth.users WHERE role = selected_user AND is_editor = TRUE;
$$ LANGUAGE SQL SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION obelisk.are_they_editor TO users;

CREATE TYPE auth.jwt_token AS (
  token VARCHAR
);