-- VIEW: cement_silos_list

--DROP VIEW cement_silos_list;

CREATE OR REPLACE VIEW cement_silos_list AS
	SELECT
		t.*,
		production_sites_ref(pst) AS production_sites_ref
	FROM cement_silos AS t
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_list OWNER TO ;
