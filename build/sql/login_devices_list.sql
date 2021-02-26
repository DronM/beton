-- VIEW: login_devices_list

DROP VIEW login_devices_list;

CREATE OR REPLACE VIEW login_devices_list AS
	SELECT
		t.user_id,
		u.name AS user_descr,		
		max(t.date_time_in) AS date_time_in,
		login_devices_uniq(t.user_agent) AS user_agent,
		CASE
			WHEN bn.user_id IS NULL THEN FALSE
			ELSE TRUE
		END AS banned,
		md5(login_devices_uniq(t.user_agent)) AS ban_hash
	FROM logins AS t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN sessions AS sess ON sess.id=t.session_id
	LEFT JOIN login_device_bans AS bn ON bn.user_id=u.id AND bn.hash=md5(login_devices_uniq(t.user_agent))
	WHERE login_devices_uniq(t.user_agent) IS NOT NULL
	
	GROUP BY t.user_id,login_devices_uniq(t.user_agent),u.name,bn.user_id
	ORDER BY max(t.date_time_in) DESC
	;
	
ALTER VIEW login_devices_list OWNER TO ;
