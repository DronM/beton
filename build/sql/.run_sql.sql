-- VIEW: shipments_for_veh_owner_list

DROP VIEW shipments_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_veh_owner_list AS
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.destination_id,
		sh.destinations_ref,
		sh.concrete_type_id,
		sh.concrete_types_ref,
		sh.quant,
		sh.vehicle_id,
		sh.vehicles_ref,
		sh.driver_id,
		sh.drivers_ref,
		sh.vehicle_owner_id,
		sh.vehicle_owners_ref,
		sh.cost,
		sh.ship_cost_edit,
		sh.pump_cost_edit,
		sh.demurrage,
		sh.demurrage_cost,
		sh.acc_comment,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		(WITH
		act_price AS (SELECT h.date AS d FROM shipment_for_driver_costs_h h WHERE h.date<=sh.ship_date_time::date ORDER BY h.date DESC LIMIT 1)
		SELECT shdr_cost.price
		FROM shipment_for_driver_costs AS shdr_cost
		WHERE
			shdr_cost.date=(SELECT d FROM act_price)
			AND shdr_cost.distance_to<=dest.distance OR shdr_cost.id=(SELECT t.id FROM shipment_for_driver_costs t WHERE t.date=(SELECT d FROM act_price) ORDER BY t.distance_to LIMIT 1)

		ORDER BY shdr_cost.distance_to DESC
		LIMIT 1
		)*sh.quant AS cost_for_driver
		
	FROM shipments_list sh
	LEFT JOIN destinations AS dest ON dest.id=destination_id
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;
