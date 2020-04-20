-- VIEW: elkon_log_list

--DROP VIEW elkon_log_list;

CREATE OR REPLACE VIEW elkon_log_list AS
	SELECT
		t.*,
		production_sites_ref(p_st) AS production_sites_ref
	FROM elkon_log AS t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW elkon_log_list OWNER TO ;
