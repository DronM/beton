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
		mat.ord AS raw_material_ord,
		t.production_site_id,
		production_sites_ref(p_st) AS production_sites_ref
		
	FROM raw_material_map_to_production AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	ORDER BY p_st.name,mat.ord,t.date_time DESC
	;
	
ALTER VIEW raw_material_map_to_production_list OWNER TO ;
