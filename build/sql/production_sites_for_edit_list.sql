-- VIEW: production_sites_for_edit_list

--DROP VIEW production_sites_for_edit_list;

CREATE OR REPLACE VIEW production_sites_for_edit_list AS
	SELECT
		*		 
	FROM production_sites
	ORDER BY name
	;
	
ALTER VIEW production_sites_for_edit_list OWNER TO ;
