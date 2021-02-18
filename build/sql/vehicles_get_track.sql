-- Function: public.vehicles_get_track(integer, timestamp without time zone, timestamp without time zone, interval)

-- DROP FUNCTION public.vehicles_get_track(integer, timestamp without time zone, timestamp without time zone, interval);

-- ИСПОЛЬЗОВАТЬ данную функцию вместо vehicles_get_track
-- т.к. она возвращает структуру с pos_data

CREATE OR REPLACE FUNCTION public.vehicles_get_track(
    IN in_vehicle_id integer,
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone,
    IN stop_dur_interval interval)
  RETURNS TABLE(
  	id integer,
  	plate text,
  	feature text,
  	owner text,
  	make text,
  	tracker_id text,
  	pos_data json
  	/*
	  	period timestamp without time zone,
	  	speed numeric,
	  	ns character,
	  	ew character,
	  	recieved_dt timestamp without time zone,
	  	odometer integer,
	  	voltage numeric,
	  	heading numeric,
	  	lon double precision,
	  	lat double precision
	*/  	
	) AS
$BODY$
DECLARE
	tr_stops_row RECORD;
	tr_stops_curs refcursor;
	v_stop_started boolean;
	v_date_time_from timestamp without time zone;
	v_date_time_to timestamp without time zone;
	v_stop_started_period timestamp without time zone;
BEGIN
	v_date_time_from = in_date_time_from - age(now(),now() at time zone 'UTC');
	v_date_time_to = in_date_time_to - age(now(),now() at time zone 'UTC');
	
	OPEN tr_stops_curs SCROLL FOR
		SELECT 
			v.id AS id,
			v.plate::text AS plate,
			v.feature,
			v.owner,
			v.make,
			v.tracker_id::text AS tracker_id,
			round(tr.speed,0) AS speed,
			tr.period,
			json_build_object(
				'period',	tr.period+age(now(),now() at time zone 'UTC'),
				'speed',	round(tr.speed,0)::numeric,
				'ns',		tr.ns,
				'ew',		tr.ew,
				'recieved_dt',	tr.recieved_dt+age(now(),now() at time zone 'UTC'),
				'odometer',	tr.odometer,
				'voltage',	tr.voltage,
				'heading',	tr.heading,
				'lon',		tr.lon,
				'lat',		tr.lat
			) AS pos_data
		FROM car_tracking AS tr
		LEFT JOIN vehicles as v ON v.tracker_id=tr.car_id
		--WHERE tr.period+age(now(),now() at time zone 'UTC') BETWEEN in_date_time_from AND in_date_time_to
		WHERE tr.period BETWEEN v_date_time_from AND v_date_time_to
		AND v.id=in_vehicle_id
		AND tr.gps_valid=1;

	v_stop_started = false;
	LOOP
		FETCH NEXT FROM tr_stops_curs INTO tr_stops_row;
		IF  FOUND=false THEN
			--no more rows
			EXIT;
		END IF;

		IF NOT v_stop_started AND tr_stops_row.speed>0 THEN
			--move point
			id		= tr_stops_row.id;
			plate		= tr_stops_row.plate;
			feature		= tr_stops_row.feature;
			owner		= tr_stops_row.owner;
			make		= tr_stops_row.make;
			tracker_id	= tr_stops_row.tracker_id;
			pos_data	= tr_stops_row.pos_data;
			RETURN NEXT;
		ELSIF NOT v_stop_started AND tr_stops_row.speed=0 THEN	
			--new stop - check duration
			v_stop_started = true;
			v_stop_started_period = tr_stops_row.period;
			
			id		= tr_stops_row.id;
			plate		= tr_stops_row.plate;
			feature		= tr_stops_row.feature;
			owner		= tr_stops_row.owner;
			make		= tr_stops_row.make;
			tracker_id	= tr_stops_row.tracker_id;
			pos_data	= tr_stops_row.pos_data;
			
		ELSIF v_stop_started AND tr_stops_row.speed>0 THEN	
			--end of stop
			v_stop_started = false;
			
			IF (tr_stops_row.period - v_stop_started_period)::interval>=stop_dur_interval THEN
				RETURN NEXT;
			END IF;
		END IF;
	END LOOP;

	IF v_stop_started THEN	
		--end of stop or end of period
		IF (tr_stops_row.period - v_stop_started_period)::interval>=stop_dur_interval THEN
			RETURN NEXT;
		END IF;
	END IF;

	CLOSE tr_stops_curs;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.vehicles_get_track(integer, timestamp without time zone, timestamp without time zone, interval)
  OWNER TO ;

