-- VIEW: raw_material_prices_list

--DROP VIEW raw_material_prices_list;

CREATE OR REPLACE VIEW raw_material_prices_list AS
	SELECT
		t.id 
		,t.date_time
		,t.raw_material_id
		,materials_ref(mat) AS raw_materials_ref
		,t.price
		,t.set_date_time
		,t.user_id
		,users_ref(u) AS users_ref
	FROM raw_material_prices AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN users AS u ON u.id=t.user_id
	;
	
ALTER VIEW raw_material_prices_list OWNER TO ;
