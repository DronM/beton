-- VIEW: shipments_for_operator

--DROP VIEW shipments_for_operator;

CREATE OR REPLACE VIEW shipments_for_operator AS
	WITH ships AS (
		SELECT
			sh.id,
			clients_ref(cl) AS clients_ref,
			destinations_ref(dest) AS destinations_ref, 
			concrete_types_ref(ct) AS concrete_types_ref, 
			vehicles_ref(v)::text AS vehicles_ref, 
			drivers_ref(d) AS drivers_ref,
			sh.date_time,
			sh.quant,
			sh.shipped,
			sh.ship_date_time
		FROM shipments AS sh
		LEFT JOIN orders o ON o.id = sh.order_id
		LEFT JOIN clients cl ON cl.id = o.client_id
		LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
		LEFT JOIN drivers d ON d.id = vs.driver_id
		LEFT JOIN vehicles v ON v.id = vs.vehicle_id
		LEFT JOIN destinations dest ON dest.id = o.destination_id
		LEFT JOIN concrete_types ct ON ct.id = o.concrete_type_id
		WHERE sh.shipped = FALSE OR (sh.ship_date_time BETWEEN in_date_time_from AND in_date_time_to)
	)
	--Все неотгруженные
	(SELECT *
	FROM ships
	WHERE shipped = FALSE
	ORDER BY date_time)
	
	UNION ALL
	
	--Все отгруженные за сегодня
	(SELECT *
	FROM shipments
	WHERE shipped = TRUE
	ORDER BY ship_date_time DESC)
		
	;
	
ALTER VIEW shipments_for_operator OWNER TO ;	
