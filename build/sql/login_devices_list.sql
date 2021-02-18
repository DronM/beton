-- VIEW: login_devices_list

DROP VIEW login_devices_list;

CREATE OR REPLACE VIEW login_devices_list AS
	SELECT
		t.user_id,
		u.name AS user_descr,		
		max(t.date_time_in) AS date_time_in,
		headers_j->>'User-Agent' AS user_agent,
		CASE
			WHEN bn.user_id IS NULL THEN FALSE
			ELSE TRUE
		END AS banned	
	FROM logins AS t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN sessions AS sess ON sess.id=t.session_id
	LEFT JOIN login_device_bans AS bn ON bn.user_id=u.id AND bn.hash=md5((headers_j->>'User-Agent')::text)
	WHERE headers_j->>'User-Agent'<>''
		--t.user_id=80 AND 
	GROUP BY t.user_id,headers_j->>'User-Agent',u.name,bn.user_id
	ORDER BY max(t.date_time_in) DESC
	;
	
ALTER VIEW login_devices_list OWNER TO ;
