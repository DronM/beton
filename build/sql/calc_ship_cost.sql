-- Function: public.calc_ship_cost(shipments, destinations, boolean)

-- DROP FUNCTION public.calc_ship_cost(shipments, destinations, boolean);

CREATE OR REPLACE FUNCTION public.calc_ship_cost(
    in_shipment shipments,
    in_destination destinations,
    for_account boolean)
  RETURNS numeric AS
$BODY$
	SELECT
		CASE
			WHEN NOT for_account AND in_destination.id=const_self_ship_dest_id_val() THEN
				const_ship_coast_for_self_ship_destination_val()::numeric
			WHEN for_account AND in_destination.id=constant_self_ship_dest_id() THEN 0
			ELSE
				COALESCE(
					round(
						GREATEST(const_min_quant_for_ship_coast_val()::numeric, in_shipment.quant::numeric)
						* in_destination.price::numeric,
					2)::numeric,
				0::numeric)
		END;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.calc_ship_cost(shipments, destinations, boolean)
  OWNER TO beton;

