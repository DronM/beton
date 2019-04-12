-- VIEW: sms_pattern_user_phones_list

--DROP VIEW sms_pattern_user_phones_list;

CREATE OR REPLACE VIEW sms_pattern_user_phones_list AS
	SELECT
		ph.*,
		users_ref(u) AS users_ref,
		u.phone_cel AS user_tel
	FROM sms_pattern_user_phones AS ph
	LEFT JOIN users AS u ON u.id=ph.user_id
	;
	
ALTER VIEW sms_pattern_user_phones_list OWNER TO ;
