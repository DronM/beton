-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.concrete_type_id,
		sh.concrete_types_ref,
		sh.quant,
		sh.vehicle_id,
		sh.vehicles_ref,
		sh.driver_id,
		sh.drivers_ref,
		sh.vehicle_owner_id,
		sh.vehicle_owners_ref,
		sh.client_id
		
	FROM shipments_list sh
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO ;
