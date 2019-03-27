-- Function: public.client_types_ref(client_types)

-- DROP FUNCTION public.client_types_ref(client_types);

CREATE OR REPLACE FUNCTION public.client_types_ref(client_types)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','client_types'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.client_types_ref(client_types) OWNER TO beton;

