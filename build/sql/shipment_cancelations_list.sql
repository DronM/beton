-- VIEW: shipment_cancelations_list

--DROP VIEW shipment_cancelations_list;

CREATE OR REPLACE VIEW shipment_cancelations_list AS
	SELECT
		sh.id,
		sh.date_time,
		sh.order_id,
		orders_ref(o) AS orders_ref,
		sh.vehicle_schedule_id,
		vehicle_schedules_ref(vsch,vh,dr) AS vehicle_schedules_ref,
		sh.comment_text,
		sh.user_id,
		users_ref(u) AS users_ref
	FROM shipment_cancelations AS sh
	LEFT JOIN orders o ON o.id=sh.order_id
	LEFT JOIN vehicle_schedules vsch ON vsch.id=sh.vehicle_schedule_id
	LEFT JOIN users u ON u.id=sh.user_id
	LEFT JOIN vehicles vh ON vh.id=vsch.vehicle_id
	LEFT JOIN drivers dr ON dr.id=vsch.driver_id
	;
	
ALTER VIEW shipment_cancelations_list OWNER TO ;
