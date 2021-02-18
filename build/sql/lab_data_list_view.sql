-- View: public.lab_data_list_view

-- DROP VIEW public.lab_data_list_view;

CREATE OR REPLACE VIEW public.lab_data_list_view
 AS
 SELECT sh.id AS shipment_id,
    sh.date_time,
    date5_descr(sh.date_time::date) AS ship_date_time_descr,
    cl.id AS client_id,
    cl.name AS client_descr,
    cl.phone_cel AS client_phone,
    lab.num,
    dest.name AS destination_descr,
    concr.name AS concrete_type_descr,
    sh.quant AS quant_descr,
    dr.name AS driver_descr,
    lab.id,
    lab.ok_sm,
    lab.weight,
    lab.weight_norm,
    lab.percent_1,
    lab.p_1,
    lab.p_2,
    lab.p_3,
    lab.p_4,
    lab.p_7,
    lab.p_28,
    lab.p_norm,
    lab.percent_2,
    lab.lab_comment
   FROM shipments sh
     LEFT JOIN lab_data lab ON lab.shipment_id = sh.id
     LEFT JOIN orders o ON o.id = sh.order_id
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN destinations dest ON dest.id = o.destination_id
     LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
     LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
     LEFT JOIN drivers dr ON dr.id = vs.driver_id
  ORDER BY sh.date_time;

ALTER TABLE public.lab_data_list_view
    OWNER TO beton;

GRANT ALL ON TABLE public.lab_data_list_view TO beton;
GRANT SELECT ON TABLE public.lab_data_list_view TO premier;


