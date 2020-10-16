-- Function: public.rg_total_recalc_material_facts_mat(in_material_id integer)

-- DROP FUNCTION public.rg_total_recalc_material_facts_mat(in_material_id integer);

CREATE OR REPLACE FUNCTION public.rg_total_recalc_material_facts_mat(in_material_id integer)
  RETURNS void AS
$BODY$  
DECLARE
	period_row RECORD;
	v_act_date_time timestamp without time zone;
	v_cur_period timestamp without time zone;
BEGIN	
	v_act_date_time = reg_current_balance_time();
	SELECT date_time INTO v_cur_period FROM rg_calc_periods;
	
	FOR period_row IN
		WITH
		periods AS (
			(SELECT
				DISTINCT date_trunc('month', date_time) AS d,
				material_id,production_site_id
			FROM ra_material_facts WHERE material_id=in_material_id)
			UNION		
			(SELECT
				date_time AS d,
				material_id,production_site_id
			FROM rg_material_facts WHERE date_time<=v_cur_period AND material_id=in_material_id
			)
			ORDER BY d			
		)
		SELECT sub.d,sub.material_id,sub.production_site_id,sub.balance_fact,sub.balance_paper
		FROM
		(
		SELECT
			periods.d,
			periods.material_id,
			periods.production_site_id,
			COALESCE((
				SELECT SUM(CASE WHEN deb THEN quant ELSE 0 END)-SUM(CASE WHEN NOT deb THEN quant ELSE 0 END)
				FROM ra_material_facts AS ra WHERE ra.date_time <= last_month_day(periods.d::date)+'23:59:59'::interval
					AND ra.material_id=periods.material_id
					AND coalesce(ra.production_site_id,0)=coalesce(periods.production_site_id,0)
			),0) AS balance_fact,
			
			(
			SELECT SUM(quant) FROM rg_material_facts WHERE date_time=periods.d
				AND material_id=periods.material_id
				AND coalesce(production_site_id,0)=coalesce(periods.production_site_id,0)
			) AS balance_paper
			
		FROM periods
		) AS sub
		WHERE sub.balance_fact<>sub.balance_paper ORDER BY sub.d	
	LOOP
		
		UPDATE rg_material_facts AS rg
		SET quant = period_row.balance_fact
		WHERE rg.date_time=period_row.d
			AND rg.material_id=period_row.material_id
			AND coalesce(rg.production_site_id,0)=coalesce(period_row.production_site_id,0)
		;
		
		IF NOT FOUND THEN
			INSERT INTO rg_material_facts (date_time,material_id,production_site_id,quant)
			VALUES (period_row.d,period_row.material_id,period_row.production_site_id,period_row.balance_fact);
		END IF;
	END LOOP;

	--АКТУАЛЬНЫЕ ИТОГИ
	DELETE FROM rg_material_facts WHERE date_time>v_cur_period AND material_id=in_material_id;
	
	INSERT INTO rg_material_facts (date_time,material_id,production_site_id,quant)
	(
	SELECT
		v_act_date_time,
		rg.material_id,
		rg.production_site_id,
		COALESCE(rg.quant,0) +
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_material_facts AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.material_id=rg.material_id
			AND coalesce(ra.production_site_id,0)=coalesce(rg.production_site_id,0)
			AND ra.deb=TRUE
		),0) - 
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_material_facts AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.material_id=rg.material_id
			AND coalesce(ra.production_site_id,0)=coalesce(rg.production_site_id,0)
			AND ra.deb=FALSE
		),0)
		
	FROM rg_material_facts AS rg
	WHERE date_time=(v_cur_period-'1 month'::interval) AND material_id=in_material_id
	);	
END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.rg_total_recalc_material_facts_mat(in_material_id integer)
  OWNER TO beton;

