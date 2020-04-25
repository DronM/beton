-- VIEW: productions_list

--DROP VIEW productions_list;

CREATE OR REPLACE VIEW productions_list AS
	SELECT
		t.id,
		t.production_id,
		t.production_site_id,
		t.production_dt_start,
		t.production_dt_end,
		t.production_user,
		t.production_vehicle_descr,
		t.dt_start_set,
		t.dt_end_set,
		production_sites_ref(ps) AS production_sites_ref,
		shipments_ref(sh) AS shipments_ref,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.production_concrete_type_descr,
		orders_ref(o) AS orders_ref,
		vs.vehicle_id,
		vehicle_schedules_ref(vs,v,dr) AS vehicle_schedules_ref
		
		,t.material_tolerance_violated
		
	FROM productions AS t
	LEFT JOIN production_sites AS ps ON ps.id = t.production_site_id
	LEFT JOIN shipments AS sh ON sh.id = t.shipment_id
	LEFT JOIN concrete_types AS ct ON ct.id = t.concrete_type_id
	LEFT JOIN orders AS o ON o.id = sh.order_id
	LEFT JOIN vehicle_schedules AS vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS v ON v.id = vs.vehicle_id
	LEFT JOIN drivers AS dr ON dr.id = vs.driver_id
	ORDER BY t.production_dt_start DESC
	;
	
ALTER VIEW productions_list OWNER TO ;
