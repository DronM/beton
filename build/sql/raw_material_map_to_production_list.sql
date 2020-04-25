-- VIEW: raw_material_map_to_production_list

--DROP VIEW raw_material_map_to_production_list;

CREATE OR REPLACE VIEW raw_material_map_to_production_list AS
	SELECT
		t.id,
		t.date_time,
		materials_ref(mat) AS raw_materials_ref,
		t.production_descr,
		t.order_id,
		t.raw_material_id,
		mat.ord AS raw_material_ord
		
	FROM raw_material_map_to_production AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	ORDER BY mat.ord,t.date_time DESC
	;
	
ALTER VIEW raw_material_map_to_production_list OWNER TO ;
