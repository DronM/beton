-- View: public.clients_list

-- DROP VIEW public.clients_list;

CREATE OR REPLACE VIEW public.clients_list AS 
	SELECT
		cl.id,
		cl.name,
		cl.manager_comment,
		cl.client_type_id,
		client_types_ref(ct) AS client_types_ref,
		client_come_from_ref(ccf) AS client_come_from_ref,
		cl.client_come_from_id,
		cl.phone_cel,		
		COALESCE(o.quant, 0::double precision) > 0::double precision AS ours,
		cl.client_kind,
		cl.email,
		
		(SELECT
			a.dt::date AS dt
		FROM ast_calls a
		WHERE a.client_id = cl.id
		ORDER BY a.dt
		LIMIT 1
		) AS first_call_date,
		
		users_ref(man) AS users_ref
		
	FROM clients cl
	LEFT JOIN client_types ct ON ct.id = cl.client_type_id
	LEFT JOIN client_come_from ccf ON ccf.id = cl.client_come_from_id
	LEFT JOIN users man ON man.id = cl.manager_id
	LEFT JOIN (
		SELECT
			orders.client_id,
	    		sum(orders.quant) AS quant
	   	FROM orders
	  	GROUP BY orders.client_id
	) o ON o.client_id = cl.id
	ORDER BY cl.name;

ALTER TABLE public.clients_list OWNER TO beton;

