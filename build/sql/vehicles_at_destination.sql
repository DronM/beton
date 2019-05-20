-- Function: vehicles_at_destination(timestamp without time zone, timestamp without time zone, integer, integer, interval, integer)

-- DROP FUNCTION vehicles_at_destination(timestamp without time zone, timestamp without time zone, integer, integer, interval, integer);

CREATE OR REPLACE FUNCTION vehicles_at_destination(
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone,
    IN in_destination_id integer,
    IN in_vehicle_id integer,
    IN in_stop_dur interval,
    IN in_vehicle_owner_id integer
    )
  RETURNS TABLE(
  	vehicle_id integer,
  	plate text,
  	driver_name text,
  	date_time text,
  	stop_dur text
  ) AS
$BODY$
		WITH dest_zone AS
		(select zone from destinations WHERE id=in_destination_id)
		SELECT
			v.id AS vehicle_id,
			v.plate::text AS plate,
			d.name::text AS driver_name,
			date8_time5_descr(tr.period+age(now(),now() at time zone 'UTC'))::text AS date_time,
			((SELECT tr2.period FROM car_tracking AS tr2 WHERE tr2.car_id=tr.car_id AND tr2.period>tr.period AND tr2.speed>0 LIMIT 1)-tr.period)::text AS stop_dur
		FROM car_tracking AS tr
		LEFT JOIN vehicles AS v ON v.tracker_id=tr.car_id
		LEFT JOIN vehicle_schedules AS vs ON vs.vehicle_id=v.id AND vs.schedule_date=(tr.period+age(now(),now() at time zone 'UTC'))::date
		LEFT JOIN drivers AS d ON d.id=vs.driver_id
		WHERE tr.period+age(now(),now() at time zone 'UTC') BETWEEN in_date_time_from AND in_date_time_to
		AND (in_vehicle_id=0 OR (in_vehicle_id>0 AND in_vehicle_id=v.id))
		AND (in_vehicle_owner_id=0 OR in_vehicle_owner_id=v.vehicle_owner_id)
		AND st_contains(
			(SELECT zone FROM dest_zone),
			ST_GeomFromText('POINT('||tr.lon::text||' '||tr.lat::text||')', -1)
			)
		AND tr.speed=0
		AND (SELECT (tr2.period-tr.period)>=in_stop_dur FROM car_tracking AS tr2 WHERE tr2.car_id=tr.car_id AND tr2.period>tr.period AND tr2.speed>0 LIMIT 1)
		AND (SELECT tr3.speed>0 FROM car_tracking AS tr3 WHERE tr3.car_id=tr.car_id AND tr3.period<tr.period ORDER BY tr3.period DESC LIMIT 1)
		ORDER BY v.plate,tr.period;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION vehicles_at_destination(timestamp without time zone, timestamp without time zone, integer, integer, interval, integer)
  OWNER TO beton;

