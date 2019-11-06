-- Function: rg_materials_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3))

-- DROP FUNCTION rg_materials_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3));

CREATE OR REPLACE FUNCTION rg_materials_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3))
  RETURNS void AS
$BODY$
DECLARE
	v_loop_rg_period timestamp;
	v_calc_interval interval;			  			
	CURRENT_BALANCE_DATE_TIME timestamp;
	CALC_DATE_TIME timestamp;
BEGIN
	CALC_DATE_TIME = rg_calc_period('material'::reg_types);
	v_loop_rg_period = rg_period('material'::reg_types,in_date_time);
	v_calc_interval = rg_calc_interval('material'::reg_types);
	LOOP
		UPDATE rg_materials
		SET
			quant = quant + in_delta_quant
		WHERE 
			date_time=v_loop_rg_period
			AND material_id = in_material_id;
			
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO rg_materials (date_time
				,material_id
				,quant)				
				VALUES (v_loop_rg_period
				,in_material_id
				,in_delta_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE rg_materials
				SET
					quant = quant + in_delta_quant
				WHERE date_time = v_loop_rg_period
				AND material_id = in_material_id;
			END;
		END IF;
		v_loop_rg_period = v_loop_rg_period + v_calc_interval;
		IF v_loop_rg_period > CALC_DATE_TIME THEN
			EXIT;  -- exit loop
		END IF;
	END LOOP;
	
	--Current balance
	CURRENT_BALANCE_DATE_TIME = reg_current_balance_time();
	UPDATE rg_materials
	SET
		quant = quant + in_delta_quant
	WHERE 
		date_time=CURRENT_BALANCE_DATE_TIME
		AND material_id = in_material_id;
		
	IF NOT FOUND THEN
		BEGIN
			INSERT INTO rg_materials (date_time
			,material_id
			,quant)				
			VALUES (CURRENT_BALANCE_DATE_TIME
			,in_material_id
			,in_delta_quant);
		EXCEPTION WHEN OTHERS THEN
			UPDATE rg_materials
			SET
				quant = quant + in_delta_quant
			WHERE 
				date_time=CURRENT_BALANCE_DATE_TIME
				AND material_id = in_material_id;
		END;
	END IF;					
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION rg_materials_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3)) OWNER TO ;
