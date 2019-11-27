-- Function: vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp)

-- DROP FUNCTION vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp);

CREATE OR REPLACE FUNCTION vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp)
  RETURNS int AS
$$
	-- выбираем из in_production_descr только числа
	-- находим авто с маской %in_production_descr% и назначенное в диапазоне получаса
	SELECT vh.id
	FROM shipments AS sh
	LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
	WHERE
		sh.date_time BETWEEN in_date_time-'60 minutes'::interval AND in_date_time
		AND vh.plate LIKE '%'||regexp_replace(in_production_descr, '\D','','g')||'%'
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp) OWNER TO ;
