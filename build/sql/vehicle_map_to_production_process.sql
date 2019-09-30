-- Function: public.vehicle_map_to_production_process()

-- DROP FUNCTION public.vehicle_map_to_production_process();

CREATE OR REPLACE FUNCTION public.vehicle_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM vehicle_map_to_production_recalc(
			OLD.vehicle_id,
			OLD.production_descr
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM vehicle_map_to_production_recalc(
			NEW.vehicle_id,
			NEW.production_descr
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET vehicle_id = NULL
			WHERE vehicle_production_descr=OLD.production_descr;
		END IF;
		
		PERFORM vehicle_map_to_production_recalc(
			NEW.vehicle_id,
			NEW.production_descr
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicle_map_to_production_process()
  OWNER TO beton;

