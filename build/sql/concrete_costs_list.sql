-- VIEW: concrete_costs_list

--DROP VIEW concrete_costs_list;

CREATE OR REPLACE VIEW concrete_costs_list AS
	SELECT
		concrete_costs.id,
		concrete_costs.date,		
		concrete_costs.price,
		concrete_costs.concrete_type_id,
		concrete_types_ref(ctp) AS concrete_types_ref
		,concrete_costs.concrete_costs_h_id
		
	FROM concrete_costs
	LEFT JOIN concrete_types AS ctp ON ctp.id=concrete_costs.concrete_type_id
	ORDER BY concrete_costs.date DESC,ctp.name
	;
	
ALTER VIEW concrete_costs_list OWNER TO ;
