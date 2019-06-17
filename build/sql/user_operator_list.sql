-- VIEW: user_operator_list

--DROP VIEW user_operator_list;

CREATE OR REPLACE VIEW user_operator_list AS
	SELECT
		u.id,
		u.name,
		u.email,
		u.phone_cel,
		production_sites_ref(ps) AS production_sites_ref
	FROM users AS u
	LEFT JOIN production_sites AS ps ON ps.id=u.production_site_id
	WHERE role_id='operator' AND NOT coalesce(banned,FALSE)
	ORDER BY u.name
	;
	
ALTER VIEW user_operator_list OWNER TO ;

