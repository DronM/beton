-- Function: public.mat_virtual_consumption(in_date_time_from timestamp without time zone,in_date_time_to timestamp without time zone)

-- DROP FUNCTION public.mat_virtual_consumption(in_date_time_from timestamp without time zone,in_date_time_to timestamp without time zone)

CREATE OR REPLACE FUNCTION public.mat_virtual_consumption(in_date_time_from timestamp without time zone,in_date_time_to timestamp without time zone)
RETURNS TABLE(
	material_id integer,
	quant numeric
) AS
$BODY$
	SELECT
		sub.material_id,
		sum(sub.mat_cons) AS quant
	FROM (
		SELECT
			mr.material_id,
			(mr.rate::numeric * sum( COALESCE(o.quant, 0::numeric) -
				COALESCE(
					(SELECT sum(sh.quant) AS sum
					FROM shipments sh
					WHERE sh.order_id = o.id
					)
				, 0::numeric)
				)
			)::numeric AS mat_cons
		FROM orders o
		LEFT JOIN (
			SELECT r.concrete_type_id,
			r.material_id,
			r.rate
			FROM raw_material_cons_rates(0, now()::timestamp without time zone) r(concrete_type_id, material_id, rate)
		) mr ON mr.concrete_type_id = o.concrete_type_id
		
		WHERE
			o.date_time >= in_date_time_from
			AND o.date_time <= in_date_time_to
			
		GROUP BY mr.rate, mr.material_id
		
		HAVING sum( COALESCE(o.quant, 0::numeric) -
			COALESCE(
				(SELECT sum(sh.quant) AS sum
				FROM shipments sh
				WHERE sh.order_id = o.id
				)
			, 0::numeric)
			) > 0::numeric) sub
		GROUP BY sub.material_id;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_virtual_consumption(in_date_time_from timestamp without time zone,in_date_time_to timestamp without time zone)
  OWNER TO beton;

