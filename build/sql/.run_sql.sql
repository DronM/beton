DELETE FROM const_efficiency_warn_k;
		INSERT INTO const_efficiency_warn_k (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Значение состояния ниже которого отправляется сообщение'
			,''
			,-60
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_efficiency_warn_k_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_efficiency_warn_k LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_efficiency_warn_k_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_efficiency_warn_k_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_efficiency_warn_k SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_efficiency_warn_k_set_val(Int) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_efficiency_warn_k_view AS
		SELECT
			'efficiency_warn_k'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_efficiency_warn_k AS t
		;
		ALTER VIEW const_efficiency_warn_k_view OWNER TO beton;
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
		FROM const_water_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_from_day_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_to_day_view
		UNION ALL
		SELECT *
		FROM const_show_time_for_shipped_vehicles_view
		UNION ALL
		SELECT *
		FROM const_tracker_malfunction_tel_list_view
		UNION ALL
		SELECT *
		FROM const_low_efficiency_tel_list_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	
