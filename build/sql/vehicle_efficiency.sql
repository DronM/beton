-- Function: vehicle_efficiency(timestamp without time zone, timestamp without time zone, integer, character varying, character varying, integer, integer)

-- DROP FUNCTION vehicle_efficiency(timestamp without time zone, timestamp without time zone, integer, character varying, character varying, integer, integer);

CREATE OR REPLACE FUNCTION vehicle_efficiency(
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone,
    IN in_vehicle_id integer,
    IN in_vehicle_owner character varying,
    IN in_vehicle_feature character varying,
    IN in_run_type integer,
    IN in_shift_type integer)
  RETURNS TABLE(
  	rep_date_time_from timestamp without time zone,
  	rep_date_time_to timestamp without time zone,
  	vehicle_descr character varying,
  	vehicle_owner_descr character varying,
  	vehicle_feature character varying,
  	date_descr text,
  	runs bigint,
  	shifts_with_runs integer,
  	shipped_quant numeric,
  	ship_cost numeric,
  	on_shift boolean
  	) AS
$BODY$	
	WITH
	shift_start_time AS (SELECT const_first_shift_start_time_val()::interval AS v),
	shift_end_time AS (SELECT const_first_shift_start_time_val()::interval + const_day_shift_length_val()::interval AS v)
	SELECT
		date_time_from AS rep_date_time_from,
		date_time_from+constant_shift_length_time() - '00:00:01'::time AS rep_date_time_to,
		sh.plate AS vehicle_descr,
		sh.owner AS vehicle_owner_descr,
		sh.feature AS vehicle_feature,
		dow_descr_short(date_time_from::date)::text AS date_descr,
		--*** RUNS ****
		CASE 
			WHEN in_run_type=0 THEN coalesce(SUM(sh.runs)::bigint,0)
			WHEN in_run_type=1 THEN coalesce(SUM(sh.runs_day)::bigint,0)
			WHEN in_run_type=2 THEN coalesce(SUM(sh.runs_night)::bigint,0)
			ELSE 0
		END AS runs,		
		--*** RUNS ****
				
		--*** SHIFTS WITH RUNS ****
		CASE 
			WHEN in_run_type=0 THEN coalesce(SUM(sh.shifts_with_runs)::int,0)
			WHEN in_run_type=1 THEN coalesce(SUM(sh.shifts_with_runs_day)::int,0)
			WHEN in_run_type=2 THEN coalesce(SUM(sh.shifts_with_runs_night)::int,0)
			ELSE 0
		END AS shifts_with_runs,		
		--*** SHIFTS WITH RUNS ****

		--*** quant ****
		CASE			
			WHEN in_run_type=0 THEN coalesce(SUM(sh.shipped_quant),0)::numeric
			WHEN in_run_type=1 THEN coalesce(SUM(sh.shipped_quant_day),0)::numeric
			WHEN in_run_type=2 THEN coalesce(SUM(sh.shipped_quant_night),0)::numeric
			ELSE 0
		END AS shipped_quant,
		--*** quant ****

		--*** ship cost ****
		CASE 
			WHEN in_run_type=0 THEN coalesce(SUM(sh.ship_cost),0)::numeric
			WHEN in_run_type=1 THEN coalesce(SUM(sh.ship_cost_day),0)::numeric
			WHEN in_run_type=2 THEN coalesce(SUM(sh.ship_cost_night),0)::numeric
			ELSE 0
		END AS ship_cost,		
		--*** ship cost ****

		--*** average ****
		/*
		CASE
			WHEN in_run_type=0 THEN AVG(SUM(sh.runs)) OVER (PARTITION BY date_time_from)
			WHEN in_run_type=1 THEN AVG(SUM(sh.runs_day)) OVER (PARTITION BY date_time_from)
			WHEN in_run_type=2 THEN AVG(SUM(sh.runs_night)) OVER (PARTITION BY date_time_from)
			ELSE 0
		END AS runs_avg,
		*/
		--*** average ****
		
		--get_working_ratio(date_time_from::date) AS working_ratio,
		/*
		CASE
			WHEN in_run_type=0 THEN AVG(SUM(sh.ship_cost)) OVER (PARTITION BY date_time_from)
			WHEN in_run_type=1 THEN AVG(SUM(sh.ship_cost_day)) OVER (PARTITION BY date_time_from)
			WHEN in_run_type=2 THEN AVG(SUM(sh.ship_cost_night)) OVER (PARTITION BY date_time_from)
			ELSE 0
		END AS ship_cost_avg,
		*/
		--*** average cost ****

		(SELECT SUM(sh.is_shift)>0) AS on_shift
		
	FROM generate_series(in_date_time_from, in_date_time_to,'1 day') AS date_time_from
	LEFT JOIN (
		(SELECT
			detail_ships.vehicle_id,
			detail_ships.plate,
			detail_ships.owner,
			detail_ships.feature,
			(SELECT d1 FROM get_shift_bounds(detail_ships.ship_date_time) AS (d1 timestamp,d2 timestamp)) AS shift_start,	
			SUM(detail_ships.shipped_quant) AS shipped_quant,
			SUM(detail_ships.runs) AS runs,
			SUM(detail_ships.runs_day) AS runs_day,
			SUM(detail_ships.runs_night) AS runs_night,
			SUM(detail_ships.shipped_quant_day) AS shipped_quant_day,
			SUM(detail_ships.shipped_quant_night) AS shipped_quant_night,
			CASE
				WHEN SUM(detail_ships.shipped_quant)>0 THEN 1
				ELSE 0
			END AS shifts_with_runs,			
			CASE
				WHEN SUM(detail_ships.shipped_quant_day)>0 THEN 1
				ELSE 0
			END AS shifts_with_runs_day,
			CASE
				WHEN SUM(detail_ships.shipped_quant_night)>0 THEN 1
				ELSE 0
			END AS shifts_with_runs_night,

			SUM(detail_ships.ship_cost) AS ship_cost,
			SUM(detail_ships.ship_cost_day) AS ship_cost_day,
			SUM(detail_ships.ship_cost_night) AS ship_cost_night,

			0::int AS is_shift
		
		FROM
		(
			SELECT shipments.ship_date_time,v.plate,v.owner,v.feature,v.id AS vehicle_id,
			shipments.quant::numeric AS shipped_quant,
			1 AS runs,
			
			CASE
				WHEN shipments.ship_date_time::time >= (SELECT v FROM shift_start_time) AND shipments.ship_date_time::time < (SELECT v FROM shift_end_time) THEN shipments.quant
				ELSE 0
			END AS shipped_quant_day,
			CASE
				WHEN shipments.ship_date_time::time >= (SELECT v FROM shift_end_time) OR shipments.ship_date_time::time < (SELECT v FROM shift_start_time) THEN shipments.quant
				ELSE 0
			END AS shipped_quant_night,
			CASE
				WHEN shipments.ship_date_time::time >= (SELECT v FROM shift_start_time) AND shipments.ship_date_time::time < (SELECT v FROM shift_end_time) THEN 1
				ELSE 0
			END AS runs_day,
			CASE
				WHEN shipments.ship_date_time::time >= (SELECT v FROM shift_end_time) OR shipments.ship_date_time::time < (SELECT v FROM shift_start_time) THEN 1
				ELSE 0
			END AS runs_night,

			calc_ship_coast(shipments, dest, false) AS ship_cost,
			
			CASE
				WHEN shipments.ship_date_time::time >= (SELECT v FROM shift_start_time) AND shipments.ship_date_time::time < (SELECT v FROM shift_end_time)
					THEN calc_ship_coast(shipments, dest, false)
				ELSE 0
			END AS ship_cost_day,
			CASE
				WHEN shipments.ship_date_time::time >= (SELECT v FROM shift_end_time) OR shipments.ship_date_time::time < (SELECT v FROM shift_start_time)
					THEN calc_ship_coast(shipments, dest, false)
				ELSE 0
			END AS ship_cost_night
			
			
			FROM shipments
			LEFT OUTER JOIN vehicle_schedules As vs ON vs.id = shipments.vehicle_schedule_id
			LEFT OUTER JOIN vehicles As v ON v.id = vs.vehicle_id
			LEFT OUTER JOIN orders AS o ON o.id = shipments.order_id
			LEFT OUTER JOIN destinations AS dest ON dest.id = o.destination_id
			WHERE shipments.ship_date_time BETWEEN in_date_time_from AND in_date_time_to
				AND (in_vehicle_id=0 OR vs.vehicle_id=in_vehicle_id)
				AND ( (in_vehicle_feature IS NULL OR in_vehicle_feature='') OR (lower(v.feature) =lower(in_vehicle_feature)) )
				AND ( (in_vehicle_owner IS NULL OR in_vehicle_owner='') OR (lower(v.owner) =lower(in_vehicle_owner)) )			
		) AS detail_ships
		GROUP BY detail_ships.vehicle_id,detail_ships.plate,detail_ships.owner,detail_ships.feature,shift_start
		)
		
		UNION ALL

		(SELECT
			vehicles.id,
			vehicles.plate,
			vehicles.owner,
			vehicles.feature,
			(SELECT d1 FROM get_shift_bounds((vehicle_schedules.schedule_date+(SELECT v FROM shift_start_time))::timestamp without time zone) AS (d1 timestamp,d2 timestamp)) AS shift_start,	
			0 AS shipped_quant,
			0 AS runs,
			0 AS runs_day,
			0 AS runs_night,
			0 AS shipped_quant_day,
			0 AS shipped_quant_night,
			0 AS shifts_with_runs,
			0 AS shifts_with_runs_day,
			0 AS shifts_with_runs_night,
			0 AS ship_cost,
			0 AS ship_cost_day,
			0 AS ship_cost_day_night,
			1 AS is_shift
		FROM vehicle_schedule_states
		LEFT JOIN vehicle_schedules ON vehicle_schedules.id=vehicle_schedule_states.schedule_id
		LEFT JOIN vehicles ON vehicles.id=vehicle_schedules.vehicle_id
		WHERE (vehicle_schedules.schedule_date BETWEEN in_date_time_from::date AND in_date_time_to::date)
			AND vehicle_schedule_states.state='shift'::vehicle_states
			AND (in_vehicle_id=0 OR vehicles.id=in_vehicle_id)
			AND ( (in_vehicle_feature IS NULL OR in_vehicle_feature='') OR (lower(vehicles.feature) =lower(in_vehicle_feature)) )
			AND ( (in_vehicle_owner IS NULL OR in_vehicle_owner='') OR (lower(vehicles.owner) =lower(in_vehicle_owner)) )			
		)	
		
		
	) AS sh ON sh.shift_start = date_time_from	
	WHERE sh.plate IS NOT NULL
	GROUP BY date_time_from,rep_date_time_to,sh.plate,sh.owner,sh.feature,date_descr
	HAVING (in_shift_type=0 OR ((in_shift_type=1 AND SUM(sh.is_shift)>0) OR (in_shift_type=2 AND SUM(sh.is_shift)=0)) )
	ORDER BY rep_date_time_from;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION vehicle_efficiency(timestamp without time zone, timestamp without time zone, integer, character varying, character varying, integer, integer)
  OWNER TO beton;

