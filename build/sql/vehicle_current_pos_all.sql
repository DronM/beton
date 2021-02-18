-- View: public.vehicle_current_pos_all

-- DROP VIEW public.vehicle_current_pos_all;

CREATE OR REPLACE VIEW public.vehicle_current_pos_all
 AS
 SELECT v.id,
    v.plate,
    v.feature,
    v.owner,
    v.make,
    ( SELECT car_tracking.period + age(now(), timezone('UTC'::text, now())::timestamp with time zone)
           FROM car_tracking
          WHERE car_tracking.car_id::text = v.tracker_id::text
          ORDER BY car_tracking.period DESC
         LIMIT 1) AS period,
    ( SELECT date5_time5_descr(car_tracking.period + age(now(), timezone('UTC'::text, now())::timestamp with time zone)) AS date5_time5_descr
           FROM car_tracking
          WHERE car_tracking.car_id::text = v.tracker_id::text
          ORDER BY car_tracking.period DESC
         LIMIT 1) AS period_str,
    ( SELECT car_tracking.longitude
           FROM car_tracking
          WHERE car_tracking.car_id::text = v.tracker_id::text
          ORDER BY car_tracking.period DESC
         LIMIT 1) AS lon_str,
    ( SELECT car_tracking.latitude
           FROM car_tracking
          WHERE car_tracking.car_id::text = v.tracker_id::text
          ORDER BY car_tracking.period DESC
         LIMIT 1) AS lat_str,
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
    ( SELECT date5_time5_descr(car_tracking.recieved_dt + age(now(), timezone('UTC'::text, now())::timestamp with time zone)) AS date5_time5_descr
           FROM car_tracking
          WHERE car_tracking.car_id::text = v.tracker_id::text
          ORDER BY car_tracking.period DESC
         LIMIT 1) AS recieved_dt_str,
    ( SELECT car_tracking.odometer
           FROM car_tracking
          WHERE car_tracking.car_id::text = v.tracker_id::text
          ORDER BY car_tracking.period DESC
         LIMIT 1) AS odometer,
    ( SELECT engine_descr(car_tracking.engine_on) AS engine_descr
           FROM car_tracking
          WHERE car_tracking.car_id::text = v.tracker_id::text
          ORDER BY car_tracking.period DESC
         LIMIT 1) AS engine_on_str,
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
     ,v.tracker_id::text AS tracker_id
   FROM vehicles v
  WHERE v.tracker_id IS NOT NULL AND v.tracker_id::text <> ''::text
  ORDER BY v.plate;

ALTER TABLE public.vehicle_current_pos_all OWNER TO beton;

