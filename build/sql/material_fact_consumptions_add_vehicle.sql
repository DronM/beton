--DROP FUNCTION material_fact_consumptions_add_vehicle(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_vehicle(text)
RETURNS int as $$
DECLARE
	v_vehicle_id int;
BEGIN
	v_vehicle_id = NULL;
	SELECT vehicle_id INTO v_vehicle_id FROM vehicle_map_to_production WHERE production_descr = $1;
	IF NOT FOUND THEN
		SELECT id FROM vehicles INTO v_vehicle_id WHERE plate=$1 OR (length($1)=3 AND length(plate)=6 AND '%'||plate||'%' LIKE $1);
		
		INSERT INTO vehicle_map_to_production
		(production_descr,vehicle_id)
		VALUES
		($1,v_vehicle_id)
		;
	END IF;
	
	RETURN v_vehicle_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_vehicle(text) OWNER TO ;
