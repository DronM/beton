-- Function: public.vehicle_schedule_states_process()

-- DROP FUNCTION public.vehicle_schedule_states_process();

CREATE OR REPLACE FUNCTION public.vehicle_schedule_states_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_veh_at_work_count int;
	v_old_state vehicle_states;
	v_controled_states vehicle_states[];
	veh_count int;
	v_vehicle_feature vehicles.feature%TYPE;
	v_do_control_max_count boolean;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF (NEW.state='free'::vehicle_states)
		AND (now()::date=NEW.date_time::date AND  now()::time<(constant_first_shift_start_time()+constant_day_shift_length()::interval)) THEN
			--ON DAY SHIFT ONLY!!!!

			--check if it is ITS shift
			SELECT true INTO v_do_control_max_count FROM vehicle_schedule_states AS st
			WHERE st.date_time::date=NEW.date_time::date
				AND st.schedule_id=NEW.schedule_id
				AND st.state='shift'::vehicle_states;

			--check vehicle counts
			IF NOT FOUND THEN			
				v_controled_states = ARRAY['free'::vehicle_states,'assigned'::vehicle_states,'busy'::vehicle_states,'at_dest'::vehicle_states,'left_for_base'::vehicle_states];

				--current (old) state
				SELECT coalesce(vehicle_schedule_states.state,'out'::vehicle_states) INTO v_old_state
				FROM vehicle_schedule_states
				WHERE vehicle_schedule_states.schedule_id = NEW.schedule_id
				ORDER BY vehicle_schedule_states.date_time DESC LIMIT 1;

				IF NOT FOUND THEN
					v_old_state = 'out'::vehicle_states;
				END IF;

				v_do_control_max_count = (NOT v_old_state = ANY(v_controled_states));

				IF v_do_control_max_count THEN
					--need feature
					SELECT v.feature INTO v_vehicle_feature
					FROM vehicle_schedules AS vs
					LEFT JOIN vehicles AS v ON v.id=vs.vehicle_id
					WHERE vs.id=NEW.schedule_id;
				
					v_do_control_max_count = ( (v_vehicle_feature IS NOT NULL) 
					AND (v_vehicle_feature=constant_own_vehicles_feature() OR v_vehicle_feature=constant_backup_vehicles_feature()) );
				END IF;
			
				IF v_do_control_max_count THEN
					SELECT * INTO v_veh_at_work_count FROM get_working_vehicles_count_main(NEW.date_time::date);

					veh_count = constant_max_vehicle_at_work();
					IF v_veh_at_work_count>=veh_count THEN
						RAISE EXCEPTION 'Максимально допустимое количество машин на линии: %. Нет возможности добавить еще.',veh_count;
					END IF;
				END IF;
			END IF;
		END IF;
				
		RETURN NEW;
			
	ELSIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
	
		UPDATE productions
		SET
			vehicle_schedule_state_id=NULL,
			shipment_id=NULL
		WHERE shipment_id = OLD.shipment_id;
		
		RETURN OLD;
	END IF;
	
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicle_schedule_states_process()
  OWNER TO beton;

