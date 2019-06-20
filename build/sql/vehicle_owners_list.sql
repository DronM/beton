-- VIEW: vehicle_owners_list

--DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		concrete_costs_for_owner_h_ref(pr) AS concrete_costs_for_owner_h_ref
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=own.concrete_costs_for_owner_h_id
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO ;
