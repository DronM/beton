-- View: public.orders_make_for_lab_list

-- DROP VIEW public.orders_make_for_lab_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_list AS 
 SELECT o.id,
    o.clients_ref,
    o.destinations_ref,
    o.concrete_types_ref,
    o.comment_text,
    o.descr,
    o.phone_cel,
    o.unload_speed,
    o.date_time,
    o.date_time_to,
    o.quant,
    o.quant_rest,
    o.quant_ordered_day,
    o.quant_ordered_before_now,
    o.quant_shipped_before_now,
    o.quant_shipped_day_before_now,
    o.no_ship_mark,
    o.payed,
    o.under_control,
    o.pay_cash,
    o.total,
    o.pump_vehicle_owner,
    o.unload_type,
    o.pump_vehicle_owners_ref,
    o.pump_vehicle_length,
    o.pump_vehicle_comment,
    need_t.need_cnt > 0::numeric AS is_needed
   FROM orders_make_list o
     LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (((o.concrete_types_ref -> 'keys'::text) ->> 'id'::text)::integer)
  WHERE o.date_time >= get_shift_start(now()::timestamp without time zone) AND o.date_time <= get_shift_end(get_shift_start(now()::timestamp without time zone))
  ORDER BY o.date_time;

ALTER TABLE public.orders_make_for_lab_list
  OWNER TO beton;

