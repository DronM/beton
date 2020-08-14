-- Function: public.mat_plan_procur(timestamp without time zone, timestamp without time zone, timestamp without time zone, integer)

-- DROP FUNCTION public.mat_plan_procur(timestamp without time zone, timestamp without time zone, timestamp without time zone, integer);

CREATE OR REPLACE FUNCTION public.mat_plan_procur(
    IN in_date_time_to timestamp without time zone,
    IN in_date_time_for_avg_from timestamp without time zone,
    IN in_date_time_for_avg_to timestamp without time zone,
    IN in_material_id integer)
RETURNS TABLE(
	shift timestamp without time zone,
	material_id integer,
	concrete_avg_quant numeric,
	balance_start numeric,
	mat_avg_cons numeric,
	quant_to_order numeric,
	balance_end numeric,
	mat_tot_cons numeric
) AS
$BODY$
DECLARE
	data_row RECORD;
	v_balance numeric;
	v_balance_beg numeric;
	v_dow integer;
	v_days_to_mon integer;
	v_sup_days_to_mon integer;
	v_material_id integer;
	v_no_sup_day boolean;
BEGIN
	v_balance = 0;
	v_material_id = 0;
	FOR data_row IN
	WITH
		shift_from AS (
			SELECT
				get_shift_end(get_shift_start(now()::timestamp))+'1 second'
				AS shift
		),
		/* Заявки на будущий период*/
		orders AS (
			SELECT
				get_shift_start(o.date_time) AS shift,
				COALESCE(SUM(o.quant)::numeric,0) AS quant
			FROM orders AS o
			WHERE o.date_time BETWEEN (SELECT t.shift FROM shift_from t) AND $1
			GROUP BY shift
		),
		
		/* Средний выпуск бетона за X дней*/
		ship_avg AS (
			SELECT
				COALESCE((CASE
					WHEN COUNT(DISTINCT get_shift_start(ship_date_time))=0 THEN 0
					ELSE ROUND((SUM(quant)/COUNT(DISTINCT get_shift_start(ship_date_time)))::numeric,2)
				END)::numeric,0) AS quant_avg,
				COALESCE(SUM(quant)::numeric,0) AS quant
			FROM shipments
			WHERE shipped=true
				AND ship_date_time BETWEEN
				$2 AND $3
		),
		
		/* список всех материалов*/
		mats AS (
			SELECT
				m.id,
				m.supply_days_count,
				m.ord,
				m.store_days,
				m.min_end_quant
			FROM raw_materials m
			WHERE (
					($4 IS NULL OR $4=0)
					AND m.concrete_part=TRUE
				)
				OR (m.id=$4)
		),
		
		/* Начало тек.смены */
		cur_shift_start AS (		
			SELECT get_shift_start(now()::timestamp without time zone) AS shift
		),
		
		/* Остатки материалов на начало периода,
		   расход материалов за период для расчета
		   средних значений,
		   средний расход за день
		*/
		mat_data AS (
			SELECT
				--Данные по материалу
				m.id AS material_id,
				m.supply_days_count,
				m.ord,
				
				/*Остаток*/
				COALESCE(bal.quant,0) AS balance,
				
				--Факт.расход за тек. смену
				COALESCE(mat_cur_shift_consump.quant,0) AS mat_cur_shift_cons,
				
				--Факт.расход за тек. смену в неотгруженных заявках
				COALESCE(mat_cur_shift_virt_consump.quant,0) AS mat_cur_shift_virt_cons,
				
				--Всего расход
				mat_cons.quant AS cons_tot,

				--Средн. расход
				CASE
					WHEN (SELECT ship_avg.quant FROM ship_avg)=0 THEN 0
					ELSE
						ROUND(
							(mat_cons.quant/
							(SELECT ship_avg.quant FROM ship_avg))
							 *
							(SELECT ship_avg.quant_avg FROM ship_avg)
						,3)
				END AS cons_avg,
				
				--ЗАПАС
				/* Ручные данные по запасу*/
				m.store_days AS user_store_days,
				
				m.min_end_quant AS user_min_end_quant
				
			FROM mats AS m
			
			--Остатки
			LEFT JOIN 
				(SELECT
					rg.material_id,
					SUM(rg.quant) AS quant
				--rg_materials_balance
				FROM rg_material_facts_balance((SELECT t.shift FROM shift_from t),
					ARRAY(SELECT m.id
						FROM mats m
						WHERE ($4 IS NULL OR $4=0) OR (m.id=$4)
					)
				) AS rg
				GROUP BY rg.material_id
				) AS bal ON bal.material_id=m.id
				
			--Расход материалов
			LEFT JOIN
				(SELECT
					cons.material_id,
					COALESCE(SUM(cons.quant)::numeric,0) AS quant
					FROM ra_materials AS cons
					WHERE
						cons.date_time BETWEEN $2 AND $3
						AND cons.deb=FALSE
						AND ($4 IS NULL OR $4=0 OR ($4=cons.material_id))
					GROUP BY cons.material_id
				) AS mat_cons ON mat_cons.material_id=m.id
				
			--Расход материала за тек.смену
			LEFT JOIN 
				(SELECT
					cons.material_id,
					COALESCE(SUM(cons.quant)::numeric,0) AS quant
					FROM ra_materials AS cons
					WHERE
						cons.date_time BETWEEN
								(SELECT cur_shift_start.shift FROM cur_shift_start)
							AND get_shift_end((SELECT cur_shift_start.shift FROM cur_shift_start))
						AND cons.deb=FALSE
						AND ($4 IS NULL OR $4=0 OR ($4=cons.material_id))
					GROUP BY cons.material_id
				) AS mat_cur_shift_consump
				ON mat_cur_shift_consump.material_id=m.id

			/** Расход материала в неотгруженных на сегодня
			 * заявках
			 */
			LEFT JOIN 
				(SELECT *
				FROM mat_cur_shift_virt_cons
				) AS mat_cur_shift_virt_consump
				ON mat_cur_shift_virt_consump.material_id=m.id							
			
		)
		
	SELECT
		sh AS shift,
		m.material_id,
		
		/* Средний V бетона:
			- либо средний за Х дней
			- либо заявки*/
		GREATEST(o.quant,
			(SELECT ship_avg.quant_avg FROM ship_avg)
		) AS concrete_avg_quant,
		
		m.cons_avg AS mat_avg_day_cons,
		
		/* Средний расход материала за смену:
			- если заявок> среднего V бетона,
				то пересчет по заявкам
		*/
		CASE
			WHEN o.quant IS NULL
				OR o.quant<=(SELECT ship_avg.quant_avg FROM ship_avg) THEN
				m.cons_avg
			ELSE
				ROUND(
					m.cons_tot/
					(SELECT ship_avg.quant FROM ship_avg)
					 *
					o.quant
				,3)
			
		END AS mat_avg_cons_fact,
		
		m.balance,
		m.mat_cur_shift_cons,
		m.mat_cur_shift_virt_cons,
		COALESCE(m.user_store_days,1) As user_store_days,
		COALESCE(m.user_min_end_quant,0) AS user_min_end_quant,
		m.supply_days_count
		
	FROM generate_series((SELECT t.shift FROM shift_from t),
			$1, '24 hours') AS sh
	CROSS JOIN mat_data AS m
	LEFT JOIN orders AS o ON o.shift=sh
	ORDER BY m.ord,sh
		
	LOOP
		shift				= data_row.shift;
		material_id			= data_row.material_id;
		concrete_avg_quant	= data_row.concrete_avg_quant;
		mat_avg_cons		= data_row.mat_avg_cons_fact;
		mat_tot_cons		= 0;
		--Расчет планового прихода
		v_dow = EXTRACT(DOW FROM data_row.shift);
		
		--Инициализация начального остатка
		IF v_material_id<>data_row.material_id THEN
			/*остаток = 
			остаток - норма/день + уже выдали за тек.смену
			*/
			--RAISE 'a=%',data_row.mat_cur_shift_virt_cons;
			v_balance = data_row.balance
				-data_row.mat_cur_shift_virt_cons;
			/*
			IF (data_row.mat_avg_day_cons>data_row.mat_cur_shift_cons) THEN
				v_balance = v_balance
					- data_row.mat_avg_day_cons 
					+ data_row.mat_cur_shift_cons;				
			END IF;
			*/
		END IF;
		balance_start = v_balance;
		
		IF (v_dow=0) THEN
			v_days_to_mon = 1;
		ELSE
			v_days_to_mon = 7 - v_dow + 1;
		END IF;
		v_sup_days_to_mon = v_days_to_mon - (7-data_row.supply_days_count);
		--Как минимум 1 день или userdefined
		v_days_to_mon = v_days_to_mon + data_row.user_store_days;
		
		--НЕТ ЗАВОЗА В ЭТОТ ДЕНЬ
		v_no_sup_day = (
			(v_dow>0 AND v_dow>data_row.supply_days_count)
			OR (v_dow=0 AND data_row.supply_days_count<7)
		);
			
		IF v_no_sup_day THEN
			quant_to_order = 0;
		ELSIF (v_balance<=data_row.mat_avg_day_cons) THEN
			quant_to_order = ROUND(
				data_row.mat_avg_day_cons -
				v_balance + 
				(v_days_to_mon*data_row.mat_avg_day_cons-data_row.mat_avg_day_cons)/
				v_sup_days_to_mon
			,3);
			IF (data_row.mat_avg_cons_fact>data_row.mat_avg_day_cons) THEN
				/*
				RAISE 'Расход=%,
				остаток=%,
				дней до пон=%,
				дней пост=%',
				data_row.mat_avg_cons_fact,
				v_balance,
				v_days_to_mon,
				v_sup_days_to_mon;
				--RAISE 'смена=%,материал=%,факт.расход=%,ср.расход=%,надо заказать=%',shift,material_id,data_row.mat_avg_cons_fact,data_row.mat_avg_day_cons,quant_to_order;
				*/
				quant_to_order = quant_to_order + (data_row.mat_avg_cons_fact-data_row.mat_avg_day_cons);				
			END IF;
		ELSIF (v_balance>data_row.mat_avg_day_cons)
		AND (v_balance<(
			v_days_to_mon*data_row.mat_avg_day_cons -
			(v_sup_days_to_mon*data_row.mat_avg_day_cons) + 
			data_row.mat_avg_day_cons
		)
		) THEN
			quant_to_order = ROUND(
				(v_days_to_mon*data_row.mat_avg_day_cons-v_balance)/
				v_sup_days_to_mon
			,3);
			IF (data_row.mat_avg_cons_fact>data_row.mat_avg_day_cons) THEN
				--RAISE '2 !!!';
				quant_to_order = quant_to_order + (data_row.mat_avg_cons_fact-data_row.mat_avg_day_cons);
			END IF;			
		ELSE
			quant_to_order = 0;
		END IF;
	
		--Новый остаток
		v_balance_beg = v_balance;
		v_balance = v_balance + quant_to_order - data_row.mat_avg_cons_fact;
		v_material_id = data_row.material_id;
		--RAISE 'quant_to_order=%',quant_to_order;
		
		balance_end = v_balance;		
		
		IF (data_row.material_id=5) THEN
			--цемент
			balance_end=GREATEST(data_row.mat_avg_cons_fact,data_row.user_min_end_quant);
			quant_to_order = balance_end-v_balance_beg+data_row.mat_avg_cons_fact;
			v_balance = balance_end;
			
		ELSIF (balance_end<data_row.user_min_end_quant
			AND v_no_sup_day=FALSE) THEN
			/*Установлен минимальный остаток
			и день завоза
			*/
			balance_end=data_row.user_min_end_quant;
			quant_to_order = balance_end-v_balance_beg+data_row.mat_avg_cons_fact;
			v_balance = balance_end;
		END IF;
		
		RETURN NEXT;
	END LOOP;
END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_plan_procur(timestamp without time zone, timestamp without time zone, timestamp without time zone, integer)
  OWNER TO beton;

