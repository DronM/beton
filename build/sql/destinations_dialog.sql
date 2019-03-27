-- View: public.destinations_dialog

-- DROP VIEW public.destinations_dialog;

CREATE OR REPLACE VIEW public.destinations_dialog AS 
	SELECT
		destinations.id,
		destinations.name,
		destinations.distance,
		destinations.time_route,
		destinations.price,
		replace(replace(st_astext(destinations.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text) AS zone_str,
		replace(replace(st_astext(st_centroid(destinations.zone)), 'POINT('::text, ''::text), ')'::text, ''::text) AS zone_center_str
	FROM destinations;

ALTER TABLE public.destinations_dialog
  OWNER TO beton;

