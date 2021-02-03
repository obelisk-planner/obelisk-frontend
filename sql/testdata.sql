CREATE OR REPLACE FUNCTION obelisk.make_test_data () RETURNS VOID AS $$
DECLARE
    token_uuid UUID;
    road_uuid UUID;
    labor_uuid UUID;
    land_uuid UUID;
    flower_uuid UUID;
    transport_uuid UUID;
    growing_uuid UUID;
    consumption_uuid UUID;
    building_uuid UUID;
    fertilizing_uuid UUID;
    farm_land_uuid UUID;
    compost_uuid UUID;
    leisure_uuid UUID;
    greenspace_uuid UUID;
BEGIN

    PERFORM obelisk.create_resource('generic_transport_token',0,'unit',NULL,0,
    VARIADIC ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    token_uuid := id FROM obelisk.resources WHERE resource_name = 'generic_transport_token';

    PERFORM obelisk.create_resource('road',0,'kilometer-week',NULL,0,
    VARIADIC ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    road_uuid := id FROM obelisk.resources WHERE resource_name = 'road';

    PERFORM obelisk.create_resource('generic_labor',1000,'man-week',NULL,0,
    VARIADIC ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    labor_uuid := id FROM obelisk.resources WHERE resource_name = 'generic_labor';

    PERFORM obelisk.create_resource('land',10000,'acre-week',NULL,0,
    VARIADIC ARRAY[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    land_uuid := id FROM obelisk.resources WHERE resource_name = 'land';

    PERFORM obelisk.create_recipe('road_building',0,0,10,0);
    building_uuid := id FROM obelisk.recipes WHERE recipe_name = 'road_building';

    PERFORM obelisk.create_starting_production(building_uuid,land_uuid,-0.5);
    PERFORM obelisk.create_starting_production(building_uuid,labor_uuid,-1);

    PERFORM obelisk.create_production(building_uuid,road_uuid,1);
    PERFORM obelisk.create_production(building_uuid,land_uuid,-1);
    PERFORM obelisk.create_production(building_uuid,labor_uuid,-1);

    PERFORM obelisk.create_recipe('generic_transport',0,0,0,0);
    transport_uuid := id FROM obelisk.recipes WHERE recipe_name = 'generic_transport';

    PERFORM obelisk.create_production(transport_uuid,road_uuid,-0.01);
    PERFORM obelisk.create_production(transport_uuid,labor_uuid,-1);
    PERFORM obelisk.create_production(transport_uuid,token_uuid,10);

    PERFORM obelisk.create_resource('flower',0,'unit',token_uuid,5,
    VARIADIC ARRAY[9.5,0,0,0,0,18.5,3.2,65,0,0,0.2,0.1,0,0,1,0.3,0.2,0,0.4,1.5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    flower_uuid := id FROM obelisk.resources WHERE resource_name = 'flower';

    PERFORM obelisk.create_resource('compost',0,'flower-weight',token_uuid,5,
    VARIADIC ARRAY[9.5,0,0,0,0,18.5,3.2,65,0,0,0.2,0.1,0,0,1,0.3,0.2,0,0.4,1.5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    compost_uuid := id FROM obelisk.resources WHERE resource_name = 'compost';

    PERFORM obelisk.create_resource('farm_land',0,'acre-week',NULL,0,
    VARIADIC ARRAY[9500,0,0,0,0,18500,3200,65000,0,0,200,100,0,0,1000,300,200,0,400,1500,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]);
    farm_land_uuid := id FROM obelisk.resources WHERE resource_name = 'farm_land';

    PERFORM obelisk.create_recipe('fertilizing',0,0,0,0);
    fertilizing_uuid := id FROM obelisk.recipes WHERE recipe_name = 'fertilizing';

    PERFORM obelisk.create_production(fertilizing_uuid,farm_land_uuid,1);
    PERFORM obelisk.create_production(fertilizing_uuid,land_uuid,-1);
    PERFORM obelisk.create_production(fertilizing_uuid,compost_uuid,-1000);
    PERFORM obelisk.create_production(fertilizing_uuid,labor_uuid,-1);

    PERFORM obelisk.create_recipe('flower_growing',0,0,10,0);
    growing_uuid := id FROM obelisk.recipes WHERE recipe_name = 'flower_growing';

    PERFORM obelisk.create_starting_production(growing_uuid,farm_land_uuid,-0.001);
    PERFORM obelisk.create_starting_production(growing_uuid,labor_uuid,-0.1);

    PERFORM obelisk.create_production(growing_uuid,farm_land_uuid,-0.001);
    PERFORM obelisk.create_production(growing_uuid,labor_uuid,-0.1);
    PERFORM obelisk.create_production(growing_uuid,flower_uuid,1);

    PERFORM obelisk.create_recipe('flower_consumption',1,1000,2,1000);
    consumption_uuid := id FROM obelisk.recipes WHERE recipe_name = 'flower_consumption';

    PERFORM obelisk.create_starting_production(consumption_uuid,flower_uuid,-0.5);

    PERFORM obelisk.create_production(consumption_uuid,flower_uuid,-1);
    PERFORM obelisk.create_production(consumption_uuid,compost_uuid,1);

    PERFORM obelisk.create_recipe('leisure',0.1,100,0,10);
    leisure_uuid := id FROM obelisk.recipes WHERE recipe_name = 'leisure';

    PERFORM obelisk.create_production(leisure_uuid,labor_uuid,-1);

    PERFORM obelisk.create_recipe('leaving_greenspace',0.1,1000,0,1000);
    greenspace_uuid := id FROM obelisk.recipes WHERE recipe_name = 'leaving_greenspace';

    PERFORM obelisk.create_production(greenspace_uuid,land_uuid,-1);

END
$$ LANGUAGE plpgsql;

SELECT obelisk.make_test_data();