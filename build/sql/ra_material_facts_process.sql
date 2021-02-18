-- FUNCTION: public.ra_material_facts_process()

-- DROP FUNCTION public.ra_material_facts_process();

CREATE OR REPLACE FUNCTION public.ra_material_facts_process()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
				v_delta_quant  numeric(19,3) DEFAULT 0;
				CALC_DATE_TIME timestamp;
				CURRENT_BALANCE_DATE_TIME timestamp;
				v_loop_rg_period timestamp;
				v_calc_interval interval;			  			
			BEGIN
				IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
					RETURN NEW;
				ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
					RETURN NEW;
				ELSIF (TG_WHEN='AFTER' AND (TG_OP='UPDATE' OR TG_OP='INSERT')) THEN
					CALC_DATE_TIME = rg_calc_period('material_fact'::reg_types);
					IF (CALC_DATE_TIME IS NULL) OR (NEW.date_time::date > rg_period_balance('material_fact'::reg_types, CALC_DATE_TIME)) THEN
						CALC_DATE_TIME = rg_period('material_fact'::reg_types,NEW.date_time);
						PERFORM rg_material_fact_set_custom_period(CALC_DATE_TIME);						
					END IF;

					IF TG_OP='UPDATE' AND
					(NEW.date_time<>OLD.date_time
					OR NEW.material_id<>OLD.material_id
					OR coalesce(NEW.production_site_id,0)<>coalesce(OLD.production_site_id,0)
					) THEN
						--delete old data completely
						PERFORM rg_material_facts_update_periods(OLD.date_time, OLD.material_id, OLD.production_site_id, -1*OLD.quant);
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

					PERFORM rg_material_facts_update_periods(NEW.date_time, NEW.material_id, NEW.production_site_id, v_delta_quant);
					/*
					v_loop_rg_period = CALC_DATE_TIME;
					v_calc_interval = rg_calc_interval('material_fact'::reg_types);
					LOOP
						UPDATE rg_material_facts
						SET
						quant = quant + v_delta_quant
						WHERE 
							date_time=v_loop_rg_period
							AND material_id = NEW.material_id
							AND coalesce(production_site_id,0) = coalesce(NEW.production_site_id,0);
						IF NOT FOUND THEN
							BEGIN
								INSERT INTO rg_material_facts (date_time
								,material_id
								,production_site_id
								,quant)				
								VALUES (v_loop_rg_period
								,NEW.material_id
								,NEW.production_site_id
								,v_delta_quant);
							EXCEPTION WHEN OTHERS THEN
								UPDATE rg_material_facts
								SET
								quant = quant + v_delta_quant
								WHERE date_time = v_loop_rg_period
								AND material_id = NEW.material_id
								AND coalesce(production_site_id,0) = coalesce(NEW.production_site_id,0);
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
					quant = quant + v_delta_quant
					WHERE 
						date_time=CURRENT_BALANCE_DATE_TIME
						AND material_id = NEW.material_id
						AND coalesce(production_site_id,0) = coalesce(NEW.production_site_id,0);
					IF NOT FOUND THEN
						BEGIN
							INSERT INTO rg_material_facts (date_time
							,material_id
							,quant)				
							VALUES (CURRENT_BALANCE_DATE_TIME
							,NEW.material_id
							,v_delta_quant);
						EXCEPTION WHEN OTHERS THEN
							UPDATE rg_material_facts
							SET
							quant = quant + v_delta_quant
							WHERE 
								date_time=CURRENT_BALANCE_DATE_TIME
								AND material_id = NEW.material_id
								AND coalesce(production_site_id,0) = coalesce(NEW.production_site_id,0);
						END;
					END IF;
					*/
					
					--Event support
					/*PERFORM pg_notify(
							'RAMaterialFact.'||lower(TG_OP)
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
					CALC_DATE_TIME = rg_calc_period('material_fact'::reg_types);
					IF (CALC_DATE_TIME IS NULL) OR (OLD.date_time::date > rg_period_balance('material_fact'::reg_types, CALC_DATE_TIME)) THEN
						CALC_DATE_TIME = rg_period('material_fact'::reg_types,OLD.date_time);
						PERFORM rg_material_fact_set_custom_period(CALC_DATE_TIME);						
					END IF;
					v_delta_quant = OLD.quant;
					IF OLD.deb THEN
						v_delta_quant = -1*v_delta_quant;					
					END IF;

					PERFORM rg_material_facts_update_periods(OLD.date_time, OLD.material_id, OLD.production_site_id, v_delta_quant);
					
					/*
					v_loop_rg_period = CALC_DATE_TIME;
					v_calc_interval = rg_calc_interval('material_fact'::reg_types);
					LOOP
						UPDATE rg_material_facts
						SET
						quant = quant + v_delta_quant
						WHERE 
							date_time=v_loop_rg_period
							AND material_id = OLD.material_id
							AND coalesce(production_site_id,0) = coalesce(OLD.production_site_id,0);
						IF NOT FOUND THEN
							BEGIN
								INSERT INTO rg_material_facts (date_time
								,material_id
								,production_site_id
								,quant)				
								VALUES (v_loop_rg_period
								,OLD.material_id
								,OLD.production_site_id
								,v_delta_quant);
							EXCEPTION WHEN OTHERS THEN
								UPDATE rg_material_facts
								SET
								quant = quant + v_delta_quant
								WHERE date_time = v_loop_rg_period
								AND material_id = OLD.material_id
								AND coalesce(production_site_id,0) = coalesce(OLD.production_site_id,0);
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
					quant = quant + v_delta_quant
					WHERE 
						date_time=CURRENT_BALANCE_DATE_TIME
						AND material_id = OLD.material_id
						AND coalesce(production_site_id,0) = coalesce(OLD.production_site_id,0);
					IF NOT FOUND THEN
						BEGIN
							INSERT INTO rg_material_facts (date_time
							,material_id
							,production_site_id
							,quant)				
							VALUES (CURRENT_BALANCE_DATE_TIME
							,OLD.material_id
							,OLD.production_site_id
							,v_delta_quant);
						EXCEPTION WHEN OTHERS THEN
							UPDATE rg_material_facts
							SET
							quant = quant + v_delta_quant
							WHERE 
								date_time=CURRENT_BALANCE_DATE_TIME
								AND material_id = OLD.material_id
								AND coalesce(production_site_id,0) = coalesce(OLD.production_site_id,0);
						END;
					END IF;					
					*/
					
					--Event support
					/*PERFORM pg_notify(
							'RAMaterialFact.'||lower(TG_OP)
						,json_build_object(
							'params',json_build_object(
								'id',OLD.id
							)
						)::text
					);*/
					
					RETURN OLD;					
				END IF;
			END;
$BODY$;

ALTER FUNCTION public.ra_material_facts_process()
    OWNER TO beton;

