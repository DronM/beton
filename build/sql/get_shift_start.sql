-- Function: get_shift_start(timestamp without time zone)

-- DROP FUNCTION get_shift_start(timestamp without time zone);

CREATE OR REPLACE FUNCTION get_shift_start(in_date_time timestamp without time zone)
  RETURNS timestamp without time zone AS
$BODY$
	WITH
	first_shift_start AS (
		SELECT val::time without time zone AS v FROM public.const_first_shift_start_time LIMIT 1
	)
	SELECT
		CASE
			WHEN in_date_time::time without time zone<(SELECT v FROM first_shift_start) THEN
				(in_date_time::date - '1 day'::interval)+(SELECT v::interval FROM first_shift_start)
			ELSE in_date_time::date+(SELECT v::interval FROM first_shift_start)
		END
	;
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION get_shift_start(timestamp without time zone)
  OWNER TO beton;

