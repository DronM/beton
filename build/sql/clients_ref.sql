-- Function: public.clients_ref(clients)

-- DROP FUNCTION public.clients_ref(clients);

CREATE OR REPLACE FUNCTION public.clients_ref(clients)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name||CASE WHEN $1.inn IS NOT NULL AND length($1.inn)>0 THEN ', '||$1.inn ELSE '' END,
		'dataType','clients'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.clients_ref(clients) OWNER TO beton;

