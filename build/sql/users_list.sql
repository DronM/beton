-- View: users_list

-- DROP VIEW users_list;

CREATE OR REPLACE VIEW users_list AS 
	SELECT
	 	u.*
 	FROM users AS u
	ORDER BY u.name;

ALTER TABLE users_list OWNER TO ;

