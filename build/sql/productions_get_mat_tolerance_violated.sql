-- Function: productions_get_mat_tolerance_violated(in_production_site_id int, in_production_id int)

-- DROP FUNCTION productions_get_mat_tolerance_violated(in_production_site_id int, in_production_id int);

CREATE OR REPLACE FUNCTION productions_get_mat_tolerance_violated(in_production_site_id int, in_production_id int)
  RETURNS bool AS
$$
	/*
	SELECT
		bool_or(mat_list.dif_violation)
	FROM production_material_list AS mat_list
	WHERE mat_list.production_site_id = in_production_site_id AND mat_list.production_id = in_production_id			
	*/
	--ссуммирует одинаковые материалы (цемент с разных силосов)
	SELECT
		bool_or(sub.material_tolerance_violated)
	FROM (
	SELECT
		CASE WHEN prod.quant_consuption=0 THEN FALSE
		ELSE
			--abs
			abs(prod.quant_consuption - sum(prod.material_quant) + sum(prod.quant_corrected))*100/prod.quant_consuption>=prod.max_fact_quant_tolerance_percent
		END AS material_tolerance_violated
	FROM production_material_list AS prod
	WHERE prod.production_site_id=in_production_site_id AND prod.production_id=in_production_id
	GROUP BY prod.material_id,prod.quant_consuption,prod.max_fact_quant_tolerance_percent
	) AS sub
	
	;
	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION productions_get_mat_tolerance_violated(in_production_site_id int, in_production_id int) OWNER TO ;
