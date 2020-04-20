-- VIEW: material_fact_consumption_corrections_list

--DROP VIEW material_fact_consumption_corrections_list;

CREATE OR REPLACE VIEW material_fact_consumption_corrections_list AS
	SELECT
		t.id,
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.date_time,
		t.date_time_set,
		t.user_id,
		users_ref(u) AS users_ref,
		material_id,
		materials_ref(m) AS materials_ref,
		t.cement_silo_id,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.production_id,
		t.elkon_id,
		t.quant,
		
		t.comment_text
		
	FROM material_fact_consumption_corrections AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.user_id
	LEFT JOIN raw_materials AS m ON m.id=t.material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW material_fact_consumption_corrections_list OWNER TO ;
