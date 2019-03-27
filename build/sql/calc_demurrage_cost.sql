-- Function: public.calc_demurrage_cost(interval)

-- DROP FUNCTION public.calc_demurrage_cost(interval);

CREATE OR REPLACE FUNCTION public.calc_demurrage_cost(in_demurrage_time interval)
  RETURNS numeric AS
$BODY$
	SELECT 
		CASE
			WHEN in_demurrage_time>'00:00' THEN
				round( (EXTRACT(EPOCH FROM GREATEST(in_demurrage_time,constant_min_demurrage_time()))::numeric
					* const_demurrage_coast_per_hour_val()::numeric / 3600::numeric
					)/100
				)*100
			ELSE 0
		END;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.calc_demurrage_cost(interval)
  OWNER TO beton;

