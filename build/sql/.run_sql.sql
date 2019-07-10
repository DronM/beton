-- VIEW: shipped_vehicles_list

DROP VIEW shipped_vehicles_list;

CREATE OR REPLACE VIEW shipped_vehicles_list AS
	SELECT
		t.id,
		t.ship_date_time,
		--date_trunc('minute', now()-t.ship_date_time) AS elapsed_time,
		destinations_ref(dest) AS destinations_ref,
		drivers_ref(dr) AS drivers_ref,
		vehicles_ref(v) AS vehicles_ref,
		production_sites_ref(ps) AS production_sites_ref
	FROM shipments AS t
	LEFT JOIN orders AS o ON o.id=t.order_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id=t.vehicle_schedule_id
	LEFT JOIN vehicles AS v ON v.id=vsch.vehicle_id
	LEFT JOIN drivers AS dr ON dr.id=vsch.driver_id
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	WHERE t.shipped AND (t.ship_date_time BETWEEN now()-const_show_time_for_shipped_vehicles_val() AND now())
	ORDER BY t.ship_date_time DESC
	;
	
ALTER VIEW shipped_vehicles_list OWNER TO beton;
