-- Function: public.mat_totals(date)

-- DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(material_id integer, material_descr text, quant_ordered numeric, quant_procured numeric, quant_balance numeric, quant_morn_balance numeric) AS
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
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance
		
	FROM raw_materials AS m
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	
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
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date)
  OWNER TO beton;

