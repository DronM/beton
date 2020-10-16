-- FUNCTION: public.rg_material_facts_open_period(timestamp without time zone)

-- DROP FUNCTION public.rg_material_facts_open_period(timestamp without time zone);

CREATE OR REPLACE FUNCTION public.rg_material_facts_open_period(
	in_date_time timestamp without time zone)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
DECLARE
	v_period timestamp without time zone;
	v_new_period timestamp without time zone;
	v_next_period timestamp without time zone;
BEGIN
	v_new_period = rg_calc_period_start('material_fact'::reg_types,in_date_time);
	SELECT date_time INTO v_period FROM rg_calc_periods WHERE reg_type='material_fact'::reg_types;
	
	WHILE v_period<v_new_period LOOP
		v_next_period = v_period + rg_calc_interval('material_fact'::reg_types);
		
		--clear period
		DELETE FROM rg_materials WHERE date_time=v_next_period;
		
		--insert data		
		INSERT INTO rg_material_facts
		(date_time,
		material_id,production_site_id,quant)
		(SELECT
			v_next_period,
			rg_rest.material_id,
			rg_rest.production_site_id,
			rg_rest.quant
		FROM rg_materials_balance(rg_calc_period_end('material_fact'::reg_types,v_period),'{}','{}') AS rg_rest
		);
		v_period = v_next_period;		
	END LOOP;
	/*
	DELETE FROM rg_materials WHERE date_time=reg_current_balance_time();
	INSERT INTO rg_materials
	(date_time,material_id,production_site_id,quant)
	(SELECT
		reg_current_balance_time(),
		rg.material_id,
		rg.production_site_id,
		rg.quant + (SELECT sum(ra.quant*CASE WHEN ra.deb THEN 1 ELSE -1 END) FROM ra_materials AS ra WHERE ra.date_time >=v_new_period)
	FROM rg_materials AS rg
	WHERE rg.date_time=v_new_period
	);
	*/
	--setting new period
	UPDATE rg_calc_periods SET date_time=v_new_period WHERE reg_type='material_fact'::reg_types;
	IF NOT FOUND THEN
		BEGIN	
			INSERT INTO rg_calc_periods (date_time,reg_type) VALUES (v_new_period,'material_fact'::reg_types);
		EXCEPTION WHEN OTHERS THEN
			UPDATE rg_calc_periods SET date_time=v_new_period WHERE reg_type=='material_fact'::reg_types;
		END;
	END IF;
		
END;
$BODY$;

ALTER FUNCTION public.rg_material_facts_open_period(timestamp without time zone)
    OWNER TO beton;

