-- View: public.lab_entry_list_view

-- DROP VIEW public.lab_entry_list_view;

CREATE OR REPLACE VIEW public.lab_entry_list_view
 AS
 SELECT lab.shipment_id AS id,
    sh.id AS shipment_id,
    sh.date_time,
    date5_descr(sh.date_time::date) AS ship_date_time_descr,
    concr.id AS concrete_type_id,
    concr.name AS concrete_type_descr,
    ( SELECT round(avg(d.ok)) AS round
           FROM lab_entry_details d
          WHERE d.shipment_id = sh.id) AS ok,
    ( SELECT round(avg(d.weight)) AS round
           FROM lab_entry_details d
          WHERE d.shipment_id = sh.id AND d.id >= 3) AS weight,
    round(
        CASE
            WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN (( SELECT avg(s_lab_det.kn::numeric / concr.mpa_ratio) AS avg
               FROM lab_entry_details s_lab_det
              WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id < 3)) / concr.pres_norm * 100::numeric * 2::numeric / 2::numeric
            ELSE 0::numeric
        END) AS p7,
    round(
        CASE
            WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN (( SELECT avg(s_lab_det.kn::numeric / concr.mpa_ratio) AS avg
               FROM lab_entry_details s_lab_det
              WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id >= 3)) / concr.pres_norm * 100::numeric * 2::numeric / 2::numeric
            ELSE 0::numeric
        END) AS p28,
    lab.samples,
    lab.materials,
    cl.id AS client_id,
    cl.name AS client_descr,
    cl.phone_cel AS client_phone,
    dest.name AS destination_descr,
    lab.ok2,
    lab."time"
   FROM shipments sh
     LEFT JOIN lab_entries lab ON lab.shipment_id = sh.id
     LEFT JOIN orders o ON o.id = sh.order_id
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN destinations dest ON dest.id = o.destination_id
     LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
  ORDER BY sh.date_time, sh.id;

ALTER TABLE public.lab_entry_list_view
    OWNER TO beton;


