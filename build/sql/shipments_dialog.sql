-- View: public.shipments_dialog

-- DROP VIEW public.shipments_dialog;

CREATE OR REPLACE VIEW public.shipments_dialog AS 
	SELECT
		sh.id,
		sh.date_time,
		sh.ship_date_time,
		sh.quant,
		destinations_ref(dest) As destinations_ref,
		clients_ref(cl) As clients_ref,
		vehicle_schedules_ref(vs,v,d) AS vehicle_schedules_ref,
		sh.shipped,
		sh.client_mark,
		sh.demurrage,
		sh.blanks_exist,
		production_sites_ref(ps) AS production_sites_ref,
		sh.acc_comment,
		
		v.vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_from
						ORDER BY pr_vals.quant_from ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		sh.pump_cost_edit,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS ship_cost,
		sh.ship_cost_edit,
		
		sh_last.id AS order_last_shipment,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,FALSE) AS ship_cost_default,
		shipments_pump_cost(sh,o,dest,pvh,FALSE) AS pump_cost_default
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN (
		SELECT
			max(sh.ship_date_time) AS ship_date_time,
			sh.order_id,
			sum(sh.quant) AS quant
		FROM shipments AS sh
		GROUP BY sh.order_id
	) AS sh_t ON sh_t.order_id = sh.order_id
	LEFT JOIN (
		SELECT
			t.id,
			t.order_id,
			t.ship_date_time
		FROM shipments AS t
	) AS sh_last ON sh_last.order_id = sh_t.order_id AND sh_last.ship_date_time = sh_t.ship_date_time
	
	ORDER BY sh.date_time;

ALTER TABLE public.shipments_dialog
  OWNER TO beton;

