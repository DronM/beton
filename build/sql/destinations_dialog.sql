-- View: public.destinations_dialog

-- DROP VIEW public.destinations_dialog;

CREATE OR REPLACE VIEW public.destinations_dialog AS 
	WITH
	last_price AS
		(SELECT
			max(t.date) AS date,
			t.distance_to
		FROM shipment_for_owner_costs AS t
		GROUP BY t.distance_to
		ORDER BY t.distance_to
		)
	,act_price AS
		(SELECT
			t.distance_to,
			t.price
		FROM last_price
		LEFT JOIN shipment_for_owner_costs AS t ON last_price.date=t.date AND last_price.distance_to=t.distance_to
		ORDER BY t.distance_to
		)

	SELECT
		destinations.id,
		destinations.name,
		destinations.distance,
		destinations.time_route,
		
		CASE
			WHEN coalesce(destinations.special_price,FALSE) = TRUE THEN coalesce(destinations.price,0)
			ELSE
				coalesce(
					coalesce(
						(SELECT act_price.price
						FROM act_price
						WHERE destinations.distance <= act_price.distance_to
						LIMIT 1
						)
					,destinations.price)
				,0)
		END AS price,
		
		destinations.special_price,
		
		replace(replace(st_astext(destinations.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text) AS zone_str,
		replace(replace(st_astext(st_centroid(destinations.zone)), 'POINT('::text, ''::text), ')'::text, ''::text) AS zone_center_str
		
	FROM destinations;

ALTER TABLE public.destinations_dialog OWNER TO ;

