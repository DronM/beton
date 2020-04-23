-- Function: public.rg_total_recalc_cement()

-- DROP FUNCTION public.rg_total_recalc_cement();

CREATE OR REPLACE FUNCTION public.rg_total_recalc_cement()
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
				cement_silos_id
			FROM ra_cement)
			UNION		
			(SELECT
				date_time AS d,
				cement_silos_id
			FROM rg_cement WHERE date_time<=v_cur_period
			)
			ORDER BY d			
		)
		SELECT sub.d,sub.cement_silos_id,sub.balance_fact,sub.balance_paper
		FROM
		(
		SELECT
			periods.d,
			periods.cement_silos_id,
			COALESCE((
				SELECT SUM(CASE WHEN deb THEN quant ELSE 0 END)-SUM(CASE WHEN NOT deb THEN quant ELSE 0 END)
				FROM ra_cement AS ra WHERE ra.date_time <= last_month_day(periods.d::date)+'23:59:59'::interval AND ra.cement_silos_id=periods.cement_silos_id
			),0) AS balance_fact,
			
			(
			SELECT SUM(quant) FROM rg_cement WHERE date_time=periods.d AND cement_silos_id=periods.cement_silos_id
			) AS balance_paper
			
		FROM periods
		) AS sub
		WHERE sub.balance_fact<>sub.balance_paper ORDER BY sub.d	
	LOOP
		
		UPDATE rg_cement AS rg
		SET quant = period_row.balance_fact
		WHERE rg.date_time=period_row.d AND rg.cement_silos_id=period_row.cement_silos_id;
		
		IF NOT FOUND THEN
			INSERT INTO rg_cement (date_time,cement_silos_id,quant)
			VALUES (period_row.d,period_row.cement_silos_id,period_row.balance_fact);
		END IF;
	END LOOP;

	--АКТУАЛЬНЫЕ ИТОГИ
	DELETE FROM rg_cement WHERE date_time>v_cur_period;
	
	INSERT INTO rg_cement (date_time,cement_silos_id,quant)
	(
	SELECT
		v_act_date_time,
		rg.cement_silos_id,
		COALESCE(rg.quant,0) +
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=TRUE
		),0) - 
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=FALSE
		),0)
		
	FROM rg_cement AS rg
	WHERE date_time=(v_cur_period-'1 month'::interval)
	);	
END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.rg_total_recalc_cement()
  OWNER TO beton;

