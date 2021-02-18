-- View: public.order_dialog_view

-- DROP VIEW public.order_dialog_view;

CREATE OR REPLACE VIEW public.order_dialog_view
 AS
 SELECT o.id,
    order_num(o.*) AS number,
    cl.name AS client_descr,
    o.client_id,
    d.name AS destination_descr,
    o.destination_id,
    o.destination_price,
    concr.name AS concrete_type_descr,
    o.concrete_type_id,
    o.concrete_price,
    o.unload_type,
    get_unload_types_descr(o.unload_type) AS unload_type_descr,
    COALESCE(o.comment_text, ''::text) AS comment_text,
    COALESCE(o.descr, ''::text) AS descr,
    o.phone_cel,
    o.unload_speed,
    date8_time5_descr(o.date_time) AS date_time_descr,
    date8_descr(o.date_time::date) AS date_time_date_descr,
    time5_descr(o.date_time::time without time zone) AS date_time_time_descr,
    o.date_time,
    o.time_to,
    time5_descr(o.date_time::time without time zone + '01:00:00'::interval) AS time_to_user_descr,
    time5_descr(o.time_to) AS time_to_descr,
    o.quant,
    l.id AS lang_id,
    l.name AS lang_descr,
    o.total,
    o.total_edit,
    o.pump_vehicle_id,
    pv.vehicle_descr AS pump_vehicle_descr,
    pv.pump_price_id,
    pv.pump_price_descr,
    o.pay_cash,
    o.unload_price,
    o.payed,
    o.under_control
   FROM orders o
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN destinations d ON d.id = o.destination_id
     LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
     LEFT JOIN langs l ON l.id = o.lang_id
     LEFT JOIN pump_vehicles_list pv ON pv.id = o.pump_vehicle_id
  ORDER BY o.date_time;

ALTER TABLE public.order_dialog_view
    OWNER TO beton;

GRANT ALL ON TABLE public.order_dialog_view TO beton;
GRANT SELECT ON TABLE public.order_dialog_view TO premier;


