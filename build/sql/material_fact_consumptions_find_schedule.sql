-- Function: material_fact_consumptions_find_schedule(in_date_time timestamp with time zone,in_vehicle_id int)

-- DROP FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp with time zone,in_vehicle_id int);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp with time zone,in_vehicle_id int)
  RETURNS int AS
$$
	SELECT id FROM vehicle_schedule_states AS st
	WHERE st.schedule_id =
		(SELECT vsch.id FROM vehicle_schedules AS vsch WHERE vsch.vehicle_id=in_vehicle_id AND vsch.schedule_date = in_date_time::date)
	AND (st.state = 'assigned' OR st.state = 'busy')
	AND st.date_time BETWEEN in_date_time-'20 minute'::interval AND in_date_time+'20 minute'::interval
	LIMIT 1
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp with time zone,in_vehicle_id int) OWNER TO ;
