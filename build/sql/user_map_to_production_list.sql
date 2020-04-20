-- VIEW: user_map_to_production_list

DROP VIEW user_map_to_production_list;

CREATE OR REPLACE VIEW user_map_to_production_list AS
	SELECT
		t.*,
		production_sites_ref(p_st) AS production_sites_ref,
		users_ref(u) AS users_ref
	FROM user_map_to_production AS t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.user_id
	;
	
ALTER VIEW user_map_to_production_list OWNER TO ;
