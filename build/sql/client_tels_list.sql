-- VIEW: client_tels_list

--DROP VIEW client_tels_list;

CREATE OR REPLACE VIEW client_tels_list AS
	SELECT
		t.*,
		clients_ref(cl) AS clients_ref
		
	FROM client_tels AS t
	LEFT JOIN clients AS cl ON cl.id=t.client_id
	ORDER BY cl.name,t.name
	;
	
ALTER VIEW client_tels_list OWNER TO ;
