read -p "Database to use:" dbname

psql -f sql/obelisk.sql $dbname

read -p "URL to access your API (pick localhost:3000 if unsure):" apiurl

echo "VUE_APP_API_URL=$apiurl" > obelisk-app/.env

read -p "Insert example data? y to do so:" dotestdata

if [ "$dotestdata" == "y" ]
then
psql -f sql/testdata.sql $dbname
else
echo "Skipping."
fi

psql -f sql/auth.sql $dbname

randompass=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32)

echo "
db-uri = \"postgres://authenticator:$randompass@localhost:5432/$dbname\"
db-schema = \"obelisk\"
db-anon-role = \"anon\"
max-rows=1000
jwt-secret=\"@obelisk-jwt\"
" > obelisk.conf

echo "
DROP ROLE IF EXISTS authenticator;
DROP ROLE IF EXISTS anon;

CREATE ROLE authenticator WITH PASSWORD '$randompass' NOINHERIT LOGIN;
CREATE ROLE anon;

GRANT anon TO authenticator;
" | psql $dbname

echo $random

read -s -p "Password for newuser (no special characters):" pswd
echo
read -s -p "Re-enter password:" repswd
echo

while [ $pswd != $repswd ]
do
    echo "Passwords do not match."
    echo
    read -s -p "Password for newuser:" pswd
    echo
    read -s -p "Re-enter password:" repswd
done

echo "
DROP ROLE IF EXISTS newuser;
CREATE ROLE newuser;
GRANT newuser TO authenticator;

INSERT INTO auth.users VALUES ('newuser',crypt('$pswd', gen_salt('bf')), FALSE);

CREATE OR REPLACE FUNCTION obelisk.add_user(new_user NAME, new_password VARCHAR) RETURNS VOID AS \$\$
DECLARE                                                                                
    add_string NAME;                                                                   
BEGIN                                                                                  
    -- It was taking new_user literally, so here's a work-around using EXECUTE.        
    add_string =                                                                       
      'CREATE USER ' || new_user || ' IN ROLE users;' ||                               
      'GRANT ' || new_user || ' TO authenticator;'                                     
    ;                                                                                  
    EXECUTE add_string;                                                                
    INSERT INTO auth.users VALUES (new_user,crypt(new_password, gen_salt('bf')),FALSE);
END;
\$\$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION obelisk.add_user TO newuser;
" | psql $dbname

new_secret=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c32)
echo $new_secret > obelisk-jwt

echo "

CREATE OR REPLACE FUNCTION obelisk.login(rol VARCHAR, pass VARCHAR) RETURNS auth.jwt_token AS \$\$
DECLARE                                                               
  _role NAME;                                                         
  result auth.jwt_token;                                              
BEGIN                                                                 
  SELECT auth.user_role(login.rol, login.pass) INTO _role;            
  IF _role IS NULL THEN                                               
    RAISE invalid_password USING MESSAGE = 'invalid user or password';
  END IF;                                                             
                                                                      
  SELECT sign(                                                        
      row_to_json(r), '$new_secret'              
    ) AS token                                                        
    FROM (                                                            
      SELECT _role AS role, login.rol AS rol,                         
         EXTRACT(epoch from now())::integer + 60*60*24 AS exp         
    ) r                                                              
    INTO result;                                                      
  RETURN result;                                                      
END;                                                                  
\$\$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION obelisk.login TO anon;
" | psql $dbname