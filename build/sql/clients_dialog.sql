-- View: public.clients_dialog

-- DROP VIEW public.clients_dialog;

CREATE OR REPLACE VIEW public.clients_dialog AS 
	SELECT
		cl.id,
		cl.name,
		cl.name_full,
		cl.manager_comment,
		client_types_ref(ct) AS client_types_ref,
		client_come_from_ref(ccf) AS client_come_from_ref,
		cl.phone_cel,
		cl.email,
		cl.client_kind,
		users_ref(u) AS users_ref,
		
		cl.inn
		
	FROM clients cl
	LEFT JOIN client_types ct ON ct.id = cl.client_type_id
	LEFT JOIN client_come_from ccf ON ccf.id = cl.client_come_from_id
	LEFT JOIN users u ON u.id = cl.manager_id;

ALTER TABLE public.clients_dialog
  OWNER TO beton;

