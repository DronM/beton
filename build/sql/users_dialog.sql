-- View: public.users_dialog

 DROP VIEW public.users_dialog;

CREATE OR REPLACE VIEW public.users_dialog AS 
	SELECT
		users.*,
		time_zone_locales.name AS user_time_locale
	FROM users
	LEFT JOIN time_zone_locales ON time_zone_locales.id=users.time_zone_locale_id
	;

ALTER TABLE public.users_dialog
  OWNER TO beton;

