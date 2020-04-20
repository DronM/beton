-- VIEW: cement_silo_balance_resets_list

--DROP VIEW cement_silo_balance_resets_list;

CREATE OR REPLACE VIEW cement_silo_balance_resets_list AS
	SELECT
		t.id
		,t.date_time
		,t.user_id
		,users_ref(u) AS users_ref
		,t.cement_silo_id
		,cement_silos_ref(sil) AS cement_silos_ref
		,t.comment_text
		,ra.quant
		
	FROM cement_silo_balance_resets AS t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN cement_silos sil ON sil.id=t.cement_silo_id
	LEFT JOIN ra_cement AS ra ON ra.doc_id = t.id AND ra.doc_type='cement_silo_balance_reset'::doc_types
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW cement_silo_balance_resets_list OWNER TO ;
