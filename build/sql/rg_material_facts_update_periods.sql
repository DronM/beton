-- Function: rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_production_site_id int, in_delta_quant numeric(19,3))

-- DROP FUNCTION rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_production_site_id int, in_delta_quant numeric(19,3));

CREATE OR REPLACE FUNCTION rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_production_site_id int, in_delta_quant numeric(19,3))
  RETURNS void AS
$BODY$
DECLARE
	v_loop_rg_period timestamp;
	v_calc_interval interval;			  			
	CURRENT_BALANCE_DATE_TIME timestamp;
	CALC_DATE_TIME timestamp;
BEGIN
	CALC_DATE_TIME = rg_calc_period('material_fact'::reg_types);
	v_loop_rg_period = rg_period('material_fact'::reg_types,in_date_time);
	v_calc_interval = rg_calc_interval('material_fact'::reg_types);
	LOOP
		UPDATE rg_material_facts
		SET
			quant = quant + in_delta_quant
		WHERE 
			date_time=v_loop_rg_period
			AND material_id = in_material_id
			AND coalesce(production_site_id,0) = coalesce(in_production_site_id,0)
			;
			
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO rg_material_facts (date_time
				,material_id
				,production_site_id
				,quant)				
				VALUES (v_loop_rg_period
				,in_material_id
				,in_production_site_id
				,in_delta_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE rg_material_facts
				SET
					quant = quant + in_delta_quant
				WHERE date_time = v_loop_rg_period
				AND material_id = in_material_id
				AND coalesce(production_site_id,0) = coalesce(in_production_site_id,0)
				;
			END;
		END IF;
		v_loop_rg_period = v_loop_rg_period + v_calc_interval;
		IF v_loop_rg_period > CALC_DATE_TIME THEN
			EXIT;  -- exit loop
		END IF;
	END LOOP;
	
	--Current balance
	CURRENT_BALANCE_DATE_TIME = reg_current_balance_time();
	UPDATE rg_material_facts
	SET
		quant = quant + in_delta_quant
	WHERE 
		date_time=CURRENT_BALANCE_DATE_TIME
		AND material_id = in_material_id
		AND coalesce(production_site_id,0) = coalesce(in_production_site_id,0)
		;
		
	IF NOT FOUND THEN
		BEGIN
			INSERT INTO rg_material_facts (date_time
			,material_id
			,production_site_id
			,quant)				
			VALUES (CURRENT_BALANCE_DATE_TIME
			,in_material_id
			,in_production_site_id
			,in_delta_quant);
		EXCEPTION WHEN OTHERS THEN
			UPDATE rg_material_facts
			SET
				quant = quant + in_delta_quant
			WHERE 
				date_time=CURRENT_BALANCE_DATE_TIME
				AND material_id = in_material_id
				AND coalesce(production_site_id,0) = coalesce(in_production_site_id,0)
				;
		END;
	END IF;					
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_production_site_id int, in_delta_quant numeric(19,3)) OWNER TO ;


