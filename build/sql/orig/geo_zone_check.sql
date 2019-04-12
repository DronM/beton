-- Function: geo_zone_check()

-- DROP FUNCTION geo_zone_check();

CREATE OR REPLACE FUNCTION geo_zone_check()
  RETURNS trigger AS
$BODY$
DECLARE
	v_tracker_date date;
	v_cur_state vehicle_states;
	v_shipment_id int;
	v_schedule_id int;
	v_destination_id int;
	v_zone geometry;
	
	v_lon_min float;
	v_lon_max float;
	v_lat_min float;
	v_lat_max float;
	
	v_car_rec RECORD;	
	v_true_point boolean;
	v_control_in boolean;
	v_new_state vehicle_states;
	v_point_in_zone boolean;

	V_SRID int;
BEGIN
	--RETURN NEW;
	V_SRID = 0;
	SELECT d1::date INTO v_tracker_date FROM get_shift_bounds(NEW.recieved_dt+age(now(), now() at time zone 'UTC')) AS (d1 timestamp,d2 timestamp);

	--get last state
	SELECT st.state,st.shipment_id,st.schedule_id,st.destination_id INTO v_cur_state,v_shipment_id,v_schedule_id,v_destination_id
	FROM vehicle_schedule_states AS st
	WHERE st.tracker_id=NEW.car_id AND st.date_time::date = v_tracker_date
	ORDER BY st.date_time DESC LIMIT 1;

	--controled states only
	IF (v_cur_state='busy'::vehicle_states)
	OR (v_cur_state='at_dest'::vehicle_states)
	OR (v_cur_state='left_for_base'::vehicle_states)
	THEN
		-- direction to controle
		IF (v_cur_state='busy'::vehicle_states)
		OR (v_cur_state='left_for_base'::vehicle_states) THEN
			v_control_in = true;
		ELSE
			v_control_in = false;--controling out
		END IF;
		
		--coords to control
		IF (v_cur_state='busy'::vehicle_states) THEN
			--clients zone on shipment
			SELECT destinations.id,
				destinations.lon_min, destinations.lon_max,
				destinations.lat_min, destinations.lat_max,
				destinations.zone
			INTO v_destination_id,v_lon_min,v_lon_max,v_lat_min,v_lat_max,v_zone
			FROM shipments
			LEFT JOIN orders ON orders.id=shipments.order_id
			LEFT JOIN destinations ON destinations.id=orders.destination_id
			WHERE shipments.id = v_shipment_id;

		ELSE
			-- base zone OR clients zone from state
			SELECT destinations.lon_min, destinations.lon_max,
				destinations.lat_min, destinations.lat_max,
				destinations.zone
			INTO v_lon_min,v_lon_max,v_lat_min,v_lat_max,v_zone
			FROM destinations
			WHERE destinations.id =
				CASE v_cur_state
					WHEN 'at_dest'::vehicle_states THEN v_destination_id
					ELSE constant_base_geo_zone_id()
				END;
		END IF;		

		
		--v_point_in_zone = (NEW.lon>=v_lon_min) AND (NEW.lon<=v_lon_max) AND (NEW.lat>=v_lat_min) AND (NEW.lat<=v_lat_max);
		--4326
		v_point_in_zone = st_contains(v_zone, ST_GeomFromText('POINT('||NEW.lon::text||' '||NEW.lat::text||')', V_SRID));
		
		IF (v_control_in AND v_point_in_zone)
		OR (v_control_in=false AND v_point_in_zone=false) THEN
			v_true_point = true;
		ELSE
			v_true_point = false;
		END IF;
		IF v_true_point THEN
			--check last X points to be sure
			v_true_point = false;
			FOR v_car_rec IN SELECT lon,lat FROM car_tracking AS t
					WHERE t.car_id = NEW.car_id
					ORDER BY t.period DESC
					LIMIT constant_geo_zone_check_points_count()-1 OFFSET 1
			LOOP	
				--RAISE EXCEPTION 'v_lon_min=%,v_lon_max=%,v_lat_min=%,v_lat_max=%',v_lon_min,v_lon_max,v_lat_min,v_lat_max;
				--RAISE EXCEPTION 'v_car_rec.lon=%,v_car_rec.lat=%',v_car_rec.lon,v_car_rec.lat;
				
				--v_point_in_zone = (v_car_rec.lon>=v_lon_min) AND (v_car_rec.lon<=v_lon_max) AND (v_car_rec.lat>=v_lat_min) AND (v_car_rec.lat<=v_lat_max);
				--4326
				v_point_in_zone = st_contains(v_zone, ST_GeomFromText('POINT('||v_car_rec.lon::text||' '||v_car_rec.lat::text||')', V_SRID));
				
				v_true_point = (v_control_in AND v_point_in_zone)
					OR (v_control_in=false AND v_point_in_zone=false);
				--RAISE EXCEPTION 'v_point_in_zone=%',v_point_in_zone;
				IF v_true_point = false THEN
					EXIT;
				END IF;
			END LOOP;

			IF v_true_point THEN
				--current position is inside/outside zone
				IF (v_cur_state='busy'::vehicle_states) THEN
					v_new_state = 'at_dest'::vehicle_states;
				ELSEIF (v_cur_state='at_dest'::vehicle_states) THEN
					v_new_state = 'left_for_base'::vehicle_states;
				ELSEIF (v_cur_state='left_for_base'::vehicle_states) THEN
					v_new_state = 'free'::vehicle_states;			
				END IF;

				--change position
				INSERT INTO vehicle_schedule_states (date_time, schedule_id, state, tracker_id,destination_id,shipment_id)
				VALUES (CURRENT_TIMESTAMP,v_schedule_id,v_new_state,NEW.car_id,v_destination_id,v_shipment_id);
			END IF;
		END IF;
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION geo_zone_check()
  OWNER TO beton;

