-- Function: public.vehicle_last_states(date)

-- DROP FUNCTION public.vehicle_last_states(date);

CREATE OR REPLACE FUNCTION public.vehicle_last_states(IN in_date date)
  RETURNS TABLE(
	date_time timestamp,
	id int,
	vehicles_count int,	
	vehicles_ref JSON,	
	owner text,	
	drivers_ref JSON,
	driver_phone_cel text,	
	state vehicle_states, 
	is_late boolean,
	is_late_at_dest boolean,
	inf_on_return text, 	
	load_capacity double precision,
	runs bigint,
	tracker_no_data boolean,	
	no_tracker boolean,	
	schedule_date date,
	vehicle_schedules_ref json,
	driver_tel text
  ) AS
$BODY$
	--*****************************
	WITH states_q AS (SELECT * FROM vehicle_states_all WHERE schedule_date=$1)
	--assigned
	(SELECT *
	FROM states_q
	WHERE  state='assigned'::vehicle_states
	ORDER BY CURRENT_TIMESTAMP-date_time DESC)

	UNION ALL

	--free
	(SELECT *	
	FROM states_q
	WHERE state='free'::vehicle_states
	ORDER BY CURRENT_TIMESTAMP-date_time DESC)

	UNION ALL

	--late
	(SELECT *
	FROM states_q
	WHERE is_late
	ORDER BY CURRENT_TIMESTAMP-date_time DESC)


	UNION ALL

	--busy && at_dest(late/not late) && left_for_base
	(SELECT *
	FROM states_q
	WHERE (state='busy'::vehicle_states OR state='at_dest'::vehicle_states OR state='left_for_base'::vehicle_states)
		AND (NOT is_late)
	ORDER BY inf_on_return ASC)


	UNION ALL

	--shift && shift_added
	(SELECT *		
	FROM states_q
	WHERE  schedule_date=$1 AND (state='shift'::vehicle_states OR state='shift_added'::vehicle_states)
	ORDER BY vehicles_ref->>'descr')

	UNION ALL

	--out
	(SELECT *
	FROM states_q
	WHERE (state='out_from_shift'::vehicle_states OR state='out'::vehicle_states)
	ORDER BY inf_on_return
	);
	
	--*****************************
$BODY$
  LANGUAGE sql VOLATILE COST 100 ROWS 50;
ALTER FUNCTION public.vehicle_last_states(date) OWNER TO beton;

