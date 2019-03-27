-- Function: set_vehicle_schedule_free(integer)

-- DROP FUNCTION set_vehicle_schedule_free(integer);

CREATE OR REPLACE FUNCTION set_vehicle_schedule_free(integer)
  RETURNS void AS
$BODY$
DECLARE cur_state vehicle_states;
	cur_state_id int;
	cur_date date;
BEGIN
	SELECT state,id INTO cur_state,cur_state_id FROM vehicle_schedule_states WHERE schedule_id=$1 ORDER BY date_time DESC LIMIT 1;
	
	IF (cur_state = 'out'::vehicle_states) 
	OR (cur_state = 'out_from_shift'::vehicle_states)
	THEN
		--get previous state
		SELECT state INTO cur_state FROM vehicle_schedule_states WHERE schedule_id=$1 ORDER BY date_time DESC LIMIT 1 OFFSET 1;
		
		--delete out comment which will delete out state
		DELETE FROM out_comments WHERE vehicle_schedule_id=$1;
	END IF;
	--RAISE EXCEPTION 'cur_state=%',cur_state;
	IF cur_state != 'free'::vehicle_states THEN
		SELECT schedule_date INTO cur_date FROM vehicle_schedules WHERE id=$1;
		IF (cur_date<>get_shift_start(current_timestamp::timestamp without time zone)::date ) THEN
			RAISE EXCEPTION 'Нельзя освободить автомобиль на будующую дату!';
		END IF;
		
		INSERT INTO vehicle_schedule_states
		(date_time,state,schedule_id,tracker_id)
		VALUES(current_timestamp,'free'::vehicle_states,$1, get_vehicle_tracker_id_on_schedule_id($1));
	END IF;

EXCEPTION WHEN raise_exception THEN
	RAISE EXCEPTION 'Нет возможности добавить автомобиль!';
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION set_vehicle_schedule_free(integer)
  OWNER TO beton;

