-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
	
		IF TG_OP='UPDATE' AND OLD.manual_correction=TRUE AND NEW.manual_correction=TRUE THEN
			RETURN OLD;
		END IF;	
	
		IF TG_OP='INSERT' OR
			(TG_OP='UPDATE'
			AND (
				OLD.production_vehicle_descr!=NEW.production_vehicle_descr
				OR OLD.production_dt_start!=NEW.production_dt_start
			)
			)
		THEN		
			SELECT *
			INTO
				NEW.vehicle_id,
				NEW.vehicle_schedule_state_id,
				NEW.shipment_id
			FROM material_fact_consumptions_find_vehicle(
				NEW.production_site_id,
				coalesce(
					(SELECT v.plate::text
					FROM production_vehicle_corrections AS p
					LEFT JOIN vehicles AS v ON v.id=p.vehicle_id
					WHERE p.production_site_id=NEW.production_site_id AND p.production_id=NEW.production_id
					)
					,NEW.production_vehicle_descr
				),
				NEW.production_dt_start::timestamp
			) AS (
				vehicle_id int,
				vehicle_schedule_state_id int,
				shipment_id int
			);		
		END IF;
		
		IF NEW.production_dt_end IS NOT NULL THEN
			NEW.material_tolerance_violated = productions_get_mat_tolerance_violated(
				NEW.production_site_id,
				NEW.production_id
			);
		END IF;
				
		/*
		IF TG_OP='UPDATE'		
			AND (
				(OLD.production_dt_end IS NULL AND NEW.production_dt_end IS NOT NULL)
				OR coalesce(NEW.shipment_id,0)<>coalesce(OLD.shipment_id,0)
				OR coalesce(NEW.vehicle_schedule_state_id,0)<>coalesce(OLD.vehicle_schedule_state_id,0)
				OR coalesce(NEW.concrete_type_id,0)<>coalesce(OLD.concrete_type_id,0)
			)
		THEN			
			NEW.material_tolerance_violated = productions_get_mat_tolerance_violated(
				NEW.production_site_id,
				NEW.production_id
			);			
		END IF;
		*/
		
		RETURN NEW;
		
	ELSEIF TG_WHEN='AFTER' AND TG_OP='INSERT' THEN
		
		IF coalesce(
			(SELECT TRUE
			FROM production_sites
			WHERE id = NEW.production_site_id
			AND NEW.production_id =ANY(missing_elkon_production_ids))
			,FALSE
		) THEN
			UPDATE production_sites
			SET
				missing_elkon_production_ids = array_diff(missing_elkon_production_ids,ARRAY[NEW.production_id])
			WHERE id = NEW.production_site_id
			;
		END IF;
		
		PERFORM pg_notify(
			'Production.insert'
			,json_build_object(
				'params',json_build_object(
					'id',NEW.id
				)
			)::text
		);
		
		RETURN NEW;
		
	ELSEIF TG_WHEN='AFTER' AND TG_OP='UPDATE' THEN
		/*
		IF coalesce(NEW.concrete_type_id,0)<>coalesce(OLD.concrete_type_id,0)
		THEN
			UPDATE material_fact_consumptions
			SET
				concrete_type_id = NEW.concrete_type_id
			WHERE production_site_id = NEW.production_site_id AND production_id = NEW.production_id;
		END IF;
		*/
		/* МЕНЯТЬ ТС ПРИ СМЕНЕ shipment_id*/
		IF (coalesce(NEW.shipment_id,0)<>coalesce(OLD.shipment_id,0))
		OR (coalesce(NEW.vehicle_schedule_state_id,0)<>coalesce(OLD.vehicle_schedule_state_id,0))
		OR (coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0))
		OR (coalesce(NEW.concrete_type_id,0)<>coalesce(OLD.concrete_type_id,0))
		OR (coalesce(NEW.concrete_quant,0)<>coalesce(OLD.concrete_quant,0))
		THEN
			--сменить shipment_id,vehicle_schedule_state_id
			IF (coalesce(NEW.shipment_id,0)<>coalesce(OLD.shipment_id,0)) THEN
				SELECT
					vsch.vehicle_id
					,vschst.id
				INTO
					NEW.vehicle_id
					,NEW.vehicle_schedule_state_id	
				FROM shipments AS sh
				LEFT JOIN vehicle_schedules AS vsch ON vsch.id=sh.vehicle_schedule_id
				LEFT JOIN vehicle_schedule_states AS vschst ON vschst.schedule_id=sh.vehicle_schedule_id AND vschst.shipment_id=sh.id
				WHERE sh.id=NEW.shipment_id	
				;
			END IF;
			
			UPDATE material_fact_consumptions
			SET
				vehicle_schedule_state_id = NEW.vehicle_schedule_state_id,
				vehicle_id = NEW.vehicle_id,
				concrete_type_id = NEW.concrete_type_id,
				concrete_quant = NEW.concrete_quant
			WHERE production_site_id = NEW.production_site_id AND production_id = NEW.production_id;
		END IF;
		
		
		--ЭТО ДЕЛАЕТСЯ В КОНТРОЛЛЕРЕ Production_Controller->check_data!!!
		--IF OLD.production_dt_end IS NULL
		--AND NEW.production_dt_end IS NOT NULL
		--AND NEW.shipment_id IS NOT NULL THEN
		--END IF;
		
		PERFORM pg_notify(
			'Production.update'
			,json_build_object(
				'params',json_build_object(
					'id',NEW.id
				)
			)::text
		);
		
		RETURN NEW;
		
	ELSEIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM material_fact_consumptions WHERE production_site_id = OLD.production_site_id AND production_id = OLD.production_id;
		
		RETURN OLD;

	ELSEIF TG_WHEN='AFTER' AND TG_OP='DELETE' THEN
		
		PERFORM pg_notify(
			'Production.delete'
			,json_build_object(
				'params',json_build_object(
					'id',OLD.id
				)
			)::text
		);
		
		RETURN OLD;
				
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO ;

