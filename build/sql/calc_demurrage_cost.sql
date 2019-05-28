-- Function: public.calc_demurrage_cost(interval)

-- DROP FUNCTION public.calc_demurrage_cost(interval);

CREATE OR REPLACE FUNCTION public.calc_demurrage_cost(in_demurrage_time interval)
  RETURNS numeric AS
$BODY$
	SELECT shipments_demurrage_cost(in_demurrage_time);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.calc_demurrage_cost(interval)
  OWNER TO beton;

