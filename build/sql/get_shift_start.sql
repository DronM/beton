-- Function: get_shift_start(timestamp without time zone)

-- DROP FUNCTION get_shift_start(timestamp without time zone);

CREATE OR REPLACE FUNCTION get_shift_start(in_date_time timestamp without time zone)
  RETURNS timestamp without time zone AS
$BODY$
	SELECT
		CASE
			--const_first_shift_start_time_val()
			--(const_first_shift_start_time_val()::time without time zone)::interval
			WHEN in_date_time::time without time zone<const_first_shift_start_time_val()::time without time zone THEN
				(in_date_time::date - '1 day'::interval)+(const_first_shift_start_time_val()::time without time zone)::interval
			ELSE in_date_time::date+(const_first_shift_start_time_val()::time without time zone)::interval
		END
	;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION get_shift_start(timestamp without time zone)
  OWNER TO beton;

