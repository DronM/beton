-- Function: client_price_list(in_client_id int)

-- DROP FUNCTION client_price_list(in_client_id int);

CREATE OR REPLACE FUNCTION client_price_list(in_client_id int)
  RETURNS TABLE(
  	concrete_type_id int,
  	price numeric(15,2)
  ) AS
$$
	WITH
	client_price AS (
		SELECT h.id
		FROM concrete_costs_h AS h
		WHERE in_client_id =ANY (h.clients_ar)
		ORDER BY h.date DESC
		LIMIT 1
	)
	,common_price AS (
		SELECT h.id
		FROM concrete_costs_h AS h
		WHERE 0 =ANY (h.clients_ar)
		ORDER BY h.date DESC
		LIMIT 1
	)
	SELECT
		t.concrete_type_id,
		t.price
	FROM concrete_costs AS t
	WHERE t.concrete_costs_h_id =
		CASE
			WHEN coalesce((SELECT count(*) FROM client_price),0)>0 THEN
				(SELECT id FROM client_price)
			ELSE (SELECT id FROM common_price)
		END
	ORDER BY t.concrete_type_id	
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION client_price_list(in_client_id int) OWNER TO ;
