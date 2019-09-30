-- VIEW: vehicle_map_to_production_list

--DROP VIEW vehicle_map_to_production_list;

CREATE OR REPLACE VIEW vehicle_map_to_production_list AS
	SELECT
		t.id,
		vehicles_ref(vh) AS vehicles_ref,
		t.production_descr
	FROM vehicle_map_to_production AS t
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	ORDER BY vh.plate
	;
	
ALTER VIEW vehicle_map_to_production_list OWNER TO ;
