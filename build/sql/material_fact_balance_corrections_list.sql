-- VIEW: material_fact_balance_corrections_list

--DROP VIEW material_fact_balance_corrections_list;

CREATE OR REPLACE VIEW material_fact_balance_corrections_list AS
	SELECT
		t.id,
		t.date_time,
		t.balance_date_time,
		t.user_id,
		users_ref(u) AS users_ref,
		t.material_id,
		materials_ref(mat) AS materials_ref,
		t.required_balance_quant,
		t.comment_text,
		t.production_site_id,
		production_sites_ref(pr_st) AS production_sites_ref
		
	FROM material_fact_balance_corrections t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN raw_materials mat ON mat.id=t.material_id
	LEFT JOIN production_sites AS pr_st ON pr_st.id=t.production_site_id		
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW material_fact_balance_corrections_list OWNER TO ;
