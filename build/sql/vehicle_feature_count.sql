-- VIEW: vehicle_feature_count

--DROP VIEW vehicle_feature_count;

CREATE OR REPLACE VIEW vehicle_feature_count AS
SELECT
	vs.schedule_date,
	v.feature,
	COUNT(*) AS cnt
	FROM vehicle_schedules AS vs
	LEFT JOIN vehicle_schedule_states st ON st.schedule_id = vs.id
		AND st.date_time = (SELECT t.date_time AS max
			FROM vehicle_schedule_states AS t
			WHERE t.schedule_id = vs.id
			ORDER BY t.date_time DESC LIMIT 1
		)
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	WHERE
		st.state <> 'out'::vehicle_states AND st.state <> 'out_from_shift'::vehicle_states AND st.state <> 'shift'::vehicle_states AND st.state <> 'shift_added'::vehicle_states
	GROUP BY v.feature,vs.schedule_date;
	
ALTER VIEW vehicle_feature_count OWNER TO ;
