-- VIEW: shipments_for_veh_owner_list

--DROP VIEW shipments_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_veh_owner_list AS
	SELECT
		id,
		ship_date_time,
		destination_id,
		destinations_ref,
		concrete_type_id,
		concrete_types_ref,
		quant,
		vehicle_id,
		vehicles_ref,
		driver_id,
		drivers_ref,
		vehicle_owner_id,
		vehicle_owners_ref,
		cost,
		ship_cost_edit,
		pump_cost_edit,
		demurrage,
		demurrage_cost,
		acc_comment,
		owner_agreed,
		owner_agreed_date_time
		
	FROM shipments_list
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO ;
