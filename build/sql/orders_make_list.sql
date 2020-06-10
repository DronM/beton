-- View: public.orders_make_list

-- DROP VIEW public.orders_make_list;

CREATE OR REPLACE VIEW public.orders_make_list AS 
 SELECT o.id,
    clients_ref(cl.*) AS clients_ref,
    destinations_ref(d.*) AS destinations_ref,
    concrete_types_ref(concr.*) AS concrete_types_ref,
    o.comment_text,
    o.descr,
    o.phone_cel,
    o.unload_speed,
    o.date_time,
    o.date_time_to,
    o.quant,
    o.quant - COALESCE(( SELECT sum(shipments.quant) AS sum
           FROM shipments
          WHERE shipments.order_id = o.id AND shipments.shipped), 0::double precision) AS quant_rest,
        CASE
            WHEN o.date_time::time without time zone >= const_first_shift_start_time_val() AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val()) AND o.date_time_to::time without time zone >= const_first_shift_start_time_val() AND o.date_time_to::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val()) THEN o.quant
            WHEN o.date_time::time without time zone >= const_first_shift_start_time_val() AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val()) AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val()) THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, o.date_time::date + (const_first_shift_start_time_val()::interval + const_day_shift_length_val()) - o.date_time) / 60::double precision))::numeric, 2)::double precision
            ELSE 0::double precision
        END AS quant_ordered_day,
        CASE
            WHEN now()::timestamp without time zone > o.date_time AND now()::timestamp without time zone < o.date_time_to THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, now()::timestamp without time zone::timestamp with time zone - o.date_time::timestamp with time zone) / 60::double precision))::numeric, 2)::double precision
            WHEN now()::timestamp without time zone > o.date_time_to THEN o.quant
            ELSE 0::double precision
        END AS quant_ordered_before_now,
    ( SELECT COALESCE(sum(shipments.quant), 0::double precision) AS sum
           FROM shipments
          WHERE shipments.order_id = o.id AND shipments.ship_date_time < now()::timestamp without time zone) AS quant_shipped_before_now,
    ( SELECT COALESCE(sum(shipments.quant), 0::double precision) AS sum
           FROM shipments
          WHERE shipments.order_id = o.id AND shipments.ship_date_time::time without time zone >= constant_first_shift_start_time() AND shipments.ship_date_time::time without time zone <= (const_first_shift_start_time_val()::interval + const_day_shift_length_val())) AS quant_shipped_day_before_now,
        CASE
            WHEN (o.quant - COALESCE(( SELECT sum(shipments.quant) AS sum
               FROM shipments
              WHERE shipments.order_id = o.id AND shipments.shipped), 0::double precision)) > 0::double precision AND (now()::timestamp without time zone::timestamp with time zone - (( SELECT shipments.ship_date_time
               FROM shipments
              WHERE shipments.order_id = o.id AND shipments.shipped
              ORDER BY shipments.ship_date_time DESC
             LIMIT 1))::timestamp with time zone) > const_ord_mark_if_no_ship_time_val()::interval THEN true
            ELSE false
        END AS no_ship_mark,
    o.payed,
    o.under_control,
    o.pay_cash,
        CASE
            WHEN o.pay_cash THEN o.total
            ELSE 0::numeric
        END AS total,
    vh.owner AS pump_vehicle_owner,
    o.unload_type,
    ( SELECT (owners."row" -> 'fields'::text) -> 'owner'::text
           FROM ( SELECT jsonb_array_elements(vh.vehicle_owners -> 'rows'::text) AS "row") owners
          WHERE o.date_time >= (((owners."row" -> 'fields'::text) ->> 'dt_from'::text)::timestamp without time zone)
          ORDER BY (((owners."row" -> 'fields'::text) ->> 'dt_from'::text)::timestamp without time zone) DESC
         LIMIT 1) AS pump_vehicle_owners_ref,
    pvh.pump_length AS pump_vehicle_length,
    pvh.comment_text AS pump_vehicle_comment
   FROM orders o
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN destinations d ON d.id = o.destination_id
     LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
     LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
     LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
  ORDER BY o.date_time;

ALTER TABLE public.orders_make_list OWNER TO beton;

