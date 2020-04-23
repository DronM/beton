-- Function: public.rg_material_facts_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_material_facts_balance(
    IN in_date_time timestamp without time zone,
    IN in_material_id_ar integer[])
  RETURNS TABLE(material_id integer, quant numeric) AS
$BODY$
	WITH
	cur_per AS (SELECT rg_period('material_fact'::reg_types, in_date_time) AS v ),
	act_forward AS (
		SELECT
			rg_period_balance('material_fact'::reg_types,in_date_time) - in_date_time >
			(SELECT t.v FROM cur_per t) - in_date_time
			AS v
	),
	act_sg AS (SELECT CASE WHEN t.v THEN 1 ELSE -1 END AS v FROM act_forward t),
	last_calc_per AS (SELECT rg_period_balance('material_fact'::reg_types,rg_calc_period('material_fact'::reg_types)) AS v)
	SELECT 
	sub.material_id
	,SUM(sub.quant) AS quant				
	FROM(
		(SELECT
		b.material_id
		,b.quant				
		FROM rg_material_facts AS b
		WHERE
		(
			--date bigger than last calc period
			(in_date_time > (SELECT v FROM last_calc_per) AND b.date_time = (SELECT rg_current_balance_time()))
			OR (
				in_date_time < (SELECT v FROM last_calc_per)
				AND (
					--forward from previous period
					( (SELECT t.v FROM act_forward t) AND b.date_time = (SELECT t.v FROM cur_per t)-rg_calc_interval('material_fact'::reg_types)
					)
					--backward from current
					OR			
					( NOT (SELECT t.v FROM act_forward t) AND b.date_time = (SELECT t.v FROM cur_per t)				
					)
				)
			)
		)	
		AND ( (in_material_id_ar IS NULL OR ARRAY_LENGTH(in_material_id_ar,1) IS NULL) OR (b.material_id=ANY(in_material_id_ar)))
		AND (
		b.quant<>0
		)
		)
		UNION ALL
		(SELECT
		act.material_id
		,CASE act.deb
			WHEN TRUE THEN act.quant * (SELECT t.v FROM act_sg t)
			ELSE -act.quant * (SELECT t.v FROM act_sg t)
		END AS quant
		FROM doc_log
		LEFT JOIN ra_material_facts AS act ON act.doc_type=doc_log.doc_type AND act.doc_id=doc_log.doc_id
		WHERE
		(
			--forward from previous period
			( (SELECT t.v FROM act_forward t) AND
					act.date_time >= (SELECT t.v FROM cur_per t)
					AND act.date_time <= 
						(SELECT l.date_time FROM doc_log l
						WHERE date_trunc('second',l.date_time)<=date_trunc('second',in_date_time)
						ORDER BY l.date_time DESC LIMIT 1
						)
			)
			--backward from current
			OR			
			( NOT (SELECT t.v FROM act_forward t) AND
					act.date_time >= 
						(SELECT l.date_time FROM doc_log l
						WHERE date_trunc('second',l.date_time)>=date_trunc('second',in_date_time)
						ORDER BY l.date_time ASC LIMIT 1
						)			
					AND act.date_time <= (SELECT t.v FROM cur_per t)
			)
		)
		AND (in_material_id_ar IS NULL OR ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (act.material_id=ANY(in_material_id_ar)))
		AND (
		act.quant<>0
		)
		ORDER BY doc_log.date_time,doc_log.id)
	) AS sub
	WHERE
	 (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (sub.material_id=ANY(in_material_id_ar)))
	GROUP BY
		sub.material_id
	HAVING
		SUM(sub.quant)<>0
	ORDER BY
		sub.material_id;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[])
  OWNER TO beton;

