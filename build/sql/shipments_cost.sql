-- Function: shipments_cost(destinations, int, date, shipments, bool)

--DROP FUNCTION shipments_cost(destinations, int, date, shipments, bool);

CREATE OR REPLACE FUNCTION shipments_cost(in_destinations destinations, in_concrete_type_id int, in_date date, in_shipments shipments, in_editable bool)
  RETURNS numeric(15,2) AS
$$
	SELECT
		(CASE
			WHEN in_editable AND coalesce(in_shipments.ship_cost_edit,FALSE) THEN in_shipments.ship_cost
			WHEN in_destinations.id=const_self_ship_dest_id_val() THEN 0
			WHEN in_concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(in_destinations.special_price,FALSE) THEN coalesce(in_destinations.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=in_date AND sh_p.distance_to>=in_destinations.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(in_destinations.price,0))			
				END
				*
				CASE
					WHEN in_shipments.quant>=7 THEN in_shipments.quant
					WHEN in_destinations.distance<=60 THEN greatest(5,in_shipments.quant)
					ELSE 7
				END
		END)::numeric(15,2)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION shipments_cost(destinations, int, date, shipments, bool) OWNER TO ;

