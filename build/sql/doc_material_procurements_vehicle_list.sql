-- VIEW: doc_material_procurements_vehicle_list

DROP VIEW doc_material_procurements_vehicle_list;

CREATE OR REPLACE VIEW doc_material_procurements_vehicle_list AS
	SELECT
		DISTINCT vehicle_plate
		
	FROM doc_material_procurements
	WHERE coalesce(vehicle_plate,'')<>''
	ORDER BY vehicle_plate
	;
	
ALTER VIEW doc_material_procurements_vehicle_list OWNER TO ;
