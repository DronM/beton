-- VIEW: concrete_type_map_to_production_list

--DROP VIEW concrete_type_map_to_production_list;

CREATE OR REPLACE VIEW concrete_type_map_to_production_list AS
	SELECT
		t.id,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.production_descr
	FROM concrete_type_map_to_production AS t
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	ORDER BY ct.name
	;
	
ALTER VIEW concrete_type_map_to_production_list OWNER TO ;
