-- Function: public.pump_prices_ref(pump_prices)

-- DROP FUNCTION public.pump_prices_ref(pump_prices);

CREATE OR REPLACE FUNCTION public.pump_prices_ref(pump_prices)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,		
		'dataType','pump_prices'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.pump_prices_ref(pump_prices) OWNER TO beton;

