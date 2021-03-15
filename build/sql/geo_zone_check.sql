-- Function: geo_zone_check()

-- DROP FUNCTION geo_zone_check();
/**
 */
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

	v_route_geom geometry;
	v_veh_on_route bool;

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
					WHERE t.car_id = NEW.car_id AND t.gps_valid=1
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
	
	--*** КОНТРОЛЬ ЗАПРЕЩЕННЫХ ЗОН!!! ****
	INSERT INTO sms_for_sending
		(tel, body, sms_type,event_key)
	(WITH
	zone_viol AS (
		SELECT
			string_agg(sms_text.body,',') AS body
		FROM
		(
		SELECT
			sms_templates_text(
				ARRAY[
					ROW('plate',(SELECT plate::text FROM vehicles WHERE tracker_id=NEW.car_id))::template_value,
					ROW('zone',dest.name::text)::template_value,
					ROW('date_time',to_char(now(),'DD/MM/YY HH24:MI'))::template_value
				],
				(SELECT pattern FROM sms_patterns WHERE sms_type='vehicle_zone_violation')
			) AS body	
		FROM
		(	SELECT
				zone_contains.zone_id,
				bool_and(zone_contains.inside_zone) AS inside_zone
			FROM
			(SELECT
				destinations.id AS zone_id,
				st_contains(
					destinations.zone,
					ST_GeomFromText('POINT('||last_pos.lon::text||' '||last_pos.lat::text||')', 0)
				) AS inside_zone
		
			FROM tracker_zone_controls
			LEFT JOIN destinations ON destinations.id=tracker_zone_controls.destination_id
			CROSS JOIN (
				SELECT
					tr.lon,tr.lat
				FROM car_tracking AS tr
				WHERE tr.car_id = NEW.car_id AND tr.gps_valid=1 --16/09/20!!!
				--(SELECT tracker_id FROM vehicles WHERE plate='864')
				ORDER BY tr.period DESC
				LIMIT const_geo_zone_check_points_count_val()	
			) AS last_pos
			) AS zone_contains	
			GROUP BY zone_contains.zone_id
		) AS zone_check	
		LEFT JOIN destinations AS dest ON dest.id=zone_check.zone_id
		WHERE zone_check.inside_zone
		) AS sms_text
		WHERE NOT exists (
			SELECT sms.id
			FROM sms_for_sending sms
			WHERE sms.event_key=NEW.car_id
				AND (now()::timestamp-sms.date_time)<=const_zone_violation_alarm_interval_val()
				AND sms.sms_type='vehicle_zone_violation'
			)
	)
	SELECT 
		us.phone_cel,
		(SELECT zone_viol.body FROM zone_viol) AS body,
		'vehicle_zone_violation',
		NEW.car_id

	FROM sms_pattern_user_phones AS u
	LEFT JOIN sms_patterns AS p ON p.id=u.sms_pattern_id
	LEFT JOIN users AS us ON us.id=u.user_id
	WHERE p.sms_type='vehicle_zone_violation' AND (SELECT zone_viol.body FROM zone_viol) IS NOT NULL
	);

	IF NEW.gps_valid = 1 THEN
	
		IF v_shipment_id IS NOT NULL
		AND ( (v_cur_state='left_for_dest'::vehicle_states)
			OR (v_cur_state='left_for_base'::vehicle_states)
			OR (v_cur_state='busy'::vehicle_states)
		) THEN
			SELECT
				CASE
					WHEN route->'routes' IS NOT NULL AND jsonb_array_length(route->'routes')>=1
					THEN ST_LineFromEncodedPolyline(route->'routes'->0->>'geometry')
					ELSE NULL
				END AS route_geom
			INTO
				v_route_geom
			FROM vehicle_route_cashe AS t
			WHERE
				t.shipment_id = v_shipment_id
				AND t.vehicle_state = v_cur_state
				AND t.tracker_id = NEW.car_id
			;
			
			IF v_route_geom IS NOT NULL THEN
				--route exists, check if rebuild is needed
				SELECT
					bool_and(sub.pt_on_route) AS veh_on_route
				INTO v_veh_on_route
				FROM (
					SELECT 
						st_contains(
							v_route_geom
							,ST_Buffer(
								ST_GeomFromText('POINT('||tr.lon::text||' '||tr.lat::text||')', 4326)
								,(SELECT (const_deviation_for_reroute_val()->>'distance_m')::int)
							)
						) AS pt_on_route
					FROM car_tracking AS tr
					WHERE tr.car_id = NEW.car_id AND tr.gps_valid = 1
					ORDER BY tr.period DESC
					LIMIT (const_deviation_for_reroute_val()->>'points_cnt')::int
				) AS sub;
				
				IF v_veh_on_route = FALSE THEN
					--rebuild!
					PERFORM pg_notify(
						'Vehicle.rebuild_route'
						,json_build_object(
							'params',json_build_object(								
								'tracker_id',NEW.car_id
								,'shipment_id',v_shipment_id
								,'vehicle_state', v_cur_state
							)
						)::text
					);					
				END IF;
				
			END IF;
		END IF;
			
		--returns vehicles_last_pos struc
		PERFORM pg_notify(
			'Vehicle.position.'||NEW.car_id
			,json_build_object(
				'params',json_build_object(
					'tracker_id',NEW.car_id
					,'lon',NEW.lon
					,'lat',NEW.lat
					,'heading',NEW.heading
					,'speed',NEW.speed
					,'period',NEW.period+age(now(), timezone('UTC'::text, now())::timestamp with time zone)
					,'ns',NEW.ns
					,'ew',NEW.ew
					,'recieved_dt',NEW.recieved_dt + age(now(), timezone('UTC'::text, now())::timestamp with time zone)
					,'odometer',NEW.odometer::text
					,'voltage',round(NEW.voltage,0)					
				)
			)::text
		);
	END IF;
		
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION geo_zone_check()
  OWNER TO beton;

