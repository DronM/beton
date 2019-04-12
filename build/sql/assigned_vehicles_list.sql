-- VIEW: assigned_vehicles_list

--DROP VIEW assigned_vehicles_list;

CREATE OR REPLACE VIEW assigned_vehicles_list AS
	SELECT
		sh.id,
		sh.date_time,
		destinations_ref(dest) AS destinations_ref,
		drivers_ref(dr) AS drivers_ref,
		vehicles_ref(vh) AS vehicles_ref,
		production_sites_ref(ps) AS production_sites_ref,
		sh.quant
	FROM shipments AS sh
	LEFT JOIN orders o ON o.id=sh.order_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_schedules AS vsc ON vsc.id=sh.vehicle_schedule_id
	LEFT JOIN drivers AS dr ON dr.id=vsc.driver_id
	LEFT JOIN vehicles AS vh ON vh.id=vsc.vehicle_id
	LEFT JOIN production_sites AS ps ON ps.id=sh.production_site_id
	WHERE sh.ship_date_time IS NULL
		AND sh.date_time BETWEEN get_shift_start(now()::timestamp) AND get_shift_end(get_shift_start(now()::timestamp))
	ORDER BY ps.name,sh.date_time DESC
	;
	
ALTER VIEW assigned_vehicles_list OWNER TO ;
