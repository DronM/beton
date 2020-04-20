-- View: public.shipments_pump_list

-- DROP VIEW public.shipments_pump_list;

CREATE OR REPLACE VIEW public.shipments_pump_list AS 
	SELECT
		o.id AS order_id,
		sh_last.id AS last_ship_id,
		order_num(o.*) AS order_number,
		o.date_time,
		o.quant,
		o.concrete_type_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		
		sh_last.acc_comment,
		sh_last.owner_pump_agreed_date_time,
		sh_last.owner_pump_agreed,
		/*
		(CASE
			WHEN coalesce(sh_last.pump_cost_edit,FALSE) THEN sh_last.pump_cost
			--last ship only!!!
			WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = (pump_vehicle_price_on_date(pvh.pump_prices,sh_last.ship_date_time)->'keys'->>'id')::int
					--pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)
		END)::numeric AS pump_cost,
		*/
		shipments_pump_cost(
			(SELECT shipments FROM shipments WHERE shipments.id=sh_last.id),
			o,dest,pvh,
			TRUE
		) AS pump_cost,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh_last.production_site_id
		
		
		
	FROM orders AS o
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN (
		SELECT
			max(sh.ship_date_time) AS ship_date_time,
			sh.order_id,
			sum(sh.quant) AS quant
		FROM shipments AS sh
		GROUP BY sh.order_id
	) AS sh ON sh.order_id = o.id
	LEFT JOIN (
		SELECT
			sh.id,
			sh.ship_date_time,
			sh.order_id,
			sh.acc_comment,
			sh.pump_cost_edit,
			sh.pump_cost,
			sh.owner_pump_agreed,
			sh.owner_pump_agreed_date_time,
			sh.production_site_id
		FROM shipments AS sh
	) AS sh_last ON sh_last.order_id = sh.order_id AND sh_last.ship_date_time = sh.ship_date_time
	LEFT JOIN production_sites ps ON ps.id = sh_last.production_site_id
	
	WHERE
		o.pump_vehicle_id IS NOT NULL
		AND coalesce(o.quant)>0
		AND o.quant=sh.quant
		
	ORDER BY o.date_time DESC
	;
ALTER TABLE public.shipments_pump_list
  OWNER TO ;

