-- Function: vehicle_map_to_production_recalc(in_vehicle_id int, in_production_descr text)

-- DROP FUNCTION vehicle_map_to_production_recalc(int in_vehicle_id int, in_production_descr text);

CREATE OR REPLACE FUNCTION vehicle_map_to_production_recalc(in_vehicle_id int, in_production_descr text)
  RETURNS void AS
$$
	UPDATE material_fact_consumptions
	SET vehicle_id=in_vehicle_id
	WHERE vehicle_production_descr=in_production_descr;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION vehicle_map_to_production_recalc(in_material_id int, in_production_descr text) OWNER TO ;
