-- Function: public.raw_material_map_to_production_process()

-- DROP FUNCTION public.raw_material_map_to_production_process();

CREATE OR REPLACE FUNCTION public.raw_material_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM raw_material_map_to_production_recalc(
			OLD.raw_material_id,
			OLD.production_descr::text,
			(SELECT date_time FROM raw_material_map_to_production WHERE date_time<OLD.date_time ORDER BY date_time DESC LIMIT 1)
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM raw_material_map_to_production_recalc(
			NEW.raw_material_id,
			NEW.production_descr::text,
			NEW.date_time
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.raw_material_id,0)<>coalesce(OLD.raw_material_id,0) OR NEW.date_time<>OLD.date_time OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET raw_material_id = NULL
			WHERE raw_material_production_descr=OLD.production_descr AND date_time>=OLD.date_time;			
		END IF;
		
		PERFORM raw_material_map_to_production_recalc(
			NEW.raw_material_id,
			NEW.production_descr::text,
			least(NEW.date_time,OLD.date_time)
		);
	
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' THEN
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.raw_material_map_to_production_process()
  OWNER TO beton;

