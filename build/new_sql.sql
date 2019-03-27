
DROP VIEW public.const_avg_mat_cons_dev_day_count_view CASCADE;

CREATE OR REPLACE VIEW public.const_avg_mat_cons_dev_day_count_view AS 
 SELECT
 'const_avg_mat_cons_dev_day_count'::text AS id,
 t.name,
    t.descr,		
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
   FROM const_avg_mat_cons_dev_day_count t;

ALTER TABLE public.const_avg_mat_cons_dev_day_count_view
  OWNER TO beton;
 DROP VIEW public.const_backup_vehicles_feature_view;

CREATE OR REPLACE VIEW public.const_backup_vehicles_feature_view AS 
 SELECT
 	 'const_backup_vehicles_feature'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
    
   FROM const_backup_vehicles_feature t;

ALTER TABLE public.const_backup_vehicles_feature_view
  OWNER TO beton;

DROP VIEW public.const_base_geo_zone_id_view;

CREATE OR REPLACE VIEW public.const_base_geo_zone_id_view AS 
 SELECT
 'const_base_geo_zone_id'::text AS id,
 t.name,
t.descr,
    t.val::text AS val,
    t.val_type,
    t.ctrl_class::text AS ctrl_class,
    t.ctrl_options,
    t.view_class::text AS view_class,
    t.view_options
 FROM const_base_geo_zone_id t;

ALTER TABLE public.const_base_geo_zone_id_view
  OWNER TO beton;

 DROP VIEW public.const_base_geo_zone_view;

CREATE OR REPLACE VIEW public.const_base_geo_zone_view AS 
 SELECT
 	'const_base_geo_zone'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
    
   FROM const_base_geo_zone t
     LEFT JOIN destinations j ON j.id = t.val;

ALTER TABLE public.const_base_geo_zone_view
  OWNER TO beton;

 DROP VIEW public.const_chart_step_min_view;

CREATE OR REPLACE VIEW public.const_chart_step_min_view AS 
 SELECT
 	'const_chart_step_min'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_chart_step_min t;

ALTER TABLE public.const_chart_step_min_view
  OWNER TO beton;

 DROP VIEW public.const_city_ext_view;

CREATE OR REPLACE VIEW public.const_city_ext_view AS 
 SELECT
 	'const_city_ext'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_city_ext t;

ALTER TABLE public.const_city_ext_view
  OWNER TO beton;

DROP VIEW public.const_day_shift_length_view;

CREATE OR REPLACE VIEW public.const_day_shift_length_view AS 
 SELECT
 	'const_day_shift_length'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
    
   FROM const_day_shift_length t;

ALTER TABLE public.const_day_shift_length_view
  OWNER TO beton;

DROP VIEW public.const_days_allowed_with_broken_tracker_view;

CREATE OR REPLACE VIEW public.const_days_allowed_with_broken_tracker_view AS 
 SELECT
 'const_days_allowed_with_broken_tracker'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

    
   FROM const_days_allowed_with_broken_tracker t;

ALTER TABLE public.const_days_allowed_with_broken_tracker_view
  OWNER TO beton;

DROP VIEW public.const_days_for_plan_procur_view;

CREATE OR REPLACE VIEW public.const_days_for_plan_procur_view AS 
 SELECT
 	'const_city_ext'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_days_for_plan_procur t;

ALTER TABLE public.const_days_for_plan_procur_view
  OWNER TO beton;

-- View: public.const_def_order_unload_speed_view

 DROP VIEW public.const_def_order_unload_speed_view;

CREATE OR REPLACE VIEW public.const_def_order_unload_speed_view AS 
 SELECT
 	'const_def_order_unload_speed'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_def_order_unload_speed t;

ALTER TABLE public.const_def_order_unload_speed_view
  OWNER TO beton;

DROP VIEW public.const_demurrage_coast_per_hour_view;

CREATE OR REPLACE VIEW public.const_demurrage_coast_per_hour_view AS 
 SELECT
 	'const_demurrage_coast_per_hour'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_demurrage_coast_per_hour t;

ALTER TABLE public.const_demurrage_coast_per_hour_view
  OWNER TO beton;

DROP VIEW public.const_first_shift_start_time_view;

CREATE OR REPLACE VIEW public.const_first_shift_start_time_view AS 
 SELECT
 'first_shift_start_time'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_first_shift_start_time t;

ALTER TABLE public.const_first_shift_start_time_view
  OWNER TO beton;

DROP VIEW public.const_geo_zone_check_points_count_view;

CREATE OR REPLACE VIEW public.const_geo_zone_check_points_count_view AS 
 SELECT
 'geo_zone_check_points_count'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
    
   FROM const_geo_zone_check_points_count t;

ALTER TABLE public.const_geo_zone_check_points_count_view
  OWNER TO beton;

DROP VIEW public.const_grid_rows_per_page_count_view;

CREATE OR REPLACE VIEW public.const_grid_rows_per_page_count_view AS 
 SELECT
 'grid_rows_per_page_count'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
    
   FROM const_grid_rows_per_page_count t;

ALTER TABLE public.const_grid_rows_per_page_count_view
  OWNER TO beton;

DROP VIEW public.const_lab_days_for_avg_view;

CREATE OR REPLACE VIEW public.const_lab_days_for_avg_view AS 
 SELECT
 'lab_days_for_avg'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
    
   FROM const_lab_days_for_avg t;

ALTER TABLE public.const_lab_days_for_avg_view
  OWNER TO beton;

DROP VIEW public.const_lab_min_sample_count_view;

CREATE OR REPLACE VIEW public.const_lab_min_sample_count_view AS 
 SELECT
 'lab_min_sample_count'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_lab_min_sample_count t;

ALTER TABLE public.const_lab_min_sample_count_view
  OWNER TO beton;

DROP VIEW public.const_map_default_lat_view;

CREATE OR REPLACE VIEW public.const_map_default_lat_view AS 
 SELECT
 'map_default_lat'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_map_default_lat t;

ALTER TABLE public.const_map_default_lat_view
  OWNER TO beton;

DROP VIEW public.const_map_default_lon_view;

CREATE OR REPLACE VIEW public.const_map_default_lon_view AS 
 SELECT
 'map_default_lon'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_map_default_lon t;

ALTER TABLE public.const_map_default_lon_view
  OWNER TO beton;

DROP VIEW public.const_max_hour_load_view;

CREATE OR REPLACE VIEW public.const_max_hour_load_view AS 
 SELECT
 'max_hour_load'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_max_hour_load t;

ALTER TABLE public.const_max_hour_load_view
  OWNER TO beton;

DROP VIEW public.const_max_vehicle_at_work_view;

CREATE OR REPLACE VIEW public.const_max_vehicle_at_work_view AS 
 SELECT
 'max_vehicle_at_work'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_max_vehicle_at_work t;

ALTER TABLE public.const_max_vehicle_at_work_view
  OWNER TO beton;

DROP VIEW public.const_min_demurrage_time_view;

CREATE OR REPLACE VIEW public.const_min_demurrage_time_view AS 
 SELECT
 	'min_demurrage_time'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_min_demurrage_time t;

ALTER TABLE public.const_min_demurrage_time_view
  OWNER TO beton;

DROP VIEW public.const_min_quant_for_ship_coast_view;

CREATE OR REPLACE VIEW public.const_min_quant_for_ship_coast_view AS 
 SELECT
 'min_quant_for_ship_coast'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_min_quant_for_ship_coast t;

ALTER TABLE public.const_min_quant_for_ship_coast_view
  OWNER TO beton;

DROP VIEW public.const_no_tracker_signal_warn_interval_view;

CREATE OR REPLACE VIEW public.const_no_tracker_signal_warn_interval_view AS 
 SELECT
 'const_no_tracker_signal_warn_interval'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_no_tracker_signal_warn_interval t;

ALTER TABLE public.const_no_tracker_signal_warn_interval_view
  OWNER TO beton;

DROP VIEW public.const_ord_mark_if_no_ship_time_view;

CREATE OR REPLACE VIEW public.const_ord_mark_if_no_ship_time_view AS 
 SELECT
 'const_ord_mark_if_no_ship_time'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_ord_mark_if_no_ship_time t;

ALTER TABLE public.const_ord_mark_if_no_ship_time_view
  OWNER TO beton;

DROP VIEW public.const_order_auto_place_tolerance_view;

CREATE OR REPLACE VIEW public.const_order_auto_place_tolerance_view AS 
 SELECT
 'const_order_auto_place_tolerance'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_order_auto_place_tolerance t;

ALTER TABLE public.const_order_auto_place_tolerance_view
  OWNER TO beton;

DROP VIEW public.const_order_step_min_view;

CREATE OR REPLACE VIEW public.const_order_step_min_view AS 
 SELECT
 	'const_order_step_min'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_order_step_min t;

ALTER TABLE public.const_order_step_min_view
  OWNER TO beton;


DROP VIEW public.const_own_vehicles_feature_view;

CREATE OR REPLACE VIEW public.const_own_vehicles_feature_view AS 
 SELECT
 	'const_own_vehicles_feature'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_own_vehicles_feature t;

ALTER TABLE public.const_own_vehicles_feature_view
  OWNER TO beton;

 DROP VIEW public.const_raw_mater_plcons_rep_def_days_view;

CREATE OR REPLACE VIEW public.const_raw_mater_plcons_rep_def_days_view AS 
 SELECT
 	'const_raw_mater_plcons_rep_def_days'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_raw_mater_plcons_rep_def_days t;

ALTER TABLE public.const_raw_mater_plcons_rep_def_days_view
  OWNER TO beton;

DROP VIEW public.const_self_ship_dest_id_view;

CREATE OR REPLACE VIEW public.const_self_ship_dest_id_view AS 
 SELECT
 	'const_self_ship_dest_id'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_self_ship_dest_id t;

ALTER TABLE public.const_self_ship_dest_id_view
  OWNER TO beton;

-- View: public.const_self_ship_dest_view

 DROP VIEW public.const_self_ship_dest_view;

CREATE OR REPLACE VIEW public.const_self_ship_dest_view AS 
 SELECT
 'const_self_ship_dest'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
   FROM const_self_ship_dest t
    ;

ALTER TABLE public.const_self_ship_dest_view
  OWNER TO beton;

DROP VIEW public.const_shift_for_orders_length_time_view;

CREATE OR REPLACE VIEW public.const_shift_for_orders_length_time_view AS 
 SELECT
 	'const_shift_for_orders_length_time'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_shift_for_orders_length_time t;

ALTER TABLE public.const_shift_for_orders_length_time_view
  OWNER TO beton;


 DROP VIEW public.const_shift_length_time_view;

CREATE OR REPLACE VIEW public.const_shift_length_time_view AS 
 SELECT
 'const_shift_length_time'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_shift_length_time t;

ALTER TABLE public.const_shift_length_time_view
  OWNER TO beton;

DROP VIEW public.const_ship_coast_for_self_ship_destination_view;

CREATE OR REPLACE VIEW public.const_ship_coast_for_self_ship_destination_view AS 
 SELECT
 'ship_coast_for_self_ship_destination'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_ship_coast_for_self_ship_destination t;

ALTER TABLE public.const_ship_coast_for_self_ship_destination_view
  OWNER TO beton;

DROP VIEW public.const_speed_change_for_order_autolocate_view;

CREATE OR REPLACE VIEW public.const_speed_change_for_order_autolocate_view AS 
 SELECT
 	'const_speed_change_for_order_autolocate'::text AS id,
 t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_speed_change_for_order_autolocate t;

ALTER TABLE public.const_speed_change_for_order_autolocate_view
  OWNER TO beton;

DROP VIEW public.const_vehicle_unload_time_view;

CREATE OR REPLACE VIEW public.const_vehicle_unload_time_view AS 
 SELECT
 	'const_vehicle_unload_time'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_vehicle_unload_time t;

ALTER TABLE public.const_vehicle_unload_time_view
  OWNER TO beton;

DROP VIEW const_tracker_service_cel_phone_view;
CREATE OR REPLACE VIEW public.const_tracker_service_cel_phone_view AS 
 SELECT
 	'const_tracker_service_cel_phone'::text AS id,
 	t.name,
    t.descr,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json

   FROM const_tracker_service_cel_phone t;

ALTER TABLE public.const_tracker_service_cel_phone_view
  OWNER TO beton;



--******************************************
		--constant value table
		CREATE TABLE IF NOT EXISTS const_doc_per_page_count
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_doc_per_page_count OWNER TO beton;
		INSERT INTO const_doc_per_page_count (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Количество документов на странице'
			,'Количество документов на странице в журнале документов'
			,60
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_doc_per_page_count LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_doc_per_page_count_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_doc_per_page_count_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_doc_per_page_count SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_doc_per_page_count_set_val(Int) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_doc_per_page_count_view AS
		SELECT
			'doc_per_page_count'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_doc_per_page_count AS t
		;
		ALTER VIEW const_doc_per_page_count_view OWNER TO beton;
		--constant value table
		CREATE TABLE IF NOT EXISTS const_grid_refresh_interval
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_grid_refresh_interval OWNER TO beton;
		INSERT INTO const_grid_refresh_interval (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Период обновления таблиц'
			,'Период обновления таблиц в секундах'
			,15
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_grid_refresh_interval LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_grid_refresh_interval_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_grid_refresh_interval SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_grid_refresh_interval_set_val(Int) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_grid_refresh_interval_view AS
		SELECT
			'grid_refresh_interval'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_grid_refresh_interval AS t
		;
		ALTER VIEW const_grid_refresh_interval_view OWNER TO beton;
		CREATE OR REPLACE VIEW constants_list_view AS
		SELECT *
		FROM const_doc_per_page_count_view
		UNION ALL
		SELECT *
		FROM const_grid_refresh_interval_view
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
		FROM const_min_quant_for_ship_coast_view
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
		FROM const_tracker_service_cel_phone_view
		UNION ALL
		SELECT *
		FROM const_vehicle_unload_time_view
		UNION ALL
		SELECT *
		FROM const_grid_rows_per_page_count_view
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
		FROM const_city_ext_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	




