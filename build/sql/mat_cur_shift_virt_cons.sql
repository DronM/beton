-- View: public.mat_cur_shift_virt_cons

-- DROP VIEW public.mat_cur_shift_virt_cons;

CREATE OR REPLACE VIEW public.mat_cur_shift_virt_cons
AS
	SELECT
		sub.material_id,
		sum(sub.mat_cons) AS quant
	FROM (
		SELECT
			mr.material_id,
			mr.rate::double precision * sum( COALESCE(o.quant, 0::double precision) -
				COALESCE(
					(SELECT sum(sh.quant) AS sum
					FROM shipments sh
					WHERE sh.order_id = o.id
					)
				, 0::double precision)
				) AS mat_cons
		FROM orders o
		LEFT JOIN (
			SELECT r.concrete_type_id,
			r.material_id,
			r.rate
			FROM raw_material_cons_rates(0, now()::timestamp without time zone) r(concrete_type_id, material_id, rate)
		) mr ON mr.concrete_type_id = o.concrete_type_id
		
		WHERE
			o.date_time >= get_shift_start(now()::timestamp without time zone)
			AND o.date_time <= get_shift_end(get_shift_start(now()::timestamp without time zone))
			
		GROUP BY mr.rate, mr.material_id
		
		HAVING sum( COALESCE(o.quant, 0::double precision) -
			COALESCE(
				(SELECT sum(sh.quant) AS sum
				FROM shipments sh
				WHERE sh.order_id = o.id
				)
			, 0::double precision)
			) > 0::double precision) sub
		GROUP BY sub.material_id;

ALTER TABLE public.mat_cur_shift_virt_cons OWNER TO ;

