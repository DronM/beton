-- Function: public.destinations_ref(destinations)

-- DROP FUNCTION public.destinations_ref(destinations);

CREATE OR REPLACE FUNCTION public.destinations_ref(destinations)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','destinations'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.destinations_ref(destinations) OWNER TO beton;

