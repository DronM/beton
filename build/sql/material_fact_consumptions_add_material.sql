--DROP FUNCTION material_fact_consumptions_add_material(text,timestamp)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_material(text,timestamp)
RETURNS int as $$
DECLARE
	v_raw_material_id int;
BEGIN
	v_raw_material_id = NULL;
	SELECT raw_material_id INTO v_raw_material_id
	FROM raw_material_map_to_production
	WHERE production_descr = $1 AND date_time<=$2
	ORDER BY date_time DESC
	LIMIT 1;
	
	IF NOT FOUND THEN
		SELECT id FROM raw_materials INTO v_raw_material_id WHERE name=$1;
	
		INSERT INTO raw_material_map_to_production
		(date_time,production_descr,raw_material_id)
		VALUES
		(now(),$1,v_raw_material_id)
		;
	END IF;
	
	RETURN v_raw_material_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_material(text,timestamp) OWNER TO ;
