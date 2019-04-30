-- View: client_valid_duplicates_list

-- DROP VIEW client_valid_duplicates_list;

CREATE OR REPLACE VIEW client_valid_duplicates_list AS 
	SELECT
		t.tel,
		string_agg(cl.name::text, ', '::text) AS clients
	FROM client_valid_duplicates t
	LEFT JOIN clients cl ON cl.id = t.client_id
	GROUP BY t.tel
	ORDER BY t.tel;

ALTER TABLE client_valid_duplicates_list
  OWNER TO beton;

