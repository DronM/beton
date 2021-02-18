-- View: public.orders_list_view

-- DROP VIEW public.orders_list_view;

CREATE OR REPLACE VIEW public.orders_list_view
 AS
 SELECT o.id,
    order_num(o.*) AS number,
    get_short_str(cl.name::text, 15) AS client_descr,
    o.client_id,
    get_short_str(d.name::text, 10) AS destination_descr,
    concr.name AS concrete_type_descr,
    get_unload_types_descr(o.unload_type) AS unload_type_descr,
    get_short_str(o.comment_text, 15) AS comment_text,
    get_short_str(o.descr, 15) AS descr,
    o.phone_cel,
    date8_time5_descr(o.date_time) AS date_time_descr,
    o.date_time,
    o.quant,
    o.user_id,
    u.name AS user_descr
   FROM orders o
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN destinations d ON d.id = o.destination_id
     LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
     LEFT JOIN users u ON u.id = o.user_id
  ORDER BY o.date_time;

ALTER TABLE public.orders_list_view
    OWNER TO beton;

GRANT ALL ON TABLE public.orders_list_view TO beton;

