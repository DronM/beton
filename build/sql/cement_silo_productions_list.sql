-- VIEW: cement_silo_productions_list

--DROP VIEW cement_silo_productions_list;

CREATE OR REPLACE VIEW cement_silo_productions_list AS
	SELECT
		t.id,
		cement_silos_ref(cs) AS cement_silos_ref,
		t.date_time,
		t.production_date_time,
		t.production_vehicle_descr,
		vehicles_ref(vh) AS vehicles_ref,
		t.vehicle_state
		
	FROM cement_silo_productions AS t
	LEFT JOIN cement_silos AS cs ON cs.id=t.cement_silo_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	ORDER BY cs.name,t.date_time DESC
	;
	
ALTER VIEW cement_silo_productions_list OWNER TO ;
