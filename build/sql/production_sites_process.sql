-- Function: public.production_sites_process()

-- DROP FUNCTION public.production_sites_process();

CREATE OR REPLACE FUNCTION public.production_sites_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_WHEN='BEFORE' AND TG_OP='UPDATE' THEN
		
		IF (coalesce(NEW.last_elkon_production_id,0) - coalesce(OLD.last_elkon_production_id,0))>1 THEN
			--перепрыгнули
			SELECT
				array_agg(s.missing_id)
			INTO
				NEW.missing_elkon_production_ids
			FROM(
			SELECT generate_series(OLD.last_elkon_production_id+1,NEW.last_elkon_production_id-1,1) AS missing_id
			) AS s;			
		END IF;
		
		RETURN NEW;
		
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.production_sites_process() OWNER TO ;

