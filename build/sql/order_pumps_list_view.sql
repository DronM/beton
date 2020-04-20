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
		o.user_id,
		o.phone_cel,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		
		--vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		(SELECT
			owners.r->'fields'->'owner'
		FROM
		(
			SELECT jsonb_array_elements(pvh_v.vehicle_owners->'rows') AS r
		) AS owners
		WHERE (owners.r->'fields'->>'dt_from')::timestamp without time zone < o.date_time
		ORDER BY (owners.r->'fields'->>'dt_from')::timestamp without time zone DESC
		LIMIT 1
		) AS pump_vehicle_owners_ref,
		
		pvh.vehicle_id AS pump_vehicle_id,
		
		--pvh_v.vehicle_owner_id AS pump_vehicle_owner_id
		(SELECT
			(owners.r->'fields'->'owner'->'keys'->>'id')::int
		FROM
		(
			SELECT jsonb_array_elements(pvh_v.vehicle_owners->'rows') AS r
		) AS owners
		WHERE (owners.r->'fields'->>'dt_from')::timestamp without time zone < o.date_time
		ORDER BY (owners.r->'fields'->>'dt_from')::timestamp without time zone DESC
		LIMIT 1
		) AS pump_vehicle_owner_id
		
		
	FROM orders o
	LEFT JOIN order_pumps op ON o.id = op.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	--LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			sum(t.quant) AS quant
		FROM shipments t
		GROUP BY t.order_id
	) AS ships ON ships.order_id = o.id
	
	WHERE o.pump_vehicle_id IS NOT NULL
		AND o.unload_type<>'none'
		AND (coalesce(o.quant,0) - coalesce(ships.quant,0)) <> 0
	ORDER BY o.date_time ASC;

ALTER TABLE public.order_pumps_list_view
  OWNER TO beton;

