-- View: users_list

-- DROP VIEW users_list;

CREATE OR REPLACE VIEW users_list AS 
	SELECT
	 	u.id,
	 	u.name,
	 	u.role_id,
	 	u.phone_cel,
	 	u.tel_ext,
	 	u.email,
	 	u.banned
	 	
 	FROM users AS u
	ORDER BY u.name;

ALTER TABLE users_list OWNER TO ;

