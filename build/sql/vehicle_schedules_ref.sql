-- Function: public.vehicle_schedules_ref(vehicle_schedules,vehicles,drivers)

-- DROP FUNCTION public.vehicle_schedules_ref(vehicle_schedules,vehicles,drivers);

CREATE OR REPLACE FUNCTION public.vehicle_schedules_ref(vehicle_schedules,vehicles,drivers)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',coalesce($2.plate,'')||coalesce(' '||$3.name,''),
		'dataType','vehicle_schedules'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicle_schedules_ref(vehicle_schedules,vehicles,drivers) OWNER TO beton;

