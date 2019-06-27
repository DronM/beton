-- VIEW: vehicle_owner_concrete_prices_list

--DROP VIEW vehicle_owner_concrete_prices_list;

CREATE OR REPLACE VIEW vehicle_owner_concrete_prices_list AS
	SELECT
		t.vehicle_owner_id,
		t.date,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		concrete_costs_for_owner_h_ref(pr_h) AS concrete_costs_for_owner_h_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref
		
	FROM vehicle_owner_concrete_prices AS t
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h pr_h ON pr_h.id=t.concrete_costs_for_owner_h_id
	LEFT JOIN clients cl ON cl.id=t.client_id
	;
	
ALTER VIEW vehicle_owner_concrete_prices_list OWNER TO beton;
