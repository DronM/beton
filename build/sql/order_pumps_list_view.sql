-- View: public.order_pumps_list_view

-- DROP VIEW public.order_pumps_list_view;

CREATE OR REPLACE VIEW public.order_pumps_list_view AS 
	SELECT
		order_num(o.*) AS number,
		clients_ref(cl) AS clients_ref,
		o.client_id,
		destinations_ref(d) AS destinations_ref,
		o.destination_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,
		o.unload_type,
		o.comment_text AS comment_text,
		o.descr AS descr,		
		o.date_time,
		o.quant,
		o.id AS order_id,
		op.viewed,
		op.comment,
		users_ref(u) AS users_ref,
		o.user_id
		
	FROM orders o
	LEFT JOIN order_pumps op ON o.id = op.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN users u ON u.id = o.user_id
	WHERE o.pump_vehicle_id IS NOT NULL AND o.unload_type<>'none'
	ORDER BY o.date_time DESC;

ALTER TABLE public.order_pumps_list_view
  OWNER TO beton;

