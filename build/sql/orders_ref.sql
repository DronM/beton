-- Function: public.orders_ref(orders)

-- DROP FUNCTION public.orders_ref(orders);

CREATE OR REPLACE FUNCTION public.orders_ref(orders)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr','Заявка №'||$1.number::text||' от '||to_char($1.date_time,'DD/MM/YY HH24:MI'),
		'dataType','orders'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.orders_ref(orders) OWNER TO beton;

