-- VIEW: vehicle_owner_clients_list

--DROP VIEW vehicle_owner_clients_list;

CREATE OR REPLACE VIEW vehicle_owner_clients_list AS
	SELECT
		t.vehicle_owner_id,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref,
		concrete_costs_for_owner_h_ref(pr) AS last_concrete_costs_for_owner_h_ref
		  
	FROM vehicle_owner_clients t
	LEFT JOIN clients cl ON cl.id=t.client_id
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id=vown.id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	;
	
ALTER VIEW vehicle_owner_clients_list OWNER TO ;
