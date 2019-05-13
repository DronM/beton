
		--constant value table
		CREATE TABLE IF NOT EXISTS const_water_ship_cost
		(name text, descr text, val  numeric(15,2),
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_water_ship_cost OWNER TO beton;
		INSERT INTO const_water_ship_cost (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Стоимость доставки воды '
			,'Стоимость доставки воды'
			,2000
			,'Float'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_water_ship_cost_val()
		RETURNS  numeric(15,2) AS
		$BODY$
			SELECT val:: numeric(15,2) AS val FROM const_water_ship_cost LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_water_ship_cost_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_water_ship_cost_set_val(Float)
		RETURNS void AS
		$BODY$
			UPDATE const_water_ship_cost SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_water_ship_cost_set_val(Float) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_water_ship_cost_view AS
		SELECT
			'water_ship_cost'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_water_ship_cost AS t
		;
		ALTER VIEW const_water_ship_cost_view OWNER TO beton;
		CREATE OR REPLACE VIEW constants_list_view AS
		SELECT *
		FROM const_doc_per_page_count_view
		UNION ALL
		SELECT *
		FROM const_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_order_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_backup_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_id_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_view
		UNION ALL
		SELECT *
		FROM const_chart_step_min_view
		UNION ALL
		SELECT *
		FROM const_day_shift_length_view
		UNION ALL
		SELECT *
		FROM const_days_allowed_with_broken_tracker_view
		UNION ALL
		SELECT *
		FROM const_def_order_unload_speed_view
		UNION ALL
		SELECT *
		FROM const_demurrage_coast_per_hour_view
		UNION ALL
		SELECT *
		FROM const_first_shift_start_time_view
		UNION ALL
		SELECT *
		FROM const_geo_zone_check_points_count_view
		UNION ALL
		SELECT *
		FROM const_map_default_lat_view
		UNION ALL
		SELECT *
		FROM const_map_default_lon_view
		UNION ALL
		SELECT *
		FROM const_max_hour_load_view
		UNION ALL
		SELECT *
		FROM const_max_vehicle_at_work_view
		UNION ALL
		SELECT *
		FROM const_min_demurrage_time_view
		UNION ALL
		SELECT *
		FROM const_min_quant_for_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_no_tracker_signal_warn_interval_view
		UNION ALL
		SELECT *
		FROM const_ord_mark_if_no_ship_time_view
		UNION ALL
		SELECT *
		FROM const_order_auto_place_tolerance_view
		UNION ALL
		SELECT *
		FROM const_order_step_min_view
		UNION ALL
		SELECT *
		FROM const_own_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_raw_mater_plcons_rep_def_days_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_id_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_view
		UNION ALL
		SELECT *
		FROM const_shift_for_orders_length_time_view
		UNION ALL
		SELECT *
		FROM const_shift_length_time_view
		UNION ALL
		SELECT *
		FROM const_ship_coast_for_self_ship_destination_view
		UNION ALL
		SELECT *
		FROM const_speed_change_for_order_autolocate_view
		UNION ALL
		SELECT *
		FROM const_vehicle_unload_time_view
		UNION ALL
		SELECT *
		FROM const_avg_mat_cons_dev_day_count_view
		UNION ALL
		SELECT *
		FROM const_days_for_plan_procur_view
		UNION ALL
		SELECT *
		FROM const_lab_min_sample_count_view
		UNION ALL
		SELECT *
		FROM const_lab_days_for_avg_view
		UNION ALL
		SELECT *
		FROM const_city_ext_view
		UNION ALL
		SELECT *
		FROM const_def_lang_view
		UNION ALL
		SELECT *
		FROM const_efficiency_warn_k_view
		UNION ALL
		SELECT *
		FROM const_zone_violation_alarm_interval_view
		UNION ALL
		SELECT *
		FROM const_weather_update_interval_sec_view
		UNION ALL
		SELECT *
		FROM const_call_history_count_view
		UNION ALL
		SELECT *
		FROM const_water_ship_cost_view;
		ALTER VIEW constants_list_view OWNER TO ;
	