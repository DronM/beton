-- View: public.destination_dialog_view

-- DROP VIEW public.destination_dialog_view;

CREATE OR REPLACE VIEW public.destination_dialog_view
 AS
 SELECT destinations.id,
    destinations.name,
    destinations.distance,
    time5_descr(destinations.time_route) AS time_route_descr,
    destinations.price,
    replace(replace(st_astext(destinations.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text) AS zone_str,
    replace(replace(st_astext(st_centroid(destinations.zone)), 'POINT('::text, ''::text), ')'::text, ''::text) AS zone_center_str
   FROM destinations;

ALTER TABLE public.destination_dialog_view
    OWNER TO beton;
