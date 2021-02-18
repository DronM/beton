-- View: public.lab_orders_list

-- DROP VIEW public.lab_orders_list;

CREATE OR REPLACE VIEW public.lab_orders_list
 AS
 SELECT o.id,
    o.client_descr,
    o.client_id,
    o.destination_descr,
    o.destination_id,
    o.concrete_type_descr,
    o.concrete_type_id,
    o.unload_type,
    o.unload_type_descr,
    o.comment_text,
    o.descr,
    o.phone_cel,
    o.unload_speed,
    o.date_time_descr,
    o.date_time_date_descr,
    o.date_time_time_descr,
    o.date_time,
    o.date_time_to,
    o.date_time_to_user_descr,
    o.date_time_to_descr,
    o.quant,
    o.quant_rest,
    o.quant_ordered_before_now,
    o.quant_ordered_day,
    o.quant_shipped_before_now,
    o.quant_shipped_day_before_now,
    o.no_ship_mark,
    o.total,
    o.total_descr,
    o.payed,
        CASE
            WHEN need_t.need_cnt > 0::numeric THEN 'нужно'::text
            ELSE ''::text
        END AS need
   FROM orders_make_list_view o
     LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = o.concrete_type_id
  WHERE o.date_time >= get_shift_start(now()::timestamp without time zone) AND o.date_time <= get_shift_end(get_shift_start(now()::timestamp without time zone));

ALTER TABLE public.lab_orders_list
    OWNER TO beton;

