-- View: shipment_for_orders_list

-- DROP VIEW shipment_for_orders_list;

CREATE OR REPLACE VIEW shipment_for_orders_list AS 
	SELECT
		sh.id,
		sh.date_time,
		sh.ship_date_time,
		sh.quant,
		vehicle_schedules_ref(vs,v,d) AS vehicle_schedules_ref,
		st.state AS vs_state,
		sh.shipped,
		o.id AS order_id,
		
		production_sites_ref(ps) AS production_sites_ref
		
		/*
		(SELECT t.state
		FROM vehicle_schedule_states t
		WHERE t.schedule_id = vs.id
		ORDER BY t.date_time DESC
		LIMIT 1)
		*/
				
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	
	LEFT JOIN (
		SELECT
			t.schedule_id,
			max(t.date_time) AS date_time
		FROM vehicle_schedule_states t
		GROUP BY t.schedule_id
	) AS s_max ON s_max.schedule_id=sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedule_states st
		ON st.schedule_id=s_max.schedule_id AND st.date_time = s_max.date_time
	
	ORDER BY sh.date_time;

ALTER TABLE shipment_for_orders_list
  OWNER TO beton;

