-- View: public.orders_dialog

-- DROP VIEW public.orders_dialog;

CREATE OR REPLACE VIEW public.orders_dialog AS 
	SELECT
		o.id,
		order_num(o.*) AS number,		
		clients_ref(cl) AS clients_ref,		
		
		destinations_ref(d) AS destinations_ref,
		o.destination_price AS destination_cost,		
		--d.price AS destination_price,		
		CASE
			WHEN coalesce(d.special_price,FALSE) THEN coalesce(d.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=d.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(d.price,0))			
		END  AS destination_price,
		
		d.time_route,
		d.distance,
		
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_price AS concrete_cost,		
		--concr.price AS concrete_price,
		coalesce(
			(SELECT ct_p.price
			FROM concrete_costs ct_p
			WHERE ct_p.date<=o.date_time::date AND ct_p.concrete_type_id=o.concrete_type_id
			ORDER BY ct_p.date DESC
			LIMIT 1
			),
		coalesce(concr.price,0)) AS concrete_price,
		
		o.unload_type,
		o.comment_text,
		o.descr,
		o.phone_cel,
		o.unload_speed,
		o.date_time,
		o.time_to,		
		o.quant,
		langs_ref(l) AS langs_ref,
		o.total,
		o.total_edit,
		o.pay_cash,
		o.unload_price AS unload_cost,
		o.payed,
		o.under_control,
		
		pv.phone_cel AS pump_vehicle_phone_cel,
		pump_vehicles_ref(pv,v) AS pump_vehicles_ref,
		pump_prices_ref(ppr) AS pump_prices_ref,
		
		users_ref(u) AS users_ref,
		
		d.distance AS destination_distance,
		
		users_ref(lm_u) AS last_modif_users_ref,
		o.last_modif_date_time
		
	FROM orders o
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN langs l ON l.id = o.lang_id
	LEFT JOIN pump_vehicles pv ON pv.id = o.pump_vehicle_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN users lm_u ON lm_u.id = o.last_modif_user_id
	ORDER BY o.date_time;

ALTER TABLE public.orders_dialog OWNER TO beton;

