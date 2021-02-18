-- View: public.shipment_list_view

-- DROP VIEW public.shipment_list_view;

CREATE OR REPLACE VIEW public.shipment_list_view
 AS
 SELECT sh.id,
    sh.ship_date_time,
    date8_time5_descr(sh.ship_date_time) AS ship_date_time_descr,
    sh.quant,
    calc_ship_coast(sh.*, dest.*, true) AS coast,
    sh.shipped,
    concr.name AS concrete_type_descr,
    v.owner,
    v.plate AS vehicle_descr,
    d.name AS driver_descr,
    dest.id AS destination_id,
    dest.name AS destination_descr,
    cl.id AS client_id,
    cl.name AS client_descr,
    time5_descr(sh.demurrage) AS demurrage,
    calc_demurrage_coast(sh.demurrage::interval) AS demurrage_coast,
    sh.client_mark,
        CASE sh.blanks_exist
            WHEN true THEN 'ЕСТЬ'::text
            ELSE ''::text
        END AS blanks_exist
   FROM shipments sh
     LEFT JOIN orders o ON o.id = sh.order_id
     LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
     LEFT JOIN destinations dest ON dest.id = o.destination_id
     LEFT JOIN drivers d ON d.id = vs.driver_id
     LEFT JOIN vehicles v ON v.id = vs.vehicle_id
  ORDER BY sh.date_time;

ALTER TABLE public.shipment_list_view
    OWNER TO beton;

GRANT ALL ON TABLE public.shipment_list_view TO beton;

