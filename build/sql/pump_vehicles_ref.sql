-- Function: public.pump_vehicles_ref(pump_vehicles,vehicles)

-- DROP FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles);

CREATE OR REPLACE FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',coalesce($2.plate::text,'')||' '||coalesce($2.make::text,'')||' '||coalesce($2.owner::text,''),		
		'dataType','pump_vehicles'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles) OWNER TO beton;

