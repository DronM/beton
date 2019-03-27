-- View: public.users_list

-- DROP VIEW public.users_list;

CREATE OR REPLACE VIEW public.users_list AS 
	SELECT
		users.id,
		users.name,
		users.role_id,
		users.tel_ext,
		users.email,
		users.phone_cel
	FROM users
	ORDER BY users.name;

ALTER TABLE public.users_list
  OWNER TO beton;

