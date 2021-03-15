-- VIEW: doc_material_procurements_store_list

--DROP VIEW doc_material_procurements_store_list;

CREATE OR REPLACE VIEW doc_material_procurements_store_list AS
	SELECT
		DISTINCT store
		
	FROM doc_material_procurements
	WHERE coalesce(store,'')<>''
	ORDER BY store
	;
	
ALTER VIEW doc_material_procurements_store_list OWNER TO ;
