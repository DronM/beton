-- Function: public.production_vehicle_corrections_process()

-- DROP FUNCTION public.production_vehicle_corrections_process();

CREATE OR REPLACE FUNCTION public.production_vehicle_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_vehicle_id int;
	v_vehicle_schedule_state_id int;
	v_shipment_id int;
	v_production_dt_start timestamp;
	v_production_vehicle_descr text;
BEGIN
	
	IF TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
		
		SELECT *
		INTO
			v_vehicle_id,
			v_vehicle_schedule_state_id,
			v_shipment_id
		FROM material_fact_consumptions_find_vehicle(
			(SELECT v.plate::text FROM vehicles v WHERE v.id=NEW.vehicle_id)
			,(SELECT production_dt_start::timestamp FROM productions WHERE production_site_id=NEW.production_site_id AND production_id=NEW.production_id)
		) AS (
			vehicle_id int,
			vehicle_schedule_state_id int,
			shipment_id int
		);
/*				
RAISE EXCEPTION '%, %, %',
			(SELECT v.plate::text FROM vehicles v WHERE v.id=NEW.vehicle_id)
			,(SELECT production_dt_start::timestamp FROM productions WHERE production_site_id=NEW.production_site_id AND production_id=NEW.production_id)
			,material_fact_consumptions_find_vehicle(
			'1810'
			,'2020-05-18 20:02:32'::timestamp
		)
		;
*/		
		UPDATE productions
		SET
			shipment_id = v_shipment_id,
			vehicle_schedule_state_id = v_vehicle_schedule_state_id,
			vehicle_id = v_vehicle_id
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
		
		SELECT *
		INTO
			v_vehicle_id,
			v_vehicle_schedule_state_id,
			v_shipment_id
		FROM material_fact_consumptions_find_vehicle(
			v_production_vehicle_descr
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

