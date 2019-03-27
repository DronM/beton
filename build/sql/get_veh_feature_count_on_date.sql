-- Function: public.get_veh_feature_count_on_date(date)

-- DROP FUNCTION public.get_veh_feature_count_on_date(date);

CREATE OR REPLACE FUNCTION public.get_veh_feature_count_on_date(IN in_date date)
  RETURNS TABLE(feature character varying, cnt bigint) AS
$BODY$
	SELECT v.feature,COUNT(*) As cnt
	FROM vehicle_schedules AS vs
	LEFT JOIN vehicle_schedule_states st ON st.schedule_id = vs.id
		AND st.date_time = (SELECT vehicle_schedule_states.date_time AS max
			FROM vehicle_schedule_states
			WHERE vehicle_schedule_states.schedule_id = vs.id
			ORDER BY vehicle_schedule_states.date_time DESC LIMIT 1
		)
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	WHERE vs.schedule_date = in_date
	AND st.state <> 'out'::vehicle_states AND st.state <> 'out_from_shift'::vehicle_states AND st.state <> 'shift'::vehicle_states AND st.state <> 'shift_added'::vehicle_states
	GROUP BY v.feature;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.get_veh_feature_count_on_date(date)
  OWNER TO beton;

