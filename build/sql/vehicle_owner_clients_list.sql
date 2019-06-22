-- VIEW: vehicle_owner_clients_list

--DROP VIEW vehicle_owner_clients_list;

CREATE OR REPLACE VIEW vehicle_owner_clients_list AS
	SELECT
		t.vehicle_owner_id,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref
		  
	FROM vehicle_owner_clients t
	LEFT JOIN clients cl ON cl.id=t.client_id
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	;
	
ALTER VIEW vehicle_owner_clients_list OWNER TO ;
