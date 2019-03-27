-- Function: public.client_come_from_ref(client_come_from)

-- DROP FUNCTION public.client_come_from_ref(client_come_from);

CREATE OR REPLACE FUNCTION public.client_come_from_ref(client_come_from)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','client_come_from'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.client_come_from_ref(client_come_from) OWNER TO beton;

