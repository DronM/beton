-- Function: public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)

-- DROP FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval);

--Функция Устарела, использовать vehicles_get_track

CREATE OR REPLACE FUNCTION public.vehicle_track_with_stops(
    IN in_vehicle_id integer,
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone,
    IN stop_dur_interval interval)
  RETURNS TABLE(vehicle_id integer, plate text, period timestamp without time zone, period_str text, lon_str text, lat_str text, speed numeric, ns character, ew character, recieved_dt timestamp without time zone, recieved_dt_str text, odometer integer, engine_on_str text, voltage numeric, heading numeric, heading_str text, lon double precision, lat double precision) AS
$BODY$
DECLARE tr_stops_row RECORD;
	tr_stops_curs refcursor;
	v_stop_started boolean;
	v_date_time_from timestamp without time zone;
	v_date_time_to timestamp without time zone;
BEGIN
	v_date_time_from = in_date_time_from - age(now(),now() at time zone 'UTC');
	v_date_time_to = in_date_time_to - age(now(),now() at time zone 'UTC');
	
	OPEN tr_stops_curs SCROLL FOR
		SELECT 
			vehicles.id AS vehicle_id,
			vehicles.plate::text AS plate,
			tr.period+age(now(),now() at time zone 'UTC') AS period,
			date5_time5_descr(tr.period+age(now(),now() at time zone 'UTC'))::text AS period_str,
			tr.longitude::text As lon_str,
			tr.latitude::text AS lat_str,
			round(tr.speed,0)::numeric AS speed,
			tr.ns,
			tr.ew,
			tr.recieved_dt+age(now(),now() at time zone 'UTC') AS recieved_dt,
			date5_time5_descr(tr.recieved_dt+age(now(),now() at time zone 'UTC'))::text AS recieved_dt_str,
			tr.odometer,
			engine_descr(tr.engine_on)::text AS engine_on_str,
			tr.voltage,
			tr.heading,
			heading_descr(tr.heading)::text AS heading_str,
			tr.lon,
			tr.lat
		FROM car_tracking AS tr
		LEFT JOIN vehicles ON vehicles.tracker_id=tr.car_id
		--WHERE tr.period+age(now(),now() at time zone 'UTC') BETWEEN in_date_time_from AND in_date_time_to
		WHERE tr.period BETWEEN v_date_time_from AND v_date_time_to
		AND vehicles.id=in_vehicle_id
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
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
			RETURN NEXT;
		ELSIF NOT v_stop_started AND tr_stops_row.speed=0 THEN	
			--new stop - check duration
			v_stop_started = true;
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
		ELSIF v_stop_started AND tr_stops_row.speed>0 THEN	
			--end of stop
			v_stop_started = false;
			
			IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
				RETURN NEXT;
			END IF;
		END IF;
	END LOOP;

	IF v_stop_started THEN	
		--end of stop or end of period
		IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
			RETURN NEXT;
		END IF;
	END IF;

	CLOSE tr_stops_curs;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)
  OWNER TO beton;

