-- View: public.orders_make_for_lab_list

-- DROP VIEW public.orders_make_for_lab_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_list AS 
	SELECT
		o.*,
		(need_t.need_cnt > 0) AS is_needed
	FROM orders_make_list o
	LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (o.concrete_types_ref->'keys'->>'id')::int
	WHERE o.date_time BETWEEN
		get_shift_start(now()::timestamp without time zone)
		AND get_shift_end(get_shift_start(now()::timestamp without time zone))
	ORDER BY o.date_time;
ALTER TABLE public.orders_make_for_lab_list OWNER TO ;
