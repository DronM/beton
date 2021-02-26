
	-- ********** constant value table  doc_per_page_count *************
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
	INSERT INTO const_order_grid_refresh_interval (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Период обновления таблицы с заявками'
		,'Период обновления таблицы с заявками в секундах'
		,5
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_backup_vehicles_feature (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Свойство - запасные автомобили'
		,'Автомобили с таким значением свойств являются запасными'
		,
			'запас'
		,'String'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_base_geo_zone_id (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Код зоны завода'
		,''
		,0
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_base_geo_zone (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Зона завода'
		,''
		,0
		,'Ref'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_chart_step_min (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Шаг для графика (минут)'
		,'Определяет значение в минутах с каким шагом отрисовывать график'
		,60
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_day_shift_length (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Интервал дневной смены'
		,'Используется для расчета разных значений, например 13 часов, если день считается с 7-00 до 20-00'
		,
			'13:00'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_days_allowed_with_broken_tracker (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Сколько дней будет разрешена отгрузка со сломанным трэкером'
		,''
		,5
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_def_order_unload_speed (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Скорость разгрузки (куб/час)'
		,'Для подстановки в заявку по умолчанию'
		,15
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_demurrage_coast_per_hour (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Стоимость часа простоя (руб.)'
		,''
		,500
		,'Float'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_first_shift_start_time (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Время начало первой смены'
		,''
		,
			'07:00'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_geo_zone_check_points_count (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Количество точек с терминала для проверки вхождения в зону'
		,'Задает количество точек с данными (долгота и широта) для проверки вхождения автомобиля в геозону'
		,3
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_map_default_lat (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Широта для позиционирования карты по умолчанию'
		,'Задает географическую широту в формате хххх.хххх'
		,
			'5708.2928'
		,'String'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_map_default_lon (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Долгота для позиционирования карты по умолчанию'
		,'Задает географическую широту в формате ххххх.хххх'
		,
			'06533.0345'
		,'String'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_max_hour_load (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Максимальная загрузка завода (куб/час)'
		,''
		,40
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_max_vehicle_at_work (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Максимальное количество автомобилей на линии'
		,''
		,20
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_min_demurrage_time (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Минимальное время простоя'
		,'Минимальное значение времени за которое считается простой'
		,
			'00:05'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_min_quant_for_ship_cost (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Минимальный объем (м3) для расчета цены доставки'
		,''
		,5
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_no_tracker_signal_warn_interval (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Интервал, по истечении которого выводится сообщение о неисправном трекере'
		,''
		,
			'01:00'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_ord_mark_if_no_ship_time (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Выделение цветом заявок при отсутствии отгрузок более данного времени'
		,'Если не было отгрузок более данного времени, то заявка будет подсвечена'
		,
			'01:00'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_order_auto_place_tolerance (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Погрешность для автоматического размещения заявок (м3)'
		,''
		,10
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_order_step_min (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Шаг между заявками'
		,'Шаг в минутах между заявками'
		,30
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_own_vehicles_feature (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Значение свойства свои автомобили'
		,'Автомобили с тавим значением свойства считаются своими'
		,
			'основ'
		,'String'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_self_ship_dest_id (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Код объекта самовывоз'
		,''
		,0
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_self_ship_dest (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Объект самовывоз'
		,''
		,0
		,'Ref'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_shift_for_orders_length_time (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Длительность смены для заявок'
		,''
		,
			'17:00'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_shift_length_time (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Длительность смены для заявок'
		,'Продолжительность смены'
		,
			'24:00'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_ship_coast_for_self_ship_destination (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Стоимость доставки (руб.) для объекта самовывоз'
		,''
		,3500
		,'Float'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_speed_change_for_order_autolocate (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Уровень изменения скорости (%) при автоматическом подборе времени для заявки'
		,''
		,10
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_vehicle_unload_time (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Время разгрузки автомобиля'
		,'Используется для расчета времени возврата автомобиля'
		,
			'01:00'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_avg_mat_cons_dev_day_count (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Количество дней для расчета среднего отлонения расхода материалов от нормы'
		,'Среднее отклонение расхода материалов от нормы расчитывается автоматически за данное количество дней.'
		,10
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_days_for_plan_procur (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Количество дней для расчета плановых остатков'
		,'Данное количество дней используется при расчете средних показателей (отгрузка бетона,расход материалов) при планировании закупок'
		,10
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_lab_min_sample_count (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Минимальное количество отборов для лаборатории'
		,''
		,0
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_lab_days_for_avg (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Количество дней для выборки для рассчета средних значений'
		,'Используется в главной форме лаборанта для расчета средних значений'
		,28
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_city_ext (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Код города'
		,'Используется для исходящих звонков'
		,
			'3452'
		,'String'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_def_lang (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Язык по умолчанию'
		,'Основной язык для подстановки в заявку'
		,NULL
		,'JSON'
		,NULL
		,NULL
		,NULL
		,NULL
	);
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
	INSERT INTO const_zone_violation_alarm_interval (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Интервал оповещения о въезде в запрещенную зону'
		,''
		,
			'01:00'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_weather_update_interval_sec (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Интервал в секундах обновления данных о погоде'
		,''
		,
			'00:30'
		,'Time'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_call_history_count (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Количество строк в истории при новом звонке'
		,'Сколько последних отгрузок ипоследних звонков показывать при входящем звонке'
		,5
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_water_ship_cost (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Стоимость доставки воды'
		,'Стоимость доставки воды'
		,2000
		,'Float'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_vehicle_owner_accord_from_day (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Номер дня месяца'
		,'Номер дня месяца, начиная с которого владельцы ТС могу согласовывать отгрузки за предыдущий месяц'
		,5
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_vehicle_owner_accord_to_day (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Номер дня месяца'
		,'Номер дня месяца, до которого владельцы ТС могу согласовывать отгрузки за предыдущий месяц'
		,20
		,'Int'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_show_time_for_shipped_vehicles (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Время показа отргруженных ТС'
		,'Время, в течении которого показывать отгруженные ТС на большом экране'
		,
			'00:30'
		,'Interval'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_tracker_malfunction_tel_list (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Список телефонов для сообщений о неисправном трекере'
		,'На какие телефоны отправлять сообщение о неработающих трекерах'
		,NULL
		,'JSON'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_low_efficiency_tel_list (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Список телефонов для сообщений о низком состоянии эффективности'
		,'На какие телефоны отправлять сообщение о низком состоянии эффективности'
		,NULL
		,'JSON'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_material_closed_balance_date (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Дата закрытого периода остатков'
		,'Дата, раньше который период закрыт для редактирования'
		,NULL
		,'Date'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_cement_material (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Материал цемент'
		,'Материал цемент'
		,5
		,'Ref'
		,NULL
		,NULL
		,NULL
		,NULL
	);
	INSERT INTO const_deviation_for_reroute (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
		'Отклонение от маршрута для перестраивания'
		,'Определяет параметры для перестраивания маршрута'
		,NULL
		,'JSON'
		,NULL
		,NULL
		,NULL
		,NULL
	);

