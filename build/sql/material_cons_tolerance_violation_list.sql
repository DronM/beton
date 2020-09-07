-- VIEW: material_cons_tolerance_violation_list

--DROP VIEW material_cons_tolerance_violation_list;

-- НЕ ИСПОЛЬЗОВАТЬ!!!!
-- ИСПОЛЬЗОВАТЬ ОДНОИМЕННУЮ ФУНКЦИЮ!!!
CREATE OR REPLACE VIEW material_cons_tolerance_violation_list AS
	SELECT
		get_shift_start(t.date_time::timestamp without time zone) AS date_time
		,t.material_id
		,(t.materials_ref::text)::json AS materials_ref
		,mat.ord AS material_ord
		,round(SUM(t.quant_consuption)::numeric(19,4),4) AS norm_quant
		,SUM(t.material_quant) AS fact_quant
		,(SUM(t.material_quant) - SUM(t.quant_consuption) )::numeric(19,4) AS diff_quant
		,(abs(SUM(t.material_quant) - SUM(t.quant_consuption)) * 100 / SUM(t.material_quant) )::numeric(19,4) AS diff_percent
	FROM production_material_list AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.material_id
	GROUP BY
		get_shift_start(t.date_time::timestamp without time zone)
		,t.material_id
		,t.materials_ref::text
		,mat.ord
	ORDER BY get_shift_start(t.date_time::timestamp without time zone) DESC,mat.ord
	
	;
	
ALTER VIEW material_cons_tolerance_violation_list OWNER TO ;
