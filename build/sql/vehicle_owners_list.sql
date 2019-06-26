-- VIEW: vehicle_owners_list

--DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		concrete_costs_for_owner_h_ref(pr_temp) AS concrete_costs_for_owner_h_ref,
		coalesce(vown_cl.client_list,' ') AS client_list,
		concrete_costs_for_owner_h_ref(pr) AS last_concrete_costs_for_owner_h_ref
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN concrete_costs_for_owner_h AS pr_temp ON pr_temp.id=own.concrete_costs_for_owner_h_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id=own.id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO ;
