-- Function: public.set_vehicle_busy()

-- DROP FUNCTION public.set_vehicle_busy();

CREATE OR REPLACE FUNCTION public.set_vehicle_busy()
  RETURNS trigger AS
$BODY$
DECLARE
	dest_id int;
	new_state vehicle_states;
	v_feature vehicles.feature%TYPE;
	reg_act ra_material_consumption%ROWTYPE;
	reg_act_mat ra_materials%ROWTYPE;
	v_concrete_type_id int;
	v_vehicle_id int;
	v_driver_id int;
	rate_row RECORD;
	v_avg_dev numeric;
BEGIN
	--change state only if 1) insert
	--		       2) update && shipped false==>true
	IF (TG_OP='INSERT') OR (TG_OP='UPDATE' AND OLD.shipped=false AND NEW.shipped) THEN
		IF NEW.shipped THEN
			new_state = 'busy'::vehicle_states;
			
			--if self-shipment && empty feature - set state out
			SELECT o.destination_id INTO dest_id FROM orders AS o WHERE o.id=NEW.order_id;
			IF dest_id = constant_self_ship_dest_id() THEN
				SELECT v.feature INTO v_feature FROM vehicle_schedules AS vs
				LEFT JOIN vehicles AS v ON v.id=vs.vehicle_id
				WHERE vs.id=NEW.vehicle_schedule_id;
				
				IF (v_feature IS NULL) OR (v_feature='') THEN
					new_state = 'out'::vehicle_states;
				END IF;
			END IF;
		END IF;
		
		INSERT INTO vehicle_schedule_states
		(date_time,state,shipment_id,schedule_id,tracker_id,destination_id)
		VALUES(current_timestamp,
		CASE
		WHEN NEW.shipped THEN
			new_state
		ELSE
			'assigned'::vehicle_states
		END,
		NEW.id,NEW.vehicle_schedule_id,
		get_vehicle_tracker_id_on_schedule_id(NEW.vehicle_schedule_id),dest_id);

	END IF;

	IF (TG_OP='INSERT') THEN
		--log
		PERFORM doc_log_insert('shipment'::doc_types,NEW.id,NEW.date_time);
	ELSE
		--IF NEW.ship_date_time<>OLD.ship_date_time THEN
			PERFORM doc_log_update('shipment'::doc_types,NEW.id,NEW.ship_date_time);
		--END IF;			
	END IF;

	IF (TG_OP='INSERT' OR TG_OP='UPDATE') AND (NEW.shipped) THEN	
		SELECT o.concrete_type_id INTO v_concrete_type_id FROM orders AS o WHERE o.id=NEW.order_id;
		SELECT sch.vehicle_id,sch.driver_id INTO v_vehicle_id,v_driver_id FROM vehicle_schedules As sch WHERE sch.id=NEW.vehicle_schedule_id;
		
		--concrete
		--reg acts				
		reg_act.date_time		= NEW.ship_date_time;
		reg_act.doc_type  		= 'shipment'::doc_types;
		reg_act.doc_id  		= NEW.id;
		reg_act.concrete_type_id 	= v_concrete_type_id;
		reg_act.vehicle_id 		= v_vehicle_id;
		reg_act.driver_id 		= v_driver_id;
		reg_act.concrete_quant		= NEW.quant;
		reg_act.material_quant		= 0;
		reg_act.material_quant_norm	= 0;
		PERFORM ra_material_consumption_add_act(reg_act);	

		--materials		
		FOR rate_row IN
			SELECT * FROM raw_material_cons_rates(v_concrete_type_id,NEW.ship_date_time)
		LOOP
			v_avg_dev = 0;--raw_mat_cons_avg_dev(NEW.ship_date_time::date,rate_row.material_id)*NEW.quant;
			
			--reg acts				
			reg_act.date_time		= NEW.ship_date_time;
			reg_act.doc_type  		= 'shipment'::doc_types;
			reg_act.doc_id  		= NEW.id;
			reg_act.concrete_type_id 	= v_concrete_type_id;
			reg_act.vehicle_id 		= v_vehicle_id;
			reg_act.driver_id 		= v_driver_id;			
			reg_act.material_id 		= rate_row.material_id;
			reg_act.material_quant		= (rate_row.rate*NEW.quant) + v_avg_dev;
			reg_act.material_quant_norm	= rate_row.rate*NEW.quant;
			reg_act.material_quant_corrected= (rate_row.rate*NEW.quant) + v_avg_dev;
			reg_act.concrete_quant		= 0;
			PERFORM ra_material_consumption_add_act(reg_act);	

			--reg materials
			reg_act_mat.date_time		= NEW.ship_date_time;
			reg_act_mat.deb			= false;
			reg_act_mat.doc_type  		= 'shipment'::doc_types;
			reg_act_mat.doc_id  		= NEW.id;
			reg_act_mat.material_id		= rate_row.material_id;
			reg_act_mat.quant		= rate_row.rate*NEW.quant;
			PERFORM ra_materials_add_act(reg_act_mat);	
			
		END LOOP;
		
		--пересчет нарушения норма/факт по производству
		UPDATE productions
		SET
			material_tolerance_violated = productions_get_mat_tolerance_violated(
				production_site_id,
				production_id
			)
		WHERE shipment_id = NEW.id;
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.set_vehicle_busy()
  OWNER TO beton;

