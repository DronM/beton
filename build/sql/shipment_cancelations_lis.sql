-- VIEW: shipment_cancelations_list

--DROP VIEW shipment_cancelations_list;

CREATE OR REPLACE VIEW shipment_cancelations_list AS
	SELECT
		l.id,
		l.date_time,
		l.ship_date_time,
		l.order_id,
		orders_ref(o) AS orders_ref,
		l.vehicle_schedule_id,
		vehicle_schedules_ref(sch,v,dr) AS vehicle_schedules_ref,
		l.comment_text,
		l.user_id,
		users_ref(u) AS users_ref,
		l.quant
		
	FROM shipment_cancelations AS l
	LEFT JOIN users AS u ON u.id=l.user_id
	LEFT JOIN orders AS o ON o.id=l.order_id
	LEFT JOIN vehicle_schedules AS sch ON sch.id=l.vehicle_schedule_id
	LEFT JOIN vehicles AS v ON v.id=sch.vehicle_id
	LEFT JOIN drivers AS dr ON dr.id=sch.driver_id
	;
	
ALTER VIEW shipment_cancelations_list OWNER TO ;
