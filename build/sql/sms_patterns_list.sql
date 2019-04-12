-- VIEW: sms_patterns_list

--DROP VIEW sms_patterns_list;

CREATE OR REPLACE VIEW sms_patterns_list AS
	SELECT
		sms_patterns.*,
		langs_ref(langs) AS langs_ref,
		user_phones.user_list
	FROM sms_patterns
	LEFT JOIN langs ON langs.id=sms_patterns.lang_id
	LEFT JOIN (
		SELECT
			ph.sms_pattern_id,
			string_agg(u.name||coalesce('('||format_cel_phone(u.phone_cel)||')',''),',')  AS user_list
		FROM sms_pattern_user_phones AS ph
		LEFT JOIN users u ON u.id=ph.user_id
		GROUP BY ph.sms_pattern_id
	) AS user_phones ON user_phones.sms_pattern_id=sms_patterns.id
	ORDER BY sms_patterns.sms_type,langs.name
	;
	
ALTER VIEW sms_patterns_list OWNER TO ;

