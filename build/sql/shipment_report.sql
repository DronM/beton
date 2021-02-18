-- View: public.shipment_report

-- DROP VIEW public.shipment_report;

CREATE OR REPLACE VIEW public.shipment_report
 AS
 SELECT sh.ship_date_time,
    get_shift_descr(sh.ship_date_time) AS shift_descr,
    ct.id AS concrete_id,
    ct.name AS concrete_descr,
    cl.id AS client_id,
    cl.name AS client_descr,
    d.id AS destination_id,
    d.name AS destination_descr,
    dr.id AS driver_id,
    dr.name AS driver_descr,
    vh.id AS vehicle_id,
    vh.plate AS vehicle_descr,
    vh.feature AS vehicle_feature,
    vh.owner AS vehicle_owner,
    shipment_descr(sh.*) AS shipment_descr,
    sh.quant AS quant_shipped
   FROM shipments sh
     LEFT JOIN orders o ON o.id = sh.order_id
     LEFT JOIN concrete_types ct ON ct.id = o.concrete_type_id
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN destinations d ON d.id = o.destination_id
     LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
     LEFT JOIN drivers dr ON dr.id = vs.driver_id
     LEFT JOIN vehicles vh ON vh.id = vs.vehicle_id;

ALTER TABLE public.shipment_report
    OWNER TO beton;

GRANT ALL ON TABLE public.shipment_report TO beton;

