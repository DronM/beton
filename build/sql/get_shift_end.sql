-- Function: get_shift_end(timestamp without time zone)

-- DROP FUNCTION get_shift_end(timestamp without time zone);

CREATE OR REPLACE FUNCTION get_shift_end(timestamp without time zone)
  RETURNS timestamp without time zone AS
$BODY$
	SELECT $1 + const_shift_length_time_val() - '00:00:01'::time;
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION get_shift_end(timestamp without time zone)
  OWNER TO beton;

