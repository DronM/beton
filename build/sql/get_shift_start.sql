-- Function: get_shift_start(timestamp without time zone)

-- DROP FUNCTION get_shift_start(timestamp without time zone);

CREATE OR REPLACE FUNCTION get_shift_start(in_date_time timestamp without time zone)
  RETURNS timestamp without time zone AS
$BODY$
	SELECT
		CASE
			WHEN in_date_time::time<const_first_shift_start_time_val() THEN (in_date_time::date - 1)+const_first_shift_start_time_val()
			ELSE in_date_time::date+const_first_shift_start_time_val()
		END
	;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION get_shift_start(timestamp without time zone)
  OWNER TO beton;

