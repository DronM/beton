-- View: ast_calls_client_ship_history_list

-- DROP VIEW ast_calls_client_ship_history_list;

CREATE OR REPLACE VIEW ast_calls_client_ship_history_list AS 
	SELECT
		o.client_id,
		o.comment_text,
		o.number,
		o.date_time,
		(SELECT
			sum(sh.quant) AS sum
		FROM shipments sh
		WHERE sh.order_id = o.id AND sh.shipped
		) AS quant,
		concrete_types_ref(ct) AS concrete_types_ref,
		destinations_ref(dst) AS destinations_ref,
		orders_ref(o) AS orders_ref
		
	FROM orders o
	LEFT JOIN concrete_types ct ON ct.id = o.concrete_type_id
	LEFT JOIN destinations dst ON dst.id = o.destination_id
	WHERE COALESCE(
		(SELECT
			sum(sh.quant) AS sum
		FROM shipments sh
		WHERE sh.order_id = o.id AND sh.shipped
		), 0::double precision
		) > 0::double precision
	ORDER BY o.date_time DESC;

ALTER TABLE ast_calls_client_ship_history_list
  OWNER TO beton;

