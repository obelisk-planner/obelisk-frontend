CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP SCHEMA IF EXISTS obelisk CASCADE;
DROP ROLE IF EXISTS users;
DROP ROLE IF EXISTS editors;
CREATE ROLE users NOLOGIN;
CREATE ROLE editors NOLOGIN;
GRANT users TO editors;
CREATE SCHEMA obelisk;
GRANT usage ON SCHEMA obelisk TO PUBLIC;

CREATE TABLE IF NOT EXISTS obelisk.resources (
    id UUID NOT NULL,
    resource_name VARCHAR(256) NOT NULL,
    natural_production DOUBLE PRECISION NOT NULL,
    measurement_unit VARCHAR(256) NOT NULL,
    transport_token_id UUID,
    tokens_required DOUBLE PRECISION NOT NULL,
    element_content DOUBLE PRECISION[82] NOT NULL,
    CONSTRAINT fk__transport_token_id
        FOREIGN KEY (transport_token_id) REFERENCES obelisk.resources(id) ON DELETE CASCADE,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS obelisk.recipes (
    id UUID NOT NULL,
    recipe_name VARCHAR(256) NOT NULL,
    consumer_price DOUBLE PRECISION NOT NULL,
    current_activity DOUBLE PRECISION NOT NULL,
    delay DOUBLE PRECISION NOT NULL,
    max_price DOUBLE PRECISION NOT NULL,
    final_activity DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS obelisk.production (
    id UUID NOT NULL,
    recipe_id UUID NOT NULL,
    resource_id UUID NOT NULL,
    production DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk__recipe_id
        FOREIGN KEY (recipe_id) REFERENCES obelisk.recipes(id) ON DELETE CASCADE,
    CONSTRAINT fk__resource_id
        FOREIGN KEY (resource_id) REFERENCES obelisk.resources(id) ON DELETE CASCADE,
    UNIQUE (recipe_id, resource_id)
);

CREATE TABLE IF NOT EXISTS obelisk.starting_production (
    id UUID NOT NULL,
    recipe_id UUID NOT NULL,
    resource_id UUID NOT NULL,
    production DOUBLE PRECISION NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk__recipe_id
        FOREIGN KEY (recipe_id) REFERENCES obelisk.recipes(id) ON DELETE CASCADE,
    CONSTRAINT fk__resource_id
        FOREIGN KEY (resource_id) REFERENCES obelisk.resources(id) ON DELETE CASCADE,
    UNIQUE (recipe_id, resource_id)
);

CREATE TABLE IF NOT EXISTS obelisk.resources_history (
    change_id UUID NOT NULL DEFAULT uuid_generate_v1mc(),
    id UUID NOT NULL,
    resource_name VARCHAR(256) NOT NULL,
    natural_production DOUBLE PRECISION NOT NULL,
    measurement_unit VARCHAR(256) NOT NULL,
    transport_token_id UUID,
    tokens_required DOUBLE PRECISION NOT NULL,
    element_content DOUBLE PRECISION[82] NOT NULL,
    CONSTRAINT fk__transport_token_id
        FOREIGN KEY (transport_token_id) REFERENCES obelisk.resources(id),
    changed_user NAME,
    deleted BOOLEAN,
    changed_time TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (change_id)
);

CREATE TABLE IF NOT EXISTS obelisk.recipes_history (
    change_id UUID NOT NULL DEFAULT uuid_generate_v1mc(),
    id UUID NOT NULL,
    recipe_name VARCHAR(256) NOT NULL,
    consumer_price DOUBLE PRECISION NOT NULL,
    current_activity DOUBLE PRECISION NOT NULL,
    delay DOUBLE PRECISION NOT NULL,
    max_price DOUBLE PRECISION NOT NULL,
    final_activity DOUBLE PRECISION NOT NULL,
    changed_user NAME,
    deleted BOOLEAN,
    changed_time TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (change_id)
);

CREATE TABLE IF NOT EXISTS obelisk.production_history (
    change_id UUID NOT NULL DEFAULT uuid_generate_v1mc(),
    id UUID NOT NULL,
    recipe_id UUID NOT NULL,
    resource_id UUID NOT NULL,
    production DOUBLE PRECISION NOT NULL,
    changed_user NAME,
    deleted BOOLEAN,
    changed_time TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (change_id),
    CONSTRAINT fk__recipe_id
        FOREIGN KEY (recipe_id) REFERENCES obelisk.recipes(id),
    CONSTRAINT fk__resource_id
        FOREIGN KEY (resource_id) REFERENCES obelisk.resources(id)
);

CREATE TABLE IF NOT EXISTS obelisk.starting_production_history (
    change_id UUID NOT NULL DEFAULT uuid_generate_v1mc(),
    id UUID NOT NULL,
    recipe_id UUID NOT NULL,
    resource_id UUID NOT NULL,
    production DOUBLE PRECISION NOT NULL,
    changed_user NAME,
    deleted BOOLEAN,
    changed_time TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (change_id),
    CONSTRAINT fk__recipe_id
        FOREIGN KEY (recipe_id) REFERENCES obelisk.recipes(id),
    CONSTRAINT fk__resource_id
        FOREIGN KEY (resource_id) REFERENCES obelisk.resources(id)
);

GRANT SELECT ON obelisk.resources, obelisk.recipes,
obelisk.production, obelisk.starting_production, obelisk.resources_history,
obelisk.recipes_history, obelisk.production_history, obelisk.starting_production_history TO PUBLIC;

CREATE OR REPLACE FUNCTION obelisk.random_resource () RETURNS UUID AS $$
    SELECT id FROM obelisk.resources ORDER BY RANDOM() LIMIT 1;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION obelisk.random_recipe () RETURNS UUID AS $$
    SELECT id FROM obelisk.recipes ORDER BY RANDOM() LIMIT 1;
$$ LANGUAGE SQL;

-- Using a seperate SELECT for each column here to work around a bug where UUIDs are incorrectly identified as VARCHARs.

CREATE OR REPLACE FUNCTION obelisk.raw_remove_resource (selected_id UUID, 
new_change_id UUID, signed_in_user NAME) RETURNS VOID AS $$
    INSERT INTO obelisk.resources_history (change_id, id, resource_name, natural_production, measurement_unit,
    transport_token_id, tokens_required, element_content, changed_user, deleted, changed_time) VALUES (
        new_change_id,selected_id,(SELECT resource_name FROM obelisk.resources WHERE id = selected_id),
        (SELECT natural_production FROM obelisk.resources WHERE id = selected_id),
        (SELECT measurement_unit FROM obelisk.resources WHERE id = selected_id),
        (SELECT transport_token_id FROM obelisk.resources WHERE id = selected_id),
        (SELECT tokens_required FROM obelisk.resources WHERE id = selected_id),
        (SELECT element_content FROM obelisk.resources WHERE id = selected_id),  signed_in_user, TRUE, now());
    DELETE FROM obelisk.resources WHERE id = selected_id;
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.remove_resource (selected_id UUID) RETURNS VOID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
    cascade_prod UUID;
BEGIN
    FOR cascade_prod IN (SELECT id FROM obelisk.production WHERE resource_id = selected_id) LOOP
        PERFORM obelisk.remove_production (cascade_prod);
    END LOOP;
    FOR cascade_prod IN (SELECT id FROM obelisk.starting_production WHERE resource_id = selected_id) LOOP
        PERFORM obelisk.remove_starting_production (cascade_prod);
    END LOOP;
    PERFORM obelisk.raw_remove_resource (selected_id, new_uuid, user);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.raw_remove_recipe (selected_id UUID, new_change_id UUID,
  signed_in_user NAME) RETURNS VOID AS $$
    INSERT INTO obelisk.recipes_history (change_id,id,recipe_name,consumer_price,
        current_activity,delay,max_price,final_activity,changed_user,deleted,changed_time) VALUES (new_change_id, selected_id,
        (SELECT recipe_name FROM obelisk.recipes WHERE id = selected_id),
        (SELECT consumer_price FROM obelisk.recipes WHERE id = selected_id),
        (SELECT current_activity FROM obelisk.recipes WHERE id = selected_id),
        (SELECT delay FROM obelisk.recipes WHERE id = selected_id),
        (SELECT max_price FROM obelisk.recipes WHERE id = selected_id),
        (SELECT final_activity FROM obelisk.recipes WHERE id = selected_id),
         signed_in_user,TRUE,now());
    DELETE FROM obelisk.recipes WHERE id = selected_id;
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.remove_recipe (selected_id UUID) RETURNS VOID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
    cascade_prod UUID;
BEGIN
    FOR cascade_prod IN (SELECT id FROM obelisk.production WHERE recipe_id = selected_id) LOOP
        PERFORM obelisk.remove_production (cascade_prod);
    END LOOP;
    FOR cascade_prod IN (SELECT id FROM obelisk.starting_production WHERE recipe_id = selected_id) LOOP
        PERFORM obelisk.remove_starting_production (cascade_prod);
    END LOOP;
    PERFORM obelisk.raw_remove_recipe (selected_id, new_uuid, user);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.raw_create_recipe (new_change_id UUID, new_uuid UUID, new_name VARCHAR(256), 
new_consumer_price DOUBLE PRECISION, new_current_activity DOUBLE PRECISION, new_delay DOUBLE PRECISION, new_max_price DOUBLE PRECISION,
signed_in_user NAME) RETURNS VOID AS $$
    INSERT INTO obelisk.recipes (id,recipe_name,consumer_price,current_activity,delay,max_price,final_activity) 
        VALUES (new_uuid, new_name, new_consumer_price, new_current_activity, new_delay, new_max_price, 0);
    INSERT INTO obelisk.recipes_history (change_id,id,recipe_name,consumer_price, current_activity,delay,max_price,final_activity,changed_user,deleted,changed_time) 
        VALUES (new_change_id, new_uuid, new_name, new_consumer_price, new_current_activity, new_delay, new_max_price, 0,  signed_in_user, FALSE, now());
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.undelete_recipe (new_uuid UUID, new_name VARCHAR(256), new_consumer_price DOUBLE PRECISION,
new_current_activity DOUBLE PRECISION, new_delay DOUBLE PRECISION, new_max_price DOUBLE PRECISION) RETURNS VOID AS $$
DECLARE
    new_change_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_create_recipe(new_change_uuid, new_uuid, new_name, new_consumer_price, new_current_activity, new_delay,
      new_max_price, user);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.create_recipe (new_name VARCHAR(256), new_consumer_price DOUBLE PRECISION,
new_current_activity DOUBLE PRECISION, new_delay DOUBLE PRECISION, new_max_price DOUBLE PRECISION) RETURNS UUID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
    new_change_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_create_recipe(new_change_uuid, new_uuid, new_name, new_consumer_price, new_current_activity, new_delay,
    new_max_price, user);
    RETURN new_uuid;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.raw_create_resource (new_change_id UUID, new_uuid UUID, new_name VARCHAR(256),
  new_natural DOUBLE PRECISION, new_unit VARCHAR(256), new_transport_token_id UUID, 
  new_tokens_required DOUBLE PRECISION, new_element_content DOUBLE PRECISION[100],
  signed_in_user NAME) RETURNS VOID AS $$
    INSERT INTO obelisk.resources (id, resource_name, natural_production, measurement_unit,
    transport_token_id, tokens_required, element_content) VALUES (new_uuid, new_name, 
    new_natural, new_unit, new_transport_token_id, new_tokens_required, new_element_content);
    INSERT INTO obelisk.resources_history (change_id, id, resource_name, natural_production, measurement_unit,
    transport_token_id, tokens_required, element_content, changed_user, deleted, changed_time) VALUES (new_change_id, new_uuid, new_name, new_natural, new_unit, 
    new_transport_token_id, new_tokens_required, new_element_content,  signed_in_user, FALSE, now());
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.undelete_resource (new_uuid UUID, new_name VARCHAR(256), new_natural DOUBLE PRECISION, new_unit VARCHAR(256), 
new_transport_token UUID, new_tokens_required DOUBLE PRECISION, new_element_content DOUBLE PRECISION[82]) RETURNS VOID AS $$
DECLARE
    new_change_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_create_resource (new_change_uuid, new_uuid, new_name, new_natural, new_unit, new_transport_token, 
    new_tokens_required, new_element_content, user);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.create_resource (new_name VARCHAR(256), new_natural DOUBLE PRECISION, new_unit VARCHAR(256), 
new_transport_token UUID, new_tokens_required DOUBLE PRECISION, new_element_content DOUBLE PRECISION[82]) RETURNS UUID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
    new_change_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_create_resource (new_change_uuid, new_uuid, new_name, new_natural, new_unit, new_transport_token, 
    new_tokens_required, new_element_content, user);
    RETURN new_uuid;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.raw_create_production (new_change_uuid UUID, new_uuid UUID, new_recipe_id UUID,
  new_resource_id UUID, new_production DOUBLE PRECISION, signed_in_user NAME) RETURNS VOID AS $$
    INSERT INTO obelisk.production (id, recipe_id, resource_id, production) VALUES (new_uuid, new_recipe_id, new_resource_id, new_production);
    INSERT INTO obelisk.production_history (change_id, id, recipe_id, resource_id, production, changed_user, deleted, changed_time) VALUES 
        (new_change_uuid, new_uuid, new_recipe_id, new_resource_id, new_production,  signed_in_user, FALSE, now());
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.create_production (new_recipe_id UUID, new_resource_id UUID, new_production DOUBLE PRECISION) RETURNS VOID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
    new_change_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_create_production (new_change_uuid, new_uuid, new_recipe_id, new_resource_id,
      new_production, user);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.raw_remove_production (new_change_id UUID, selected_id UUID, signed_in_user NAME) RETURNS VOID AS $$
    INSERT INTO obelisk.production_history (change_id,id,recipe_id,
    resource_id,production,changed_user,deleted,changed_time) VALUES (new_change_id, selected_id,
        (SELECT recipe_id FROM obelisk.production WHERE id = selected_id),
        (SELECT resource_id FROM obelisk.production WHERE id = selected_id),
        (SELECT production FROM obelisk.production WHERE id = selected_id),
         signed_in_user,TRUE,now());
    DELETE FROM obelisk.production WHERE id = selected_id;
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.remove_production (selected_id UUID) RETURNS VOID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_remove_production (new_uuid, selected_id, user);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.raw_create_starting_production (new_change_uuid UUID, new_uuid UUID, 
  new_recipe_id UUID, new_resource_id UUID, new_production DOUBLE PRECISION,
  signed_in_user NAME) RETURNS VOID AS $$
    INSERT INTO obelisk.starting_production (id, recipe_id, resource_id, production) VALUES (new_uuid, new_recipe_id, new_resource_id, new_production);
    INSERT INTO obelisk.starting_production_history (change_id, id, recipe_id, resource_id, production, changed_user, deleted, changed_time) VALUES 
        (new_change_uuid, new_uuid, new_recipe_id, new_resource_id, new_production,  signed_in_user, FALSE, now());
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.create_starting_production (new_recipe_id UUID, new_resource_id UUID, new_production DOUBLE PRECISION) RETURNS VOID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
    new_change_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_create_starting_production (new_change_uuid,new_uuid, new_recipe_id, 
      new_resource_id, new_production, user);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.raw_remove_starting_production (new_change_id UUID, selected_id UUID,
  signed_in_user NAME) RETURNS VOID AS $$
    INSERT INTO obelisk.starting_production_history (change_id,id,recipe_id,
    resource_id,production,changed_user,deleted,changed_time) VALUES (new_change_id, selected_id,
        (SELECT recipe_id FROM obelisk.starting_production WHERE id = selected_id),
        (SELECT resource_id FROM obelisk.starting_production WHERE id = selected_id),
        (SELECT production FROM obelisk.starting_production WHERE id = selected_id),
         signed_in_user,TRUE,now());
    DELETE FROM obelisk.starting_production WHERE id = selected_id;
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.remove_starting_production (selected_id UUID) RETURNS VOID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_remove_starting_production (new_uuid, selected_id, user);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.raw_update_recipe (new_change_id UUID, selected_id UUID, new_name VARCHAR(256), 
  new_consumer_price DOUBLE PRECISION, new_current_activity DOUBLE PRECISION,
  new_delay DOUBLE PRECISION, new_max_price DOUBLE PRECISION, signed_in_user NAME) RETURNS VOID AS $$
    UPDATE obelisk.recipes SET
        recipe_name = new_name,
        consumer_price = new_consumer_price,
        current_activity = new_current_activity,
        delay = new_delay,
        max_price = new_max_price
        WHERE id = selected_id;
    INSERT INTO obelisk.recipes_history (change_id,id,recipe_name,consumer_price,
        current_activity,delay,max_price,final_activity,changed_user,deleted,changed_time) VALUES (new_change_id, selected_id,
        (SELECT recipe_name FROM obelisk.recipes WHERE id = selected_id),
        (SELECT consumer_price FROM obelisk.recipes WHERE id = selected_id),
        (SELECT current_activity FROM obelisk.recipes WHERE id = selected_id),
        (SELECT delay FROM obelisk.recipes WHERE id = selected_id),
        (SELECT max_price FROM obelisk.recipes WHERE id = selected_id),
        (SELECT final_activity FROM obelisk.recipes WHERE id = selected_id),
        signed_in_user,TRUE,now());
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.update_recipe (selected_id UUID, new_name VARCHAR(256), new_consumer_price DOUBLE PRECISION,
new_current_activity DOUBLE PRECISION, new_delay DOUBLE PRECISION, new_max_price DOUBLE PRECISION) RETURNS VOID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_update_recipe(new_uuid, selected_id, new_name, new_consumer_price,
      new_current_activity, new_delay, new_max_price, user);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION obelisk.raw_update_resource (new_change_id UUID, selected_id UUID, new_name VARCHAR(256), new_natural DOUBLE PRECISION, 
new_unit VARCHAR(256), new_transport_token_id UUID, new_tokens_required DOUBLE PRECISION, 
new_element_content DOUBLE PRECISION[82], signed_in_user NAME) RETURNS VOID AS $$
    UPDATE obelisk.resources SET
        resource_name = new_name,
        natural_production = new_natural,
        measurement_unit = new_unit,
        transport_token_id = new_transport_token_id,
        tokens_required = new_tokens_required,
        element_content = new_element_content
        WHERE id = selected_id;
    INSERT INTO obelisk.resources_history (change_id, id, resource_name, natural_production, measurement_unit,
    transport_token_id, tokens_required, element_content, changed_user, deleted, changed_time) VALUES (
        new_change_id,selected_id,(SELECT resource_name FROM obelisk.resources WHERE id = selected_id),
        (SELECT natural_production FROM obelisk.resources WHERE id = selected_id),
        (SELECT measurement_unit FROM obelisk.resources WHERE id = selected_id),
        (SELECT transport_token_id FROM obelisk.resources WHERE id = selected_id),
        (SELECT tokens_required FROM obelisk.resources WHERE id = selected_id),
        (SELECT element_content FROM obelisk.resources WHERE id = selected_id),  signed_in_user, TRUE, now());
$$ LANGUAGE SQL SECURITY DEFINER;

CREATE OR REPLACE FUNCTION obelisk.update_resource (selected_id UUID, new_name VARCHAR(256), new_natural DOUBLE PRECISION, new_unit VARCHAR(256), 
new_transport_token UUID, new_tokens_required DOUBLE PRECISION, new_element_content DOUBLE PRECISION[82]) RETURNS VOID AS $$
DECLARE
    new_uuid CONSTANT UUID := uuid_generate_v1mc();
BEGIN
    PERFORM obelisk.raw_update_resource (new_uuid, selected_id, new_name, new_natural, new_unit, new_transport_token, 
    new_tokens_required, new_element_content, user);
END
$$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION obelisk.random_resource,obelisk.random_recipe,
obelisk.remove_resource, obelisk.remove_recipe, obelisk.create_resource,
obelisk.create_recipe, obelisk.create_production, obelisk.remove_production, 
obelisk.create_starting_production, obelisk.remove_starting_production, 
obelisk.update_recipe, obelisk.update_resource TO users;

GRANT EXECUTE ON FUNCTION obelisk.undelete_recipe, obelisk.undelete_resource TO editors;
