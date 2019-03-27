-- Function: public.concrete_types_ref(concrete_types)

-- DROP FUNCTION public.concrete_types_ref(concrete_types);

CREATE OR REPLACE FUNCTION public.concrete_types_ref(concrete_types)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','concrete_types'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_types_ref(concrete_types) OWNER TO beton;

