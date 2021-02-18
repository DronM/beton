-- View: public.vehicles_last_pos

-- DROP VIEW public.vehicles_last_pos;

CREATE OR REPLACE VIEW public.vehicles_last_pos
AS
SELECT
	v.id
	,v.plate
	,v.feature
	,v.owner
	,v.make
	,v.tracker_id::text AS tracker_id
	,(SELECT
		json_build_object(
			'period',car_tracking.period + age(now(), timezone('UTC'::text, now())::timestamp with time zone)
			,'speed',round(car_tracking.speed, 0)
			,'ns',car_tracking.ns
			,'ew',car_tracking.ew
			,'recieved_dt',car_tracking.recieved_dt + age(now(), timezone('UTC'::text, now())::timestamp with time zone)
			,'odometer',car_tracking.odometer
			,'voltage',round(car_tracking.voltage,0)
			,'heading',car_tracking.heading
			,'lon',car_tracking.lon
			,'lat',car_tracking.lat			
			/*
			,'heading_descr',heading_descr(car_tracking.heading)
			,'pt_geom',ST_BUFFER(
				ST_GeomFromText('POINT('||car_tracking.lon::text||' '||car_tracking.lat::text||')', 4326)
				,(SELECT (const_deviation_for_reroute_val()->>'distance_m')::int)
			)
			*/
		)
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1
	) AS pos_data
	
	/*
	( SELECT car_tracking.period + age(now(), timezone('UTC'::text, now())::timestamp with time zone)
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS period,
	( SELECT round(car_tracking.speed, 0) AS round
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS speed,
	( SELECT car_tracking.ns
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS ns,
	( SELECT car_tracking.ew
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS ew,
	( SELECT car_tracking.recieved_dt + age(now(), timezone('UTC'::text, now())::timestamp with time zone)
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS recieved_dt,
	( SELECT car_tracking.odometer
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS odometer,
	( SELECT car_tracking.voltage
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS voltage,
	( SELECT heading_descr(car_tracking.heading) AS heading_descr
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS heading_str,
	( SELECT car_tracking.heading
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS heading,
	( SELECT car_tracking.lon
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS lon,
	( SELECT car_tracking.lat
	FROM car_tracking
	WHERE car_tracking.car_id::text = v.tracker_id::text
	ORDER BY car_tracking.period DESC
	LIMIT 1) AS lat
	*/	
FROM vehicles v
WHERE v.tracker_id IS NOT NULL AND v.tracker_id::text <> ''::text
ORDER BY v.plate_n;

ALTER TABLE public.vehicles_last_pos OWNER TO beton;

