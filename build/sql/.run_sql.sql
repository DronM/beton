CREATE OR REPLACE VIEW public.vehicle_states_all AS 
	SELECT 
		st.date_time,
		vs.id,
		CASE
		    WHEN st.state <> 'out'::vehicle_states AND st.state <> 'out_from_shift'::vehicle_states AND st.state <> 'shift'::vehicle_states AND st.state <> 'shift_added'::vehicle_states 

			THEN 1
			ELSE 0
		END AS vehicles_count,
		
		vehicles_ref(v) AS vehicles_ref,
		
		CASE
			WHEN v.vehicle_owner_id IS NULL THEN v.owner
			ELSE v_own.name
		END AS owner,
		
		drivers_ref(d) AS drivers_ref,
		d.phone_cel::text AS driver_phone_cel,
		
		st.state, 

		CASE 
			--WHEN st.state = 'busy'::vehicle_states AND (st.date_time + (coalesce(dest.time_route,'00:00'::time)*2+constant_vehicle_unload_time())::interval)::timestamp with time zone < CURRENT_TIMESTAMP
				--THEN true
			WHEN st.state = 'busy'::vehicle_states AND (st.date_time + coalesce(dest.time_route::interval,'00:00'::interval))::timestamp with time zone < CURRENT_TIMESTAMP
				THEN true
			
			WHEN st.state = 'left_for_base'::vehicle_states AND (st.date_time +  coalesce(dest.time_route,'00:00'::time)::interval)::timestamp with time zone < CURRENT_TIMESTAMP
				THEN true
			ELSE false
		END AS is_late,

		CASE
			WHEN st.state = 'at_dest'::vehicle_states AND (st.date_time + (coalesce(dest.time_route,'00:00'::time)*1 + constant_vehicle_unload_time())::interval)::timestamp with time zone < CURRENT_TIMESTAMP
				THEN true
			ELSE false
		END AS is_late_at_dest,
		
		CASE
			--shift - no inf
			WHEN st.state = 'shift'::vehicle_states OR st.state = 'shift_added'::vehicle_states
				THEN ''

			-- out_from_shift && out inf=out time
			WHEN st.state = 'out_from_shift'::vehicle_states OR st.state = 'out'::vehicle_states
				THEN time5_descr(st.date_time::time)::text

			--free && assigned inf= time elapsed
			WHEN st.state = 'free'::vehicle_states OR st.state = 'assigned'::vehicle_states
				THEN to_char(CURRENT_TIMESTAMP-st.date_time,'HH24:MI')

			--busy && late inf = -
			--WHEN st.state = 'busy'::vehicle_states AND (st.date_time + (coalesce(dest.time_route,'00:00'::time)*2+constant_vehicle_unload_time())::interval )::timestamp with time zone < CURRENT_TIMESTAMP
				--THEN '-'::text || time5_descr((CURRENT_TIMESTAMP - (st.date_time + (coalesce(dest.time_route,'00:00'::time)*2+constant_vehicle_unload_time())::interval)::timestamp with time zone)::time without time zone)::text
			WHEN st.state = 'busy'::vehicle_states AND (st.date_time + coalesce(dest.time_route,'00:00'::time)+constant_vehicle_unload_time()::interval )::timestamp with time zone < CURRENT_TIMESTAMP
				THEN time5_descr((coalesce(dest.time_route,'00:00'::time)+constant_vehicle_unload_time()::interval )::time without time zone)::text
				
			-- busy not late
			WHEN st.state = 'busy'::vehicle_states
				--THEN time5_descr(((st.date_time + (coalesce(dest.time_route,'00:00'::time)*2+constant_vehicle_unload_time())::interval)::timestamp with time zone - CURRENT_TIMESTAMP)::time without time zone)::text
				THEN time5_descr((coalesce(dest.time_route,'00:00'::time)+constant_vehicle_unload_time()::interval )::time without time zone)::text

			--at dest && late inf=route_time
			WHEN st.state = 'at_dest'::vehicle_states AND (st.date_time + (coalesce(dest.time_route,'00:00'::time)*1+constant_vehicle_unload_time())::interval )::timestamp with time zone < CURRENT_TIMESTAMP
				THEN time5_descr(coalesce(dest.time_route,'00:00'::time))::text

			--at dest NOT late
			WHEN st.state = 'at_dest'::vehicle_states
				THEN time5_descr( ((st.date_time + (coalesce(dest.time_route::interval,'00:00'::interval)+constant_vehicle_unload_time()::interval))::timestamp with time zone - CURRENT_TIMESTAMP)::time without time zone)::text

			--left_for_base && LATE
			WHEN st.state = 'left_for_base'::vehicle_states AND (st.date_time + coalesce(dest.time_route,'00:00'::time)::interval )::timestamp with time zone < CURRENT_TIMESTAMP
				THEN '-'::text || time5_descr((CURRENT_TIMESTAMP - (st.date_time + coalesce(dest.time_route,'00:00'::time)::interval)::timestamp with time zone)::time without time zone)::text

			--left_for_base NOT late
			WHEN st.state = 'left_for_base'::vehicle_states
				THEN time5_descr( ((st.date_time + coalesce(dest.time_route,'00:00'::time)::interval)::timestamp with time zone - CURRENT_TIMESTAMP)::time without time zone)::text
		    
			ELSE ''
		    
		END AS inf_on_return, 
		
		v.load_capacity,
		(SELECT COUNT(*)
		FROM shipments
		WHERE (shipments.vehicle_schedule_id = vs.id AND shipments.shipped)
		) AS runs,

		(SELECT 
			(now()-(tr.period+AGE(now(),now() AT TIME ZONE 'UTC')) )>constant_no_tracker_signal_warn_interval()
			FROM car_tracking AS tr
			WHERE tr.car_id=v.tracker_id
			ORDER BY tr.period DESC LIMIT 1
		) AS tracker_no_data,
		
		(v.tracker_id IS NULL OR v.tracker_id='') AS no_tracker,
		
		vs.schedule_date,
		
		vehicle_schedules_ref(vs,v,d) AS vehicle_schedules_ref
		
	FROM vehicle_schedules vs
	
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	
	
	LEFT JOIN vehicle_schedule_states st ON
		st.id = (SELECT vehicle_schedule_states.id 
			FROM vehicle_schedule_states
			WHERE vehicle_schedule_states.schedule_id = vs.id
			ORDER BY vehicle_schedule_states.date_time DESC NULLS LAST
			LIMIT 1
		)
	
	LEFT JOIN shipments AS sh ON sh.id=st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id		
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owners AS v_own ON v_own.id=v.vehicle_owner_id
	;		
	--WHERE vs.schedule_date=in_date


ALTER TABLE public.vehicle_states_all OWNER TO beton;

