-- VIEW: concrete_costs_for_owner_list

--DROP VIEW concrete_costs_for_owner_list;

CREATE OR REPLACE VIEW concrete_costs_for_owner_list AS
	SELECT
		t.id,
		t.header_id,
		t.price,
		t.concrete_type_id,
		concrete_types_ref(ctp) AS concrete_types_ref
	FROM concrete_costs_for_owner t
	LEFT JOIN concrete_types AS ctp ON ctp.id=t.concrete_type_id
	ORDER BY t.header_id,ctp.name
	;
	
ALTER VIEW concrete_costs_for_owner_list OWNER TO ;
