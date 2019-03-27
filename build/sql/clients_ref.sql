-- Function: public.clients_ref(clients)

-- DROP FUNCTION public.clients_ref(clients);

CREATE OR REPLACE FUNCTION public.clients_ref(clients)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','clients'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.clients_ref(clients) OWNER TO beton;

