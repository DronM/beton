-- Function: get_shift_start(timestamp without time zone)

-- DROP FUNCTION get_shift_start(timestamp without time zone);

CREATE OR REPLACE FUNCTION get_shift_start(timestamp without time zone)
  RETURNS timestamp without time zone AS
$BODY$
DECLARE
	shift_start_date date;
	shift_start_time time;
BEGIN
	shift_start_time = constant_first_shift_start_time();

	IF $1::time<shift_start_time THEN
		shift_start_date = $1::date - 1;
	ELSE
		shift_start_date = $1::date;
	END IF;
	
	RETURN shift_start_date + shift_start_time;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION get_shift_start(timestamp without time zone)
  OWNER TO beton;

