--DROP FUNCTION material_fact_consumptions_add_concrete_type(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_concrete_type(text)
RETURNS int as $$
DECLARE
	v_concrete_type_id int;
BEGIN
	v_concrete_type_id = NULL;
	SELECT concrete_type_id INTO v_concrete_type_id FROM concrete_type_map_to_production WHERE production_descr = $1;
	IF NOT FOUND THEN
		SELECT id FROM concrete_types INTO v_concrete_type_id WHERE name=$1;
	
		INSERT INTO concrete_type_map_to_production
		(production_descr,concrete_type_id)
		VALUES
		($1,v_concrete_type_id)
		;
	END IF;
	
	RETURN v_concrete_type_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_concrete_type(text) OWNER TO ;
