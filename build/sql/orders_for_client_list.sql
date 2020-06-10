-- VIEW: orders_for_client_list

--DROP VIEW orders_for_client_list;

CREATE OR REPLACE VIEW orders_for_client_list AS
	SELECT
		o.id 
		,o.date_time
		,o.number
		,o.client_id
		,destinations_ref(dest) AS destinations_ref
		,o.destination_id
		,concrete_types_ref(ct) AS concrete_types_ref
		,o.concrete_type_id
		,coalesce(o.quant,0) AS quant_ordered
		,coalesce(sh.quant,0) AS quant_shipped
		,coalesce(o.quant,0) - coalesce(sh.quant,0) AS quant_balance
		
	FROM orders o
	LEFT JOIN destinations dest ON dest.id=o.destination_id
	LEFT JOIN concrete_types ct ON ct.id=o.concrete_type_id
	LEFT JOIN (
		SELECT
			t.order_id
			,sum(t.quant) AS quant
		FROM shipments t 
		GROUP BY t.order_id
	) AS sh ON sh.order_id=o.id
	LEFT JOIN clients cl ON cl.id = o.client_id
	WHERE cl.account_from_date IS NULL OR o.date_time::date>=cl.account_from_date
	ORDER BY date_time DESC
	;
	
ALTER VIEW orders_for_client_list OWNER TO ;
