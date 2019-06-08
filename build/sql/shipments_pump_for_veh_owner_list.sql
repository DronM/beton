-- VIEW: shipments_pump_for_veh_owner_list

--DROP VIEW shipments_pump_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_pump_for_veh_owner_list AS
	SELECT
		last_ship_id,
		date_time,
		destinations_ref,
		destination_id,
		concrete_type_id,
		concrete_types_ref,
		quant,
		pump_cost,
		pump_vehicle_id,
		pump_vehicles_ref,
		pump_vehicle_owner_id,
		pump_vehicle_owners_ref,
		owner_pump_agreed,
		owner_pump_agreed_date_time,
		acc_comment
		
		
	FROM shipments_pump_list
	;
	
ALTER VIEW shipments_pump_for_veh_owner_list OWNER TO ;
