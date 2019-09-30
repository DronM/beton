-- VIEW: material_fact_consumptions_list

--DROP VIEW material_fact_consumptions_list;

CREATE OR REPLACE VIEW material_fact_consumptions_list AS
	SELECT
		t.id,
		t.date_time,
		t.upload_date_time,
		users_ref(u) AS upload_users_ref,
		production_sites_ref(pr) AS production_sites_ref,
		t.production_site_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.concrete_type_production_descr,
		materials_ref(mat) AS raw_materials_ref,
		t.raw_material_production_descr,
		vehicles_ref(vh) AS vehicles_ref,
		t.vehicle_production_descr,
		orders_ref(o) AS orders_ref,
		CASE
			WHEN sh.id IS NOT NULL THEN
				'№'||sh.id||' от '||to_char(sh.date_time,'DD/MM/YY HH24:MI:SS')
			ELSE ''
		END AS shipments_inf,
		t.concrete_quant,
		t.material_quant,
		t.material_quant_req
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	LEFT JOIN vehicle_schedule_states AS vh_sch_st ON vh_sch_st.id=t.vehicle_schedule_state_id
	LEFT JOIN shipments AS sh ON sh.id=vh_sch_st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id
	ORDER BY pr.name,t.date_time,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO ;
