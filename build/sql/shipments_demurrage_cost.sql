-- Function: public.shipments_demurrage_cost(interval)

-- DROP FUNCTION public.shipments_demurrage_cost(interval);

CREATE OR REPLACE FUNCTION public.shipments_demurrage_cost(in_demurrage_time interval)
  RETURNS numeric AS
$BODY$
	SELECT 
		CASE
			WHEN in_demurrage_time>'00:00' THEN
				/*
				round( (EXTRACT(EPOCH FROM GREATEST(in_demurrage_time,constant_min_demurrage_time()))::numeric
					* const_demurrage_coast_per_hour_val()::numeric / 3600::numeric
					)/100
				)*100
				*/
				((
					extract(hour FROM in_demurrage_time) + 
					round( extract(minute FROM in_demurrage_time)::numeric/60,1)
				) * const_demurrage_coast_per_hour_val()
				)::numeric			
			ELSE 0
		END;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.shipments_demurrage_cost(interval)
  OWNER TO beton;

