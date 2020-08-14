-- Function: material_cons_tolerance_violation_list(in_date_time_from timestamp,in_date_time_to timestamp)

-- DROP FUNCTION material_cons_tolerance_violation_list(in_date_time_from timestamp,in_date_time_to timestamp);

CREATE OR REPLACE FUNCTION material_cons_tolerance_violation_list(in_date_time_from timestamp,in_date_time_to timestamp)
  RETURNS TABLE(
  	date_time timestamp,
  	material_id int,
  	materials_ref json,
  	material_ord int,
  	norm_quant numeric(19,4),
  	fact_quant numeric(19,4),
  	diff_quant numeric(19,4),
  	diff_percent numeric(19,4)
  ) AS
$$
	SELECT
		sub.date_time
		,sub.material_id
		,(sub.materials_ref::text)::json AS materials_ref
		,mat.ord AS material_ord
		,round(SUM(sub.quant_consuption)::numeric(19,4),4) AS norm_quant
		,SUM(sub.material_quant) AS fact_quant
		,(SUM(sub.material_quant) - SUM(sub.quant_consuption) )::numeric(19,4) AS diff_quant
		,(abs(SUM(sub.material_quant) - SUM(sub.quant_consuption)) * 100 / SUM(sub.material_quant) )::numeric(19,4) AS diff_percent
	FROM (
		SELECT
			get_shift_start(t.date_time::timestamp without time zone) AS date_time
			,t.material_id
			,t.materials_ref::text AS materials_ref
			,t.quant_consuption
			,SUM(t.material_quant) AS material_quant
		FROM production_material_list AS t
		LEFT JOIN raw_materials AS mat ON mat.id=t.material_id
		WHERE
			t.date_time BETWEEN in_date_time_from AND in_date_time_to
			--t.production_id=96371
		GROUP BY
			get_shift_start(t.date_time::timestamp without time zone)
			,t.material_id
			,t.materials_ref::text
			,t.quant_consuption
			,t.production_id
	) AS sub
	LEFT JOIN raw_materials AS mat ON mat.id=sub.material_id
	GROUP BY
		sub.date_time
		,sub.material_id
		,sub.materials_ref::text
		,mat.ord
	ORDER BY sub.date_time DESC,mat.ord
	;

$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_cons_tolerance_violation_list(in_date_time_from timestamp,in_date_time_to timestamp) OWNER TO ;

