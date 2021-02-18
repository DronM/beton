-- View: public.shipment_dialog_view

-- DROP VIEW public.shipment_dialog_view;

CREATE OR REPLACE VIEW public.shipment_dialog_view
 AS
 SELECT sh.id,
    date8_time5_descr(sh.date_time) AS date_time_descr,
    date8_time5_descr(sh.ship_date_time) AS ship_date_time_descr,
    sh.date_time,
    sh.ship_date_time,
    time5_descr(sh.date_time::time without time zone) AS time_descr,
        CASE
            WHEN sh.shipped THEN time5_descr(sh.ship_date_time::time without time zone)
            ELSE ''::character varying
        END AS ship_time_descr,
    sh.quant,
    v.plate AS vehicle_descr,
    d.name AS driver_descr,
    dest.id AS destination_id,
    dest.name AS destination_descr,
    sh.vehicle_schedule_id,
    cl.id AS client_id,
    cl.name AS client_descr,
    sh.shipped,
    sh.client_mark,
    sh.demurrage,
    (d.name::text || ' '::text) || v.plate::text AS vehicle_schedule_descr,
    time5_descr(sh.demurrage) AS demurrage_descr,
    sh.blanks_exist
   FROM shipments sh
     LEFT JOIN orders o ON o.id = sh.order_id
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
     LEFT JOIN destinations dest ON dest.id = o.destination_id
     LEFT JOIN drivers d ON d.id = vs.driver_id
     LEFT JOIN vehicles v ON v.id = vs.vehicle_id
  ORDER BY sh.date_time;

ALTER TABLE public.shipment_dialog_view
    OWNER TO beton;

GRANT ALL ON TABLE public.shipment_dialog_view TO beton;

