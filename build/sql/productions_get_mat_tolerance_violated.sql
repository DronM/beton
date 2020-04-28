-- Function: productions_get_mat_tolerance_violated(in_production_site_id int, in_production_id int)

-- DROP FUNCTION productions_get_mat_tolerance_violated(in_production_site_id int, in_production_id int);

CREATE OR REPLACE FUNCTION productions_get_mat_tolerance_violated(in_production_site_id int, in_production_id int)
  RETURNS bool AS
$$
	SELECT
		bool_or(mat_list.dif_violation)
	FROM production_material_list AS mat_list
	WHERE mat_list.production_site_id = in_production_site_id AND mat_list.production_id = in_production_id			
	;

$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION productions_get_mat_tolerance_violated(in_production_site_id int, in_production_id int) OWNER TO ;
