-- Function: vehicle_route_cashe_process()

-- DROP FUNCTION vehicle_route_cashe_process();
-- Does not work: geo_zone_check.sql does everything

CREATE OR REPLACE FUNCTION vehicle_route_cashe_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='UPDATE') THEN
		IF OLD.route IS NOT NULL AND NEW.route IS NULL THEN		
			--event
			PERFORM pg_notify(
				'VehicleReoute.rebuild.'||NEW.tracker_id
				,json_build_object(
					'params',json_build_object(
						'pub_key',trim(NEW.pub_key)
					)
				)::text
			);
			
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION vehicle_route_cashe_process()
  OWNER TO ;

