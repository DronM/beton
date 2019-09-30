-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='INSERT' THEN
		SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		RETURN NEW;
		
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time) THEN
		SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' THEN	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;

