-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(pr.price,0)*o.quant::numeric + 
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO ;
