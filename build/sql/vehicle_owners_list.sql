-- VIEW: vehicle_owners_list

--DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		coalesce(vown_cl.client_list,' ') AS client_list
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO ;
