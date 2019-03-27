-- Function: available_spots_for_order_dif_speed(date, numeric, numeric)

-- DROP FUNCTION available_spots_for_order_dif_speed(date, numeric, numeric);

CREATE OR REPLACE FUNCTION available_spots_for_order_dif_speed(
    IN in_date date,
    IN in_quant numeric,
    IN in_speed_per_hour numeric)
  RETURNS TABLE(avail_date_time timestamp without time zone, avail_time_descr text, avail_speed numeric) AS
$BODY$
DECLARE
	speed_tolerance int;
	i int;
BEGIN
	CREATE TEMP TABLE res_table
	(date_time timestamp without time zone, speed numeric ,CONSTRAINT res_table_pkey PRIMARY KEY (date_time))
	ON COMMIT DROP;

	--ini speed
	INSERT INTO res_table (SELECT av_spots.avail_date_time, in_speed_per_hour FROM available_spots_for_order(in_date, in_quant, in_speed_per_hour) AS av_spots);
	DROP TABLE shift_orders_with_spread_quant;

	speed_tolerance = round(in_speed_per_hour * constant_speed_change_for_order_autolocate() /100::numeric);

	--less
	FOR i IN 1..speed_tolerance LOOP
		BEGIN
			INSERT INTO res_table (SELECT av_spots.avail_date_time, in_speed_per_hour-i FROM available_spots_for_order(in_date, in_quant, in_speed_per_hour-i) AS av_spots);
		EXCEPTION WHEN unique_violation THEN
			-- Ignore duplicate inserts.
		END;		
	END LOOP;

	--more
	FOR i IN 1..speed_tolerance LOOP
		BEGIN
			INSERT INTO res_table (SELECT av_spots.avail_date_time, in_speed_per_hour+i FROM available_spots_for_order(in_date, in_quant, in_speed_per_hour+i) AS av_spots);
		EXCEPTION WHEN unique_violation THEN
			-- Ignore duplicate inserts.
		END;					
	END LOOP;

	RETURN QUERY
		SELECT res_table.date_time AS avail_date_time,
		time5_descr(res_table.date_time::time)::text AS avail_time_descr,
		res_table.speed AS avail_speed
		FROM res_table ORDER BY avail_speed;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION available_spots_for_order_dif_speed(date, numeric, numeric)
  OWNER TO beton;

