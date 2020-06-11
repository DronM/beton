-- VIEW: shipments_for_client_list

DROP VIEW shipments_for_client_list;

CREATE OR REPLACE VIEW shipments_for_client_list AS

	SELECT
		sh.order_id
		,o.client_id
		,get_shift_start(sh.ship_date_time) AS ship_date
		,o.destination_id
		,destinations_ref(dest)::text AS destinations_ref
		,o.concrete_type_id
		,concrete_types_ref(ct)::text AS concrete_types_ref
		,(o.pump_vehicle_id IS NOT NULL) AS pump_exists
		,sum(sh.quant) AS quant
		
		,sum( (SELECT pr.price FROM client_price_list(o.client_id) AS pr WHERE pr.concrete_type_id=o.concrete_type_id)*sh.quant ) AS concrete_cost
		
		,sum((CASE
			WHEN coalesce(sh.ship_cost_edit,FALSE) THEN sh.ship_cost
			WHEN dest.id=const_self_ship_dest_id_val() THEN 0
			WHEN o.concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(dest.price,0))			
				END
				*
				shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)			
		END)::numeric(15,2)
		) AS deliv_cost
		
		,(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0				
				WHEN (SELECT bool_or(coalesce(t.pump_for_client_cost_edit,FALSE)) FROM shipments t WHERE t.order_id=o.id)
					THEN (SELECT sum(coalesce(t.pump_for_client_cost,0)::numeric(15,2)) FROM shipments t WHERE t.order_id=o.id)
				--last ship only!!!
				ELSE
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = (pump_vehicle_price_on_date(pvh.pump_prices,o.date_time)->'keys'->>'id')::int
								--pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
			END
		) AS pump_cost
		
		--concrete
		,sum( (SELECT pr.price FROM client_price_list(o.client_id) AS pr WHERE pr.concrete_type_id=o.concrete_type_id)*sh.quant )+
		--deliv
		sum((CASE
			WHEN coalesce(sh.ship_cost_edit,FALSE) THEN sh.ship_cost
			WHEN dest.id=const_self_ship_dest_id_val() THEN 0
			WHEN o.concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(dest.price,0))			
				END
				*
				shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)			
		END)::numeric(15,2))+
		--pump
		(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0				
				WHEN (SELECT bool_or(coalesce(t.pump_for_client_cost_edit,FALSE)) FROM shipments t WHERE t.order_id=o.id)
					THEN (SELECT sum(coalesce(t.pump_for_client_cost,0)::numeric(15,2)) FROM shipments t WHERE t.order_id=o.id)
				--last ship only!!!
				ELSE
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = (pump_vehicle_price_on_date(pvh.pump_prices,o.date_time)->'keys'->>'id')::int
								--pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
			END
		)
		AS total_cost
		
		
	FROM shipments AS sh
	LEFT JOIN orders o ON o.id=sh.order_id
	LEFT JOIN destinations dest ON dest.id=o.destination_id
	LEFT JOIN concrete_types ct ON ct.id=o.concrete_type_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	WHERE cl.account_from_date IS NULL OR get_shift_start(sh.ship_date_time)>=cl.account_from_date
	GROUP BY 
		sh.order_id
		,o.id
		,o.date_time
		,o.client_id
		,get_shift_start(sh.ship_date_time)
		,o.destination_id
		,destinations_ref
		,o.concrete_type_id
		,concrete_types_ref
		,o.pump_vehicle_id
		,pvh.pump_prices
	ORDER BY get_shift_start(sh.ship_date_time) DESC
	;
	
ALTER VIEW shipments_for_client_list OWNER TO beton;
