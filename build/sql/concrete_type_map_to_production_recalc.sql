-- Function: concrete_type_map_to_production_recalc(in_concrete_type_id int, in_production_descr text)

-- DROP FUNCTION concrete_type_map_to_production_recalc(int in_concrete_type_id int, in_production_descr text);

CREATE OR REPLACE FUNCTION concrete_type_map_to_production_recalc(in_concrete_type_id int, in_production_descr text)
  RETURNS void AS
$$
	UPDATE productions
	SET concrete_type_id=in_concrete_type_id
	WHERE production_concrete_type_descr=in_production_descr;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION concrete_type_map_to_production_recalc(in_material_id int, in_production_descr text) OWNER TO ;
