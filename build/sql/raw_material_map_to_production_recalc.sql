-- Function: raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp with time zone)

-- DROP FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp with time zone);

CREATE OR REPLACE FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp with time zone)
  RETURNS void AS
$$
	UPDATE material_fact_consumptions
	SET raw_material_id=in_material_id
	WHERE raw_material_production_descr = in_production_descr
	AND ( (in_date_time IS NOT NULL AND date_time>=in_date_time) OR in_date_time IS NULL )
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp with time zone) OWNER TO ;

