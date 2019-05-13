-- Function: public.vehicle_owners_ref(vehicle_owners)

-- DROP FUNCTION public.vehicle_owners_ref(vehicle_owners);

CREATE OR REPLACE FUNCTION public.vehicle_owners_ref(vehicle_owners)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','vehicle_owners'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicle_owners_ref(vehicle_owners) OWNER TO beton;

