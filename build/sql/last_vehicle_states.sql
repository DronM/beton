-- Function: public.last_vehicle_states(date)

-- DROP FUNCTION public.last_vehicle_states(date);

CREATE OR REPLACE FUNCTION public.last_vehicle_states(IN in_date date)
  RETURNS TABLE(id integer, vehicle_count integer, vehicle_id integer, vehicle_descr text, owner text, driver_descr text, driver_phone_cel text, state_descr character varying, state vehicle_states, is_late boolean, is_late_at_dest boolean, inf_on_return text, load_capacity double precision, runs bigint, tracker_no_data boolean, no_tracker boolean) AS
$BODY$
	--*****************************
	WITH all_states AS (
			SELECT 
				st.date_time,
				vs.id,
				CASE
				    WHEN st.state <> 'out'::vehicle_states AND st.state <> 'out_from_shift'::vehicle_states AND st.state <> 'shift'::vehicle_states AND st.state <> 'shift_added'::vehicle_states 

THEN 1
				    ELSE 0
				END AS vehicles_count,
				v.id AS vehicle_id, 
				v.plate::text AS vehicle_descr, 
				get_short_str(v.owner::text,7) AS owner,
				get_short_str(d.name::text,7) AS driver_descr,
				d.phone_cel::text AS driver_phone_cel,
				get_vehicle_states_descr(st.state) AS state_descr, 
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
				(SELECT COUNT(*) FROM shipments
					WHERE (shipments.vehicle_schedule_id = vs.id AND shipments.shipped)
				) AS runs,

				(SELECT 
					(now()-(tr.period+AGE(now(),now() AT TIME ZONE 'UTC')) )>constant_no_tracker_signal_warn_interval()
					FROM car_tracking AS tr WHERE tr.car_id=v.tracker_id ORDER BY tr.period DESC LIMIT 1
				) AS tracker_no_data,
				
				(v.tracker_id IS NULL OR v.tracker_id='') AS no_tracker
				
			FROM vehicle_schedules vs
			
			LEFT JOIN drivers d ON d.id = vs.driver_id
			LEFT JOIN vehicles v ON v.id = vs.vehicle_id

			LEFT JOIN vehicle_schedule_states st ON
				st.id = (SELECT vehicle_schedule_states.id 
					FROM vehicle_schedule_states
					WHERE vehicle_schedule_states.schedule_id = vs.id
					ORDER BY vehicle_schedule_states.date_time DESC LIMIT 1
				)
			LEFT JOIN shipments AS sh ON sh.id=st.shipment_id
			LEFT JOIN orders AS o ON o.id=sh.order_id		
			LEFT JOIN destinations AS dest ON dest.id=o.destination_id
					
			WHERE vs.schedule_date=in_date
	)

	--assigned
	(SELECT 

all_states.id,all_states.vehicles_count,all_states.vehicle_id,all_states.vehicle_descr,all_states.owner,all_states.driver_descr,all_states.driver_phone_cel,all_states.state_descr,all_states.state,all_states.is_late,all_states.is_late_at_dest,all_states.inf_on_return,all_states.load_capacity,all_states.runs,all_states.tracker_no_data,all_states.no_tracker
	FROM all_states WHERE all_states.state='assigned'::vehicle_states
	ORDER BY CURRENT_TIMESTAMP-all_states.date_time DESC)

	UNION ALL

	--free
	(SELECT 

all_states.id,all_states.vehicles_count,all_states.vehicle_id,all_states.vehicle_descr,all_states.owner,all_states.driver_descr,all_states.driver_phone_cel,all_states.state_descr,all_states.state,all_states.is_late,all_states.is_late_at_dest,all_states.inf_on_return,all_states.load_capacity,all_states.runs,all_states.tracker_no_data,all_states.no_tracker
	FROM all_states WHERE all_states.state='free'::vehicle_states
	ORDER BY CURRENT_TIMESTAMP-all_states.date_time DESC)

	UNION ALL

	--late
	(SELECT 

all_states.id,all_states.vehicles_count,all_states.vehicle_id,all_states.vehicle_descr,all_states.owner,all_states.driver_descr,all_states.driver_phone_cel,all_states.state_descr,all_states.state,all_states.is_late,all_states.is_late_at_dest,all_states.inf_on_return,all_states.load_capacity,all_states.runs,all_states.tracker_no_data,all_states.no_tracker
	FROM all_states WHERE all_states.is_late
	ORDER BY CURRENT_TIMESTAMP-all_states.date_time DESC)


	UNION ALL

	--busy && at_dest(late/not late) && left_for_base
	(SELECT 

all_states.id,all_states.vehicles_count,all_states.vehicle_id,all_states.vehicle_descr,all_states.owner,all_states.driver_descr,all_states.driver_phone_cel,all_states.state_descr,all_states.state,all_states.is_late,all_states.is_late_at_dest,all_states.inf_on_return,all_states.load_capacity,all_states.runs,all_states.tracker_no_data,all_states.no_tracker
	FROM all_states WHERE (all_states.state='busy'::vehicle_states OR all_states.state='at_dest'::vehicle_states OR all_states.state='left_for_base'::vehicle_states) AND (NOT all_states.is_late)
	ORDER BY all_states.inf_on_return ASC)


	UNION ALL

	--shift && shift_added
	(SELECT 

all_states.id,all_states.vehicles_count,all_states.vehicle_id,all_states.vehicle_descr,all_states.owner,all_states.driver_descr,all_states.driver_phone_cel,all_states.state_descr,all_states.state,all_states.is_late,all_states.is_late_at_dest,all_states.inf_on_return,all_states.load_capacity,all_states.runs,all_states.tracker_no_data,all_states.no_tracker
	FROM all_states WHERE all_states.state='shift'::vehicle_states OR all_states.state='shift_added'::vehicle_states
	ORDER BY all_states.vehicle_descr)

	UNION ALL

	--out
	(SELECT 

all_states.id,all_states.vehicles_count,all_states.vehicle_id,all_states.vehicle_descr,all_states.owner,all_states.driver_descr,all_states.driver_phone_cel,all_states.state_descr,all_states.state,all_states.is_late,all_states.is_late_at_dest,all_states.inf_on_return,all_states.load_capacity,all_states.runs,all_states.tracker_no_data,all_states.no_tracker
	FROM all_states WHERE all_states.state='out_from_shift'::vehicle_states OR all_states.state='out'::vehicle_states ORDER BY all_states.inf_on_return);
	
	--*****************************
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.last_vehicle_states(date)
  OWNER TO beton;

