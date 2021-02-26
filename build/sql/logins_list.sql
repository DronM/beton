-- VIEW: logins_list

--DROP VIEW logins_list;

CREATE OR REPLACE VIEW logins_list AS
	SELECT
		t.id,
		t.date_time_in,
		t.date_time_out,
		t.ip,
		t.user_id,
		users_ref(u) AS users_ref,
		t.pub_key,
		t.set_date_time,
		
		'Устройство: '||(user_agent->>'device')||
		', ОС: '||(user_agent->'osInfo'->>'name')||
		', браузер: '||(user_agent->'clientInfo'->>'name')
		AS user_agent,
		
		sess.set_time AS session_set_time
		
	FROM logins AS t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN sessions AS sess ON sess.id=t.session_id
	WHERE t.user_id IS NOT NULL
	ORDER BY t.date_time_in DESC
	;
	
ALTER VIEW logins_list OWNER TO ;
