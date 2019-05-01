-- View: destination_list_view

-- DROP VIEW destination_list_view;

CREATE OR REPLACE VIEW destination_list_view AS 
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
		time5_descr(destinations.time_route) AS time_route,
		coalesce(
			coalesce(
				(SELECT act_price.price
				FROM act_price
				WHERE destinations.distance <= act_price.distance_to
				LIMIT 1
				)
			,destinations.price)
		,0) AS price
	FROM destinations
	
	ORDER BY destinations.name;

ALTER TABLE destination_list_view
  OWNER TO ;

