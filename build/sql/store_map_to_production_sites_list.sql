-- VIEW: store_map_to_production_sites_list

--DROP VIEW store_map_to_production_sites_list;

CREATE OR REPLACE VIEW store_map_to_production_sites_list AS
	SELECT
		t.id
		,t.store
		,t.production_site_id
		,production_sites_ref(p_st) AS production_sites_ref
		,t.load_capacity
		
	FROM store_map_to_production_sites t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	ORDER BY t.store
	;
	
ALTER VIEW store_map_to_production_sites_list OWNER TO ;
