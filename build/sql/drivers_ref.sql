-- Function: public.drivers_ref(drivers)

-- DROP FUNCTION public.drivers_ref(drivers);

CREATE OR REPLACE FUNCTION public.drivers_ref(drivers)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','drivers'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.drivers_ref(drivers) OWNER TO beton;

