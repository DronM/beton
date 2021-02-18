-- View: public.shipments_list_test

-- DROP VIEW public.shipments_list_test;

CREATE OR REPLACE VIEW public.shipments_list_test
 AS
 SELECT sh.id,
    sh.ship_date_time,
    sh.quant,
    o.concrete_type_id,
    o.date_time::date AS date_time,
    concr.name,
    cl.name AS client_name,
    dest.name AS dest_name,
    shipments_cost(dest.*, o.concrete_type_id, o.date_time::date, sh.*, true) AS cost
   FROM shipments sh
     LEFT JOIN orders o ON o.id = sh.order_id
     LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN destinations dest ON dest.id = o.destination_id
     LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
  ORDER BY sh.date_time DESC;

ALTER TABLE public.shipments_list_test
    OWNER TO beton;

GRANT ALL ON TABLE public.shipments_list_test TO beton;

