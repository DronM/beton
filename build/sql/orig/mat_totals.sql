-- Function: public.mat_totals(date)

-- DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_fact_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	quant_morn_fact_cur_balance numeric,
  	balance_corrected_data json
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		
		COALESCE(bal_fact.quant,0)::numeric AS quant_fact_balance,
		
		--остатки на завтра на утро
		-- начиная с 12/08/20 без прогноза будующего прихода, просто тек.остаток-расход по подборам от тек.времени до конца смены
		--COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		--COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		COALESCE(bal_fact.quant,0) - COALESCE(mat_virt_cons.quant,0) AS quant_morn_balance,
		COALESCE(bal_fact.quant,0) - COALESCE(mat_virt_cons.quant,0) AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		
		COALESCE(bal_morn_fact.quant,0)::numeric AS quant_morn_fact_cur_balance,
		
		--Корректировки
		(SELECT
			json_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'materials_ref',materials_ref(m),
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	LEFT JOIN (
		SELECT * FROM rg_material_facts_balance($1+const_first_shift_start_time_val(),'{}')
	) AS bal_morn_fact ON bal_morn_fact.material_id=m.id

	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	LEFT JOIN (
		--SELECT * FROM rg_material_facts_balance('{}')
		SELECT
			material_id,
			sum(quant) AS quant
		FROM rg_material_facts_balance('{}'::int[],'{}'::int[])
		GROUP BY material_id		
	) AS bal_fact ON bal_fact.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	/*
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
			get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
			now()::timestamp,
			now()::timestamp,
			NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	*/
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	LEFT JOIN (
		SELECT *
		FROM mat_virtual_consumption(
			now()::timestamp,
			$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval
		)
	) AS mat_virt_cons ON mat_virt_cons.material_id = m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO ;

