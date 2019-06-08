-- Function: public.raw_material_total_report(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION public.raw_material_total_report(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.raw_material_total_report(
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone)
  RETURNS TABLE(date_time timestamp without time zone, date_time_descr text, material_id integer, quant_shipment numeric, quant_beg numeric, quant_procur numeric, quant_consump numeric, quant_end numeric, quant_correct numeric) AS
$BODY$
	/*
	v_shift_for_avg_from = get_shift_start(now()::timestamp without time zone-(const_days_for_plan_procur_val()||' days')::interval);
	v_shift_for_avg_to = get_shift_end(get_shift_start(now()::timestamp without time zone)-'1 day'::interval);
	v_sunday_shift_end = get_shift_end(get_shift_start( in_date_time_to +((7-EXTRACT(DOW FROM in_date_time_to)+1::int)||' days')::interval));
	v_plan_shift_start = get_shift_end(get_shift_start(now()::timestamp without time zone))+'1 second';
	*/
	WITH
		/* КОНСТАНТЫ */
		shift_for_avg_from AS (
		SELECT get_shift_start(now()::timestamp without time zone-(const_days_for_plan_procur_val()||' days')::interval) AS shift
		),
		shift_cur_from AS (
		SELECT get_shift_start(now()::timestamp without time zone) AS shift
		),		
		shift_for_avg_to AS (
		SELECT get_shift_end(
			(SELECT t.shift FROM shift_cur_from t) - 
			'1 day'::interval) AS shift
		),
		sunday_shift_to AS (
		SELECT get_shift_end(get_shift_start($2+((7-EXTRACT(DOW FROM $2)+1::int)||' days')::interval)) AS shift
		),
		
		/* список материалов с нужными колонками */
		mat_list AS (
			SELECT id,supply_days_count,name,ord
			FROM raw_materials
			WHERE concrete_part=TRUE
		),

		/* все смены и все материалы */
		shifts_mat AS (
			SELECT
				shift,
				m.id AS material_id,
				m.supply_days_count,
				m.name AS material_descr,
				m.ord
			FROM generate_series(
				$1,
				(SELECT t.shift FROM sunday_shift_to t),
				'24 hours') AS shift
			CROSS JOIN (
				SELECT * FROM mat_list
				) AS m
		),
		
		plan_procur AS (
			SELECT * FROM mat_plan_procur(
				(SELECT t.shift FROM sunday_shift_to t),
				(SELECT t.shift FROM shift_for_avg_from t),
				(SELECT t.shift FROM shift_for_avg_to t),
				NULL
				)
		),
		/* Выпуск бетона по дням + средний выпуск
		за пред. X дней по будущим датам*/
		ship AS (
			(SELECT
				get_shift_start(sh.ship_date_time) AS shift,
				COALESCE(SUM(sh.quant::numeric),0) AS quant				
			FROM shipments AS sh			
			WHERE sh.ship_date_time BETWEEN $1 AND $2
			GROUP BY shift
			)
			
			UNION
			(SELECT
				pp.shift,
				pp.concrete_avg_quant AS quant
			FROM plan_procur AS pp
			)
		),
		
		/* Подробная таблица с движением материалов 
		за период*/
		mat_acts AS 
		(SELECT
			ra.date_time,
			ra.deb,
			ra.material_id,
			ra.quant,
			ra.doc_type,
			ra.doc_id
		FROM ra_materials AS ra
		WHERE ra.date_time BETWEEN $1 AND $2
			AND ra.material_id IN (SELECT id FROM mat_list)
		),

		/*Расход материалов за тек смену
		*/
		/*
		mat_cur_shift_cons AS 
		(SELECT
			ra.material_id,
			SUM(ra.quant) AS quant
		FROM ra_materials AS ra
		WHERE ra.date_time BETWEEN
			(SELECT t.shift FROM shift_cur_from t)
			AND get_shift_end((SELECT t.shift FROM shift_cur_from t))
			AND ra.material_id IN (SELECT id FROM mat_list)
		GROUP BY ra.material_id
		),
		*/
		
		/* Расход материала свернуто по сменам
		+ плановый расход по будущим датам*/
		consumption AS 
		(	(SELECT
				get_shift_start(cons.date_time) AS shift,
				cons.material_id,
				SUM(quant) AS quant
			FROM mat_acts AS cons
			WHERE cons.deb=FALSE
			GROUP BY shift,cons.material_id
			)
			UNION
			(SELECT
				pp.shift,
				pp.material_id,
				pp.mat_avg_cons AS quant
			FROM plan_procur AS pp
			)			
		),

		/*Корректировки расхода материала*/
		consumption_norm AS 
		(SELECT
			get_shift_start(cons.date_time) AS shift,
			cons.material_id,SUM(quant) AS quant		
		FROM mat_acts AS cons
		WHERE cons.doc_type IS NULL
			AND cons.doc_id IS NULL
		GROUP BY shift,cons.material_id
		),

		/*Поступление материалов
		+ плановый приход по будущим датам*/
		procurement AS
		(	(SELECT
				get_shift_start(procur.date_time) AS shift,
				procur.material_id,
				SUM(quant) AS quant
			FROM mat_acts AS procur
			WHERE procur.deb=TRUE
			GROUP BY shift,procur.material_id)
			UNION
			(SELECT
				pp.shift,
				pp.material_id,
				pp.quant_to_order AS quant
			FROM plan_procur AS pp
			)			
		),

		/*Остатки материалов на начало периода*/
		rg_beg AS
		(SELECT
			rg.material_id,
			rg.quant
		FROM rg_materials_balance($1::timestamp without time zone,
			ARRAY(SELECT id FROM mat_list)) AS rg
		)

	SELECT
		sub.shift AS date_time,
		date10_descr(sub.shift::date)::text AS date_time_descr,
		sub.material_id AS material_id,

		ship.quant AS quant_shipment,
		
		--quant begining
		CASE		
			WHEN sub.shift>(SELECT t.shift FROM shift_cur_from t) THEN
				--Плановый остаток
				(SELECT p.balance_start
				FROM plan_procur p
				WHERE p.material_id=sub.material_id
					AND p.shift=sub.shift)
			ELSE
			(
				--balance
				COALESCE((SELECT rg_beg.quant FROM rg_beg WHERE rg_beg.material_id=sub.material_id),0)
				--procur before this shift
				+COALESCE((SELECT SUM(p.quant) FROM procurement AS p WHERE p.material_id=sub.material_id AND p.shift<sub.shift),0)
				--consump before this shift
				-COALESCE((SELECT SUM(c.quant) FROM consumption AS c WHERE c.material_id=sub.material_id AND c.shift<sub.shift),0)
				
			)
		END
		AS qaunt_beg,

		/* Поступление */
		COALESCE(
			(SELECT SUM(p.quant)
			FROM procurement AS p
			WHERE p.shift=sub.shift
				AND p.material_id=sub.material_id
			)
		,0) AS quant_procur,

		/* Расход */
		COALESCE(
			(SELECT SUM(quant)
			FROM consumption AS c
			WHERE c.shift=sub.shift
				AND c.material_id=sub.material_id
			)
		,0) AS quant_consump,
		
		--quant end
		(
			--balance
			CASE
			WHEN sub.shift>(SELECT t.shift FROM shift_cur_from t) THEN
				--Плановый остаток
				(SELECT p.balance_end
				FROM plan_procur p
				WHERE p.material_id=sub.material_id
					AND p.shift=sub.shift)
			ELSE
				COALESCE((SELECT rg_beg.quant FROM rg_beg WHERE rg_beg.material_id=sub.material_id),0)
				--procur before and this shift
				+COALESCE((SELECT SUM(p.quant) FROM procurement AS p WHERE p.material_id=sub.material_id AND p.shift<=get_shift_end(sub.shift)),0)
				--consump before and this shift
				-COALESCE((SELECT SUM(c.quant) FROM consumption AS c WHERE c.material_id=sub.material_id AND c.shift<=get_shift_end(sub.shift)),0)				
			END
		) AS qaunt_end,
		
		COALESCE(
			(SELECT sum(quant)
			FROM consumption_norm AS n
			WHERE n.material_id=sub.material_id
			AND sub.shift=n.shift
			)
		,0) AS quant_correct
		
	FROM shifts_mat AS sub
	LEFT JOIN ship ON ship.shift=sub.shift
	ORDER BY sub.shift,sub.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.raw_material_total_report(timestamp without time zone, timestamp without time zone)
  OWNER TO beton;

