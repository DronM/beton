<?php
require_once('db_con.php');

$dbLink->query(
	"UPDATE shipments
		SET
			owner_agreed=TRUE,
			owner_agreed_date_time=now(),
			owner_agreed_auto=TRUE
	FROM (				
	WITH
		mon AS (
			SELECT
				CASE WHEN extract('month' FROM now())=1 THEN 12
					ELSE extract('month' FROM now())-1
				END AS v
		),
		d_from AS (
			SELECT (
				(CASE WHEN (SELECT v FROM mon)=12 THEN extract('year' FROM now())-1 ELSE extract('year' FROM now()) END)::text
				||'-'|| (CASE WHEN (SELECT v FROM mon)<10 THEN '0' ELSE '' END )||(SELECT v FROM mon) ||'-01'
			)::date+
			const_first_shift_start_time_val()
			AS v
		),
		per AS (SELECT	
			(SELECT v FROM d_from) AS d_from,
			get_shift_end(
				((SELECT v FROM d_from) + '1 month'::interval -'1 day'::interval)::date+
				const_first_shift_start_time_val()
			)
			AS d_to
		)
	SELECT shipments.id AS ship_id
	FROM shipments
	WHERE 
		extract('day' FROM now())>const_vehicle_owner_accord_to_day_val()
		AND coalesce(owner_agreed,FALSE)=FALSE
		AND ship_date_time BETWEEN (SELECT d_from FROM per) AND (SELECT d_to FROM per)
	) AS sub
	WHERE sub.ship_id = shipments.id"
);

$dbLink->query(
	"UPDATE shipments
		SET
			owner_pump_agreed=TRUE,
			owner_pump_agreed_date_time=now(),
			owner_pump_agreed_auto=TRUE
	FROM (				
	WITH
		mon AS (
			SELECT
				CASE WHEN extract('month' FROM now())=1 THEN 12
					ELSE extract('month' FROM now())-1
				END AS v
		),
		d_from AS (
			SELECT (
				(CASE WHEN (SELECT v FROM mon)=12 THEN extract('year' FROM now())-1 ELSE extract('year' FROM now()) END)::text
				||'-'|| (CASE WHEN (SELECT v FROM mon)<10 THEN '0' ELSE '' END )||(SELECT v FROM mon) ||'-01'
			)::date+
			const_first_shift_start_time_val()
			AS v
		),
		per AS (SELECT	
			(SELECT v FROM d_from) AS d_from,
			get_shift_end(
				((SELECT v FROM d_from) + '1 month'::interval -'1 day'::interval)::date+
				const_first_shift_start_time_val()
			)
			AS d_to
		)
	SELECT shipments.id AS ship_id
	FROM shipments
	WHERE 
		extract('day' FROM now())>const_vehicle_owner_accord_to_day_val()
		AND coalesce(owner_pump_agreed,FALSE)=FALSE
		AND ship_date_time BETWEEN (SELECT d_from FROM per) AND (SELECT d_to FROM per)
	) AS sub
	WHERE sub.ship_id = shipments.id"
);

?>
