-- Function: public.rg_cement_update_periods(timestamp without time zone, int, numeric)

-- DROP FUNCTION public.rg_cement_update_periods(timestamp without time zone, int,numeric);

CREATE OR REPLACE FUNCTION public.rg_cement_update_periods(
    in_date_time timestamp without time zone,
    in_cement_silos_id int,
    in_delta_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_loop_rg_period timestamp;
	v_calc_interval interval;			  			
	CURRENT_BALANCE_DATE_TIME timestamp;
	CALC_DATE_TIME timestamp;
BEGIN
	CALC_DATE_TIME = rg_calc_period('cement'::reg_types);
	v_loop_rg_period = rg_period('cement'::reg_types,in_date_time);
	v_calc_interval = rg_calc_interval('cement'::reg_types);
	LOOP
		UPDATE rg_cement
		SET
			quant = quant + in_delta_quant
		WHERE 
			date_time=v_loop_rg_period
			AND cement_silos_id = in_cement_silos_id;
			
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO rg_cement (date_time
				,cement_silos_id
				,quant)				
				VALUES (v_loop_rg_period
				,in_cement_silos_id
				,in_delta_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE rg_cement
				SET
					quant = quant + in_delta_quant
				WHERE date_time = v_loop_rg_period
				AND cement_silos_id = in_cement_silos_id;
			END;
		END IF;
		v_loop_rg_period = v_loop_rg_period + v_calc_interval;
		IF v_loop_rg_period > CALC_DATE_TIME THEN
			EXIT;  -- exit loop
		END IF;
	END LOOP;
	
	--Current balance
	CURRENT_BALANCE_DATE_TIME = reg_current_balance_time();
	UPDATE rg_cement
	SET
		quant = quant + in_delta_quant
	WHERE 
		date_time=CURRENT_BALANCE_DATE_TIME
		AND cement_silos_id = in_cement_silos_id;
		
	IF NOT FOUND THEN
		BEGIN
			INSERT INTO rg_cement (date_time
			,cement_silos_id
			,quant)				
			VALUES (CURRENT_BALANCE_DATE_TIME
			,in_cement_silos_id
			,in_delta_quant);
		EXCEPTION WHEN OTHERS THEN
			UPDATE rg_cement
			SET
				quant = quant + in_delta_quant
			WHERE 
				date_time=CURRENT_BALANCE_DATE_TIME
				AND cement_silos_id = in_cement_silos_id;
		END;
	END IF;					
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.rg_cement_update_periods(timestamp without time zone, int,numeric)
  OWNER TO beton;

