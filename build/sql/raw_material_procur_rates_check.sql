-- Function: raw_material_procur_rates_check(in_material_id int,in_rate numeric(19,2))

-- DROP FUNCTION raw_material_procur_rates_check(in_material_id int,in_rate numeric(19,2));

CREATE OR REPLACE FUNCTION raw_material_procur_rates_check(in_material_id int,in_rate numeric(19,2))
  RETURNS boolean AS
$BODY$
	SELECT ( sum(coalesce(t.rate,0)) + coalesce(in_rate,0) )<=1 FROM raw_material_procur_rates t WHERE t.material_id=in_material_id ;
	
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION raw_material_procur_rates_check(in_material_id int,in_rate numeric(19,2)) OWNER TO ;
