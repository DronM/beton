-- View: public.user_mac_addresses_list

-- DROP VIEW public.user_mac_addresses_list;

CREATE OR REPLACE VIEW public.user_mac_addresses_list AS 
	SELECT
		adr.id,
		adr.user_id,
		u.name AS user_descr,
		adr.mac_address
	FROM user_mac_addresses adr
	LEFT JOIN users u ON u.id = adr.user_id
	ORDER BY u.name;

ALTER TABLE public.user_mac_addresses_list
  OWNER TO beton;

