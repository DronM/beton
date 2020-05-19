-- VIEW: production_vehicle_corrections_list

--DROP VIEW production_vehicle_corrections_list;

CREATE OR REPLACE VIEW production_vehicle_corrections_list AS
	SELECT
		t.production_site_id
		,production_sites_ref(p_st) AS production_sites_ref
		,t.production_id
		,t.vehicle_id
		,vehicles_ref(v) AS vehicles_ref
		,t.user_id
		,users_ref(u) AS users_ref
		,t.date_time
		
	FROM production_vehicle_corrections t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	LEFT JOIN vehicles AS v ON v.id=t.vehicle_id
	LEFT JOIN users AS u ON u.id=t.user_id
	;
	
ALTER VIEW production_vehicle_corrections_list OWNER TO ;
