-- View: ast_calls_new_list

-- DROP VIEW ast_calls_new_list;

CREATE OR REPLACE VIEW ast_calls_new_list AS 
	SELECT
		ac.unique_id,
		
		ac.client_id,
		clients_ref(cl) AS clients_ref,

		ac.user_id,
		users_ref(u) AS users_ref,
		
		ac.call_type,
		ac.dt AS start_time,
		ac.end_time AS end_time,
		ac.end_time - ac.start_time AS dur_time,		
		ac.manager_comment AS manager_comment,
		cl.manager_comment AS client_comment,
		cl.create_date AS client_create_date,
		COALESCE(o.quant, 0::numeric) > 0::numeric AS ours,
		
		cl.client_type_id,
		client_types_ref(clt) AS client_types_ref,

		cl.client_come_from_id,
		client_come_from_ref(clcfr) AS client_come_from_ref,
		
		cl.client_kind,
		
		ac.caller_id_num,
		ac.ext,
		
		CASE
		WHEN ac.call_type = 'in'::call_types THEN (ac.caller_id_num::text || ' => '::text) || ac.ext::text
		ELSE (ac.ext::text || ' => '::text) || ac.caller_id_num::text
		END AS num,
		
		offer.quant AS offer_quant,
		offer.total AS offer_total,
		offer.offer_result
		
	FROM ast_calls ac
	LEFT JOIN clients cl ON cl.id = ac.client_id
	LEFT JOIN client_types clt ON clt.id = cl.client_type_id
	LEFT JOIN client_come_from clcfr ON clcfr.id = cl.client_come_from_id
	LEFT JOIN users u ON u.id = ac.user_id
	LEFT JOIN offer ON offer.ast_call_unique_id = ac.unique_id
	LEFT JOIN (
		SELECT
			orders.client_id,
			sum(orders.quant) AS quant
		FROM orders
		GROUP BY orders.client_id
	) o ON o.client_id = cl.id
	ORDER BY ac.dt DESC;

ALTER TABLE ast_calls_new_list
  OWNER TO beton;

