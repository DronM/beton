-- Function: const_base_geo_zone_process()

-- DROP FUNCTION const_base_geo_zone_process();

CREATE OR REPLACE FUNCTION const_base_geo_zone_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='UPDATE') THEN
		IF coalesce(OLD.val,'') <> coalesce(NEW.val) AND NEW.val IS NOT NULL AND NEW.val->'keys' IS NOT NULL THEN		
			UPDATE const_base_geo_zone_id SET val = (NEW.val->'keys'->>'id')::int;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION const_base_geo_zone_process()
  OWNER TO ;

