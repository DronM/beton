-- Function: public.production_vehicle_corrections_process()

-- DROP FUNCTION public.production_vehicle_corrections_process();

CREATE OR REPLACE FUNCTION public.production_vehicle_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_vehicle_schedule_state_id int;
	v_shipment_id int;
	v_production_dt_start timestamp;
	v_production_vehicle_descr text;
	v_vehicle_id int;
BEGIN
	
	IF TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
		
		SELECT
			vschs.id AS vehicle_schedule_state_id,
			sh.id AS shipment_id
		INTO
			v_vehicle_schedule_state_id,
			v_shipment_id	
		FROM shipments AS sh
		LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id AND vschs.state='assigned' AND vschs.shipment_id=sh.id
		LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
		LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
		LEFT JOIN productions AS prod ON prod.production_site_id =NEW.production_site_id AND  prod.production_id=NEW.production_id
		WHERE
			vsch.vehicle_id = NEW.vehicle_id
			AND sh.date_time BETWEEN prod.production_dt_start-'240 minutes'::interval AND prod.production_dt_start+'240 minutes'::interval
			AND sh.production_site_id = NEW.production_site_id
		ORDER BY
			-- the nearest shipment
			CASE
				WHEN prod.production_dt_start>sh.date_time THEN prod.production_dt_start - sh.date_time
				ELSE sh.date_time-prod.production_dt_start
			END
		LIMIT 1;
		
		UPDATE productions
		SET
			shipment_id = v_shipment_id,
			vehicle_schedule_state_id = v_vehicle_schedule_state_id,
			vehicle_id = NEW.vehicle_id
		WHERE production_site_id=NEW.production_site_id AND production_id=NEW.production_id
		;

		UPDATE productions
		SET
			material_tolerance_violated = productions_get_mat_tolerance_violated(NEW.production_site_id,NEW.production_id)
		WHERE production_site_id=NEW.production_site_id AND production_id=NEW.production_id
		;
		
		RETURN NEW;
	
	ELSEIF TG_WHEN='AFTER' AND TG_OP='DELETE' THEN
		SELECT
			production_dt_start,
			production_vehicle_descr
		INTO
			v_production_dt_start,
			v_production_vehicle_descr
		FROM productions
		WHERE production_site_id=OLD.production_site_id AND production_id=OLD.production_id;
		
		--Привязка по-умолчанию
		SELECT *
		INTO
			v_vehicle_id,
			v_vehicle_schedule_state_id,
			v_shipment_id
		FROM material_fact_consumptions_find_vehicle(
			OLD.production_site_id
			,v_production_vehicle_descr
			,v_production_dt_start
		) AS (
			vehicle_id int,
			vehicle_schedule_state_id int,
			shipment_id int
		);		
		
		
		UPDATE productions
		SET
			shipment_id = v_shipment_id,
			vehicle_schedule_state_id = v_vehicle_schedule_state_id,
			vehicle_id=v_vehicle_id
		WHERE production_site_id=OLD.production_site_id AND production_id=OLD.production_id
		;
		
		
		RETURN OLD;
				
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.production_vehicle_corrections_process() OWNER TO ;

