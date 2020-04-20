-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
/*	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/	
	
	SELECT
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id AS material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.cement_silo_id,
		sum(t.material_quant) AS material_quant,
		sum(t.material_quant) + coalesce(t_cor.quant,0) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		ra_mat.quant - (sum(t.material_quant) + coalesce(t_cor.quant,0)) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			( (ra_mat.quant - (sum(t.material_quant) + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id --AND t_cor.cement_silo_id=t.cement_silo_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,
		mat.ord,ra_mat.quant,t.raw_material_id,t.cement_silo_id,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set,t_cor.quant
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO ;

