CREATE OR REPLACE VIEW public.veh_feature_count AS 
	SELECT
		vs.schedule_date,
		v.feature,		
		COUNT(*) AS cnt
	FROM vehicle_schedules AS vs
	LEFT JOIN vehicle_schedule_states st ON st.schedule_id = vs.id
		AND st.date_time = (SELECT vehicle_schedule_states.date_time AS max
			FROM vehicle_schedule_states
			WHERE vehicle_schedule_states.schedule_id = vs.id
			ORDER BY vehicle_schedule_states.date_time DESC NULLS LAST
			LIMIT 1
		)
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	WHERE st.state <> 'out'::vehicle_states AND st.state <> 'out_from_shift'::vehicle_states AND st.state <> 'shift'::vehicle_states AND st.state <> 'shift_added'::vehicle_states
	GROUP BY vs.schedule_date,v.feature;

ALTER TABLE public.veh_feature_count OWNER TO beton;
