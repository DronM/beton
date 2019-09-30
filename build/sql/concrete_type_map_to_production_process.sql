-- Function: public.concrete_type_map_to_production_process()

-- DROP FUNCTION public.concrete_type_map_to_production_process();

CREATE OR REPLACE FUNCTION public.concrete_type_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM concrete_type_map_to_production_recalc(
			OLD.concrete_type_id,
			OLD.production_descr
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.concrete_type_id,0)<>coalesce(OLD.concrete_type_id,0) OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET concrete_type_id = NULL
			WHERE concrete_type_production_descr=OLD.production_descr;
		END IF;
		
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
	
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' THEN
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_type_map_to_production_process()
  OWNER TO beton;

