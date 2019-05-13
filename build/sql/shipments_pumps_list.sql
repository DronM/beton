-- View: shipment_pumps_list

-- DROP VIEW shipment_pumps_list;

CREATE OR REPLACE VIEW shipment_pumps_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		o.client_id,
		cl.name AS client_descr,
		o.destination_id,
		d.name AS destination_descr,
		sh.quant,
		o.unload_price,
		o.pump_vehicle_id,
		vh.owner,
		vh.plate,
		vh.driver_id,
		dr.name AS driver_descr,
		sh.blanks_exist,
		sh.demurrage,
		vehicle_owners_ref(v_own) AS vehicle_owners_ref
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN vehicles vh ON vh.id = o.pump_vehicle_id
	LEFT JOIN drivers dr ON dr.id = vh.driver_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = vh. vehicle_owner_id
	WHERE o.unload_type = 'pump'::unload_types OR o.unload_type = 'band'::unload_types
	ORDER BY sh.ship_date_time DESC;

ALTER TABLE shipment_pumps_list OWNER TO beton;

