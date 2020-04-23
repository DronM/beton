-- VIEW: material_fact_consumptions_rolled_list

--DROP VIEW material_fact_consumptions_rolled_list;

CREATE OR REPLACE VIEW material_fact_consumptions_rolled_list AS
	SELECT
		date_time,
		upload_date_time,
		(upload_users_ref::text)::jsonb AS upload_users_ref,
		(production_sites_ref::text)::jsonb AS production_sites_ref,
		production_site_id,
		(concrete_types_ref::text)::jsonb AS concrete_types_ref,
		(order_concrete_types_ref::text)::jsonb AS order_concrete_types_ref,
		concrete_type_production_descr,
		(vehicles_ref::text)::jsonb AS vehicles_ref,
		vehicle_production_descr,
		(orders_ref::text)::jsonb AS orders_ref,
		shipments_inf,
		concrete_quant,
		jsonb_agg(
			jsonb_build_object(
				'production_descr',raw_material_production_descr,
				'ref',raw_materials_ref,
				'quant',material_quant,
				'quant_req',material_quant_req,
				'quant_shipped',material_quant_shipped,
				'quant_tolerance_exceeded',material_quant_tolerance_exceeded
			)
		) AS materials,
		err_concrete_type,
		production_id
		
	FROM material_fact_consumptions_list
	GROUP BY date_time,
		concrete_quant,
		upload_date_time,
		upload_users_ref::text,
		production_sites_ref::text,
		production_site_id,
		concrete_types_ref::text,
		order_concrete_types_ref::text,
		concrete_type_production_descr,
		vehicles_ref::text,
		vehicle_production_descr,
		orders_ref::text,
		shipments_inf,
		err_concrete_type,
		production_id
	ORDER BY date_time DESC

	;
	
ALTER VIEW material_fact_consumptions_rolled_list OWNER TO ;
