-- FUNCTION: public.bad_coord_check()

-- DROP FUNCTION public.bad_coord_check();

CREATE OR REPLACE FUNCTION public.bad_coord_check()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
BEGIN
	--gps_period+'7167 days 23:00:00'::interval

	--traservd compiled incorrecr time dif 6 hours!
	NEW.period = NEW.period - '1 hour'::interval;
	
	IF NEW.period - now() at time zone 'UTC'>='5 minutes'::interval THEN
		IF NEW.gps_valid=1 THEN
			NEW.gps_period = NEW.period;
			NEW.period = NEW.recieved_dt;
		ELSE
			--skeep bad record
			INSERT INTO car_tracking_skeeped VALUES (
				NEW.car_id,
				NEW.period,
				NEW.longitude,
				NEW.latitude,
				NEW.speed,
				NEW.ns,
				NEW.ew,
				NEW.magvar,
				NEW.heading,
				NEW.recieved_dt,
				NEW.gps_valid,
				NEW.from_memory,
				NEW.odometer,
				NEW.p1,
				NEW.p2,
				NEW.p3,
				NEW.p4,
				NEW.sensors_in,
				NEW.voltage,
				NEW.sensors_out,
				NEW.engine_on,
				NEW.lon,
				NEW.lat,
				NEW.gps_period					
			)
			ON CONFLICT (car_id,period) DO NOTHING;
			RETURN NULL;
		END IF;	
	ELSIF EXTRACT(YEAR FROM NEW.period::date)<='2001' THEN
		NEW.gps_period = NEW.period;
		NEW.period = NEW.period + '7168 days'::interval;

		IF NEW.period - now() at time zone 'UTC'>='5 minutes'::interval THEN
			INSERT INTO car_tracking_skeeped VALUES (
				NEW.car_id,
				NEW.period,
				NEW.longitude,
				NEW.latitude,
				NEW.speed,
				NEW.ns,
				NEW.ew,
				NEW.magvar,
				NEW.heading,
				NEW.recieved_dt,
				NEW.gps_valid,
				NEW.from_memory,
				NEW.odometer,
				NEW.p1,
				NEW.p2,
				NEW.p3,
				NEW.p4,
				NEW.sensors_in,
				NEW.voltage,
				NEW.sensors_out,
				NEW.engine_on,
				NEW.lon,
				NEW.lat,
				NEW.gps_period					
			)
			ON CONFLICT (car_id,period) DO NOTHING;
			RETURN NULL;--SKEEP
		END IF;
		
		-- '7167 days 23:00:00'::interval;
		--NEW.recieved_dt;
	END IF;
	
	--Проверить скорость по расстоянию ТОЛЬКО если время между точками минимальное, меньше 1 минуты?
	/*
	IF
	(WITH
	prev_d AS (
		SELECT
			period,lon,lat
		FROM car_tracking
		WHERE car_id=NEW.car_id
		ORDER BY period DESC
		LIMIT 1
	)
	SELECT
		CASE
			WHEN
				(SELECT period FROM prev_d) IS NULL
				OR NEW.period - (SELECT period FROM prev_d) > '1 minute'::interval
			THEN TRUE
			ELSE
			((
				st_distance_sphere(
					st_makepoint(NEW.lon,NEW.lat),--new lon/lat
					st_makepoint((SELECT lon FROM prev_d),(SELECT lat FROM prev_d))--prev
				)
				/
				(NEW.period - (SELECT period FROM prev_d))
			)<80)
		END			
	) = FALSE THEN
		--Скорость в течении минуты > 80 м/с > 288км/ч
		INSERT INTO car_tracking_skeeped VALUES (
			NEW.car_id,
			NEW.period,
			NEW.longitude,
			NEW.latitude,
			NEW.speed,
			NEW.ns,
			NEW.ew,
			NEW.magvar,
			NEW.heading,
			NEW.recieved_dt,
			NEW.gps_valid,
			NEW.from_memory,
			NEW.odometer,
			NEW.p1,
			NEW.p2,
			NEW.p3,
			NEW.p4,
			NEW.sensors_in,
			NEW.voltage,
			NEW.sensors_out,
			NEW.engine_on,
			NEW.lon,
			NEW.lat,
			NEW.gps_period					
		);
	
		RETURN NULL;--SKEEP
	END IF;	
	*/
	
	RETURN NEW;
	
END;
$BODY$;

ALTER FUNCTION public.bad_coord_check()
    OWNER TO beton;

