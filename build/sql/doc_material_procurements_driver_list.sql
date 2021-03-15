-- VIEW: doc_material_procurements_driver_list

DROP VIEW doc_material_procurements_driver_list;

CREATE OR REPLACE VIEW doc_material_procurements_driver_list AS
	SELECT
		DISTINCT driver
		
	FROM doc_material_procurements
	WHERE coalesce(driver,'')<>''
	ORDER BY driver
	;
	
ALTER VIEW doc_material_procurements_driver_list OWNER TO ;
