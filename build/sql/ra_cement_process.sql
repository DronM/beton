-- Function: public.ra_cement_process()

-- DROP FUNCTION public.ra_cement_process();

CREATE OR REPLACE FUNCTION public.ra_cement_process()
  RETURNS trigger AS
$BODY$
			DECLARE
				v_delta_quant  numeric(19,3) DEFAULT 0;
				CALC_DATE_TIME timestamp without time zone;
				CURRENT_BALANCE_DATE_TIME timestamp without time zone;
				v_loop_rg_period timestamp;
				v_calc_interval interval;			  			
			BEGIN
				IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
					RETURN NEW;
				ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
					RETURN NEW;
				ELSIF (TG_WHEN='AFTER' AND (TG_OP='UPDATE' OR TG_OP='INSERT')) THEN
					CALC_DATE_TIME = rg_calc_period('cement'::reg_types);
					IF (CALC_DATE_TIME IS NULL) OR (NEW.date_time::date > rg_period_balance('cement'::reg_types, CALC_DATE_TIME)) THEN
						CALC_DATE_TIME = rg_period('cement'::reg_types,NEW.date_time);
						PERFORM rg_cement_set_custom_period(CALC_DATE_TIME);						
					END IF;
					
					IF TG_OP='UPDATE' AND
					(NEW.date_time<>OLD.date_time
					) THEN
						--delete old data completely
						PERFORM rg_cement_update_periods(OLD.date_time, OLD.cement_silos_id,-1*OLD.quant);
						v_delta_quant = 0;
					ELSIF TG_OP='UPDATE' THEN						
						v_delta_quant = OLD.quant;
					ELSE
						v_delta_quant = 0;
					END IF;
					
					v_delta_quant = NEW.quant - v_delta_quant;
					IF NOT NEW.deb THEN
						v_delta_quant = -1 * v_delta_quant;
					END IF;

					PERFORM rg_cement_update_periods(NEW.date_time, NEW.cement_silos_id, v_delta_quant);

					--Event support
					/*PERFORM pg_notify(
							'RACement.'||lower(TG_OP)
						,json_build_object(
							'params',json_build_object(
								'id',NEW.id
							)
						)::text
					);*/

					RETURN NEW;					
				ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
					RETURN OLD;
				ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
					CALC_DATE_TIME = rg_calc_period('cement'::reg_types);
					IF (CALC_DATE_TIME IS NULL) OR (OLD.date_time::date > rg_period_balance('cement'::reg_types, CALC_DATE_TIME)) THEN
						CALC_DATE_TIME = rg_period('cement'::reg_types,OLD.date_time);
						PERFORM rg_cement_set_custom_period(CALC_DATE_TIME);						
					END IF;
					v_delta_quant = OLD.quant;
					IF OLD.deb THEN
						v_delta_quant = -1*v_delta_quant;					
					END IF;

					PERFORM rg_cement_update_periods(OLD.date_time, OLD.cement_silos_id,v_delta_quant);
					
					--Event support
					/*PERFORM pg_notify(
							'RACement.delete'
						,json_build_object(
							'params',json_build_object(
								'id',OLD.id
							)
						)::text
					);*/
					
					RETURN OLD;					
				END IF;
			END;
			$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.ra_cement_process()
  OWNER TO beton;

