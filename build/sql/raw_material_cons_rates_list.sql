-- VIEW: raw_material_cons_rates_list

--DROP VIEW raw_material_cons_rates_list;

CREATE OR REPLACE VIEW raw_material_cons_rates_list AS
	SELECT
		t.rate_date_id,
		t.concrete_type_id,
		concrete_types_ref(ctp) AS concrete_types_ref,
		t.raw_material_id,
		materials_ref(m) AS raw_materials_ref,
		t.rate
		
	FROM raw_material_cons_rates t
	LEFT JOIN concrete_types AS ctp ON ctp.id=t.concrete_type_id
	LEFT JOIN raw_materials AS m ON m.id=t.raw_material_id
	;
	
ALTER VIEW raw_material_cons_rates_list OWNER TO ;
