-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
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
				NEW.production_vehicle_descr,
				NEW.production_dt_start::timestamp
			) AS (
				vehicle_id int,
				vehicle_schedule_state_id int,
				shipment_id int
			);		
		END IF;
		
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

		RETURN NEW;
		
	ELSEIF TG_WHEN='AFTER' AND TG_OP='UPDATE' THEN

		IF coalesce(NEW.concrete_type_id,0)<>coalesce(OLD.concrete_type_id,0)
		THEN
			UPDATE material_fact_consumptions
			SET
				concrete_type_id = NEW.concrete_type_id
			WHERE production_site_id = NEW.production_site_id AND production_id = NEW.production_id;
		END IF;

		IF (coalesce(NEW.shipment_id,0)<>coalesce(OLD.shipment_id,0))
		OR (coalesce(NEW.vehicle_schedule_state_id,0)<>coalesce(OLD.vehicle_schedule_state_id,0))
		THEN
			UPDATE material_fact_consumptions
			SET
				shipment_id = NEW.shipment_id,
				vehicle_schedule_state_id = NEW.vehicle_schedule_state_id
			WHERE production_site_id = NEW.production_site_id AND production_id = NEW.production_id;
		END IF;
		
		
		--ЭТО ДЕЛАЕТСЯ В КОНТРОЛЛЕРЕ Production_Controller->check_data!!!
		--IF OLD.production_dt_end IS NULL
		--AND NEW.production_dt_end IS NOT NULL
		--AND NEW.shipment_id IS NOT NULL THEN
		--END IF;
		RETURN NEW;
		
	ELSEIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM material_fact_consumptions WHERE production_id = OLD.production_id;
		
		RETURN OLD;
				
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO ;

