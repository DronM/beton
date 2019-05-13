-- View: vehicle_schedules_list

-- DROP VIEW vehicle_schedules_list;

CREATE OR REPLACE VIEW vehicle_schedules_list AS 
	SELECT
		vs.id,
		vs.schedule_date,
		drivers_ref(d) AS drivers_ref,
		vehicles_ref(v) AS vehicles_ref,
		st.state,
		st.date_time AS state_date_time,
		v.load_capacity,
		oc.comment_text AS out_comment,
		v.owner,
		d.phone_cel,
		vehicle_owners_ref(v_own) AS vehicle_owners_ref
		
	FROM vehicle_schedules vs
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN (
		SELECT
			t.schedule_id,
			max(t.date_time) AS date_time
		FROM vehicle_schedule_states t
		GROUP BY t.schedule_id
	) AS s_max ON s_max.schedule_id=vs.id
	LEFT JOIN vehicle_schedule_states st
		ON st.schedule_id=s_max.schedule_id AND st.date_time = s_max.date_time
		
	LEFT JOIN out_comments oc ON oc.vehicle_schedule_id = vs.id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	
	ORDER BY
		CASE
		WHEN st.state='shift' THEN 1
		ELSE 0
		END,
		st.date_time;

ALTER TABLE vehicle_schedules_list OWNER TO beton;

