-- Function: shipments_pump_cost(shipments, orders, destinations, pump_vehicles, bool)

--DROP FUNCTION shipments_pump_cost(shipments, orders, destinations, pump_vehicles, bool);

CREATE OR REPLACE FUNCTION shipments_pump_cost(in_shipments shipments, in_orders orders, in_destinations destinations,
	in_pump_vehicles pump_vehicles, in_editable bool)
  RETURNS numeric(15,2) AS
$$
	SELECT
		CASE
			WHEN in_orders.pump_vehicle_id IS NULL THEN 0
			WHEN in_editable AND coalesce(in_shipments.pump_cost_edit,FALSE) THEN in_shipments.pump_cost::numeric(15,2)
			--last ship only!!!
			WHEN in_shipments.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=in_orders.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(in_orders.unload_price,0)>0 THEN in_orders.unload_price::numeric(15,2)
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*in_orders.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = in_pump_vehicles.pump_price_id
							AND in_orders.quant<=pr_vals.quant_to
						ORDER BY pr_vals.quant_to ASC
						LIMIT 1
						)::numeric(15,2)
				END
			ELSE 0	
		END
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION shipments_pump_cost(shipments, orders, destinations, pump_vehicles, bool) OWNER TO ;

