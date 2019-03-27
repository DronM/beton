-- Function: public.vehicle_run_inf_on_schedule(integer)

--DROP FUNCTION public.vehicle_run_inf_on_schedule(integer);

CREATE OR REPLACE FUNCTION public.vehicle_run_inf_on_schedule(IN in_scgedule_id integer)
  RETURNS TABLE(
  	st_free_start timestamp without time zone,
  	st_assigned timestamp without time zone,
  	st_shipped timestamp without time zone,
  	st_at_dest timestamp without time zone,
  	st_left_for_base timestamp without time zone,
  	st_free_end timestamp without time zone,
  	destinations_ref json,
  	run_time timestamp without time zone,
  	veh_id integer
  	) AS
$BODY$
DECLARE st_row RECORD;
	v_run_started boolean;
BEGIN
	v_run_started = false;
	FOR st_row IN
		SELECT
			vehicle_schedule_states.date_time,
			vehicle_schedule_states.state,
			coalesce(vehicle_schedule_states.shipment_id,0) AS shipment_id,
			vehicle_schedules.vehicle_id
		FROM vehicle_schedule_states
		LEFT JOIN vehicle_schedules ON vehicle_schedules.id = vehicle_schedule_states.schedule_id
		WHERE vehicle_schedules.id=in_scgedule_id
		ORDER BY vehicle_schedule_states.date_time
	LOOP
		IF st_row.state='assigned'::vehicle_states
		AND v_run_started THEN
			st_assigned = st_row.date_time;
			IF (st_row.shipment_id>0) THEN
				SELECT
					destinations_ref(destinations) INTO destinations_ref
				FROM shipments
				LEFT JOIN orders ON orders.id=shipments.order_id
				LEFT JOIN destinations ON destinations.id=orders.destination_id
				WHERE shipments.id=st_row.shipment_id;
			END IF;
			
		ELSIF st_row.state='at_dest'::vehicle_states
		AND v_run_started THEN
			st_at_dest = st_row.date_time;

		ELSIF st_row.state='left_for_base'::vehicle_states
		AND v_run_started THEN
			st_left_for_base = st_row.date_time;
			
		ELSIF st_row.state='busy'::vehicle_states
		AND v_run_started THEN
			st_shipped = st_row.date_time;
			
		ELSIF (st_row.state='free'::vehicle_states)
		AND (v_run_started=false) THEN
			--new run
			st_free_start = st_row.date_time;
			veh_id = st_row.vehicle_id;
			
			st_assigned = NULL;
			st_at_dest = NULL;
			st_left_for_base = NULL;
			st_shipped = NULL;
			st_free_end = NULL;			
			destinations_ref = NULL;
			run_time = NULL;
			
			v_run_started = true;
			
		ELSIF (st_row.state='free'::vehicle_states)
		AND (v_run_started) THEN
			st_free_end = st_row.date_time;
			run_time = now()::date+date_trunc('minute', st_free_end - st_shipped);--to_char(,'HH24:MI');			
			RETURN NEXT;

			--new run
			st_free_start = st_row.date_time;
			st_assigned = NULL;
			st_at_dest = NULL;
			st_left_for_base = NULL;
			st_shipped = NULL;
			st_free_end = NULL;			
			destinations_ref = NULL;
			run_time = NULL;
			
			v_run_started = true;			
		END IF;
	END LOOP;

	IF v_run_started THEN
		RETURN NEXT;
	END IF;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.vehicle_run_inf_on_schedule(integer)
  OWNER TO beton;

