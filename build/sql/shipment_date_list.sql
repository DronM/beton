-- View: public.shipment_date_list

-- DROP VIEW public.shipment_date_list;

CREATE OR REPLACE VIEW public.shipment_date_list
 AS
 SELECT sh.ship_date_time::date AS ship_date,
    date8_descr(sh.ship_date_time::date) AS ship_date_descr,
    concr.id AS concrete_type_id,
    concr.name AS concrete_type_descr,
    dest.id AS destination_id,
    dest.name AS destination_descr,
    cl.id AS client_id,
    cl.name AS client_descr,
    sum(sh.quant) AS quant,
    sum(calc_ship_coast(sh.*, dest.*, true)) AS ship_cost,
    time5_descr(sum(sh.demurrage::interval)::time without time zone) AS demurrage,
    sum(calc_demurrage_coast(sh.demurrage::interval)) AS demurrage_cost
   FROM shipments sh
     LEFT JOIN orders o ON o.id = sh.order_id
     LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
     LEFT JOIN clients cl ON cl.id = o.client_id
     LEFT JOIN destinations dest ON dest.id = o.destination_id
  GROUP BY (sh.ship_date_time::date), (date8_time5_descr(sh.ship_date_time::date::timestamp without time zone)), concr.id, concr.name, dest.id, dest.name, cl.id, cl.name
  ORDER BY (sh.ship_date_time::date);

ALTER TABLE public.shipment_date_list
    OWNER TO beton;

GRANT ALL ON TABLE public.shipment_date_list TO beton;

