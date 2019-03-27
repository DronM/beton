-- Function: public.vehicles_ref(vehicles)

-- DROP FUNCTION public.vehicles_ref(vehicles);

CREATE OR REPLACE FUNCTION public.vehicles_ref(vehicles)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.plate,
		'dataType','vehicles'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicles_ref(vehicles) OWNER TO beton;

