-- VIEW: material_fact_consumptions_list

--DROP VIEW material_fact_consumptions_list CASCADE;

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
		coalesce(t.concrete_quant,0) AS concrete_quant,
		coalesce(t.material_quant) AS material_quant,
		coalesce(t_cor.quant,0) AS material_quant_cor,
		t.material_quant_req,
		
		--Ошибка в марке
		(t.concrete_type_id IS NOT NULL AND t.concrete_type_id<>o.concrete_type_id) AS err_concrete_type,
		
		--ra_mat.quant AS material_quant_shipped,
		CASE
			WHEN coalesce(sh.quant,0)=0 OR coalesce(t.concrete_quant,0)=0 THEN 0
			ELSE coalesce(ra_mat.quant,0)/coalesce(sh.quant,0) * coalesce(t.concrete_quant,0)
		END AS material_quant_shipped,		
		
		
		/*
		(
			CASE
				WHEN mat.id IS NULL THEN FALSE
				WHEN coalesce(ra_mat.quant,0) = 0 OR coalesce(sh.quant,0)=0 OR coalesce(t.concrete_quant,0)=0 THEN TRUE
				ELSE abs(t.material_quant/ra_mat.quant*100-100)>=coalesce(mat.max_required_quant_tolerance_percent,100)
			END
		) AS material_quant_tolerance_exceeded,
		*/
		prod.material_tolerance_violated AS material_quant_tolerance_exceeded,
		
		concrete_types_ref(ct_o) AS order_concrete_types_ref,
		
		t.production_id,
		
		shipments_ref(sh) AS shipments_ref,
		prod.id AS production_key,
		
		t.concrete_type_id
				
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	--LEFT JOIN vehicle_schedule_states AS vh_sch_st ON vh_sch_st.id=t.vehicle_schedule_state_id
	LEFT JOIN productions AS prod ON prod.production_site_id=t.production_site_id AND prod.production_id=t.production_id
	LEFT JOIN shipments AS sh ON sh.id=prod.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id
	LEFT JOIN concrete_types AS ct_o ON ct_o.id=o.concrete_type_id	
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=sh.id AND ra_mat.material_id=t.raw_material_id
	--LEFT JOIN production_vehicle_corrections AS v_cor ON v_cor.production_site_id=.production_site_id AND v_cor.production_id=.production_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id
		AND t_cor.production_id=t.production_id AND t_cor.material_id=t.raw_material_id 
	
	ORDER BY pr.name,t.date_time DESC,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO ;
