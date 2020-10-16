-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	v_dif_store bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		--Все материалы проходят по регистру учета материалов
		IF NEW.raw_material_id IS NOT NULL  THEN
			--attributes
			SELECT
				is_cement
				,dif_store
			INTO
				v_is_cement
				,v_dif_store
			FROM raw_materials
			WHERE id=NEW.raw_material_id;
			
			
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			IF v_dif_store THEN
				IF NEW.production_site_id IS NULL THEN
					RAISE EXCEPTION 'По материалу % ведется учет остатков в разрезе мест хранения!',(SELECT name FROM raw_materials WHERE id=NEW.raw_material_id);
				END IF;
				reg_material_facts.production_site_id	= NEW.production_site_id;
			END IF;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
		
		--А те, что учитываются по силосам (с отметкой в справочнике), еще и по регистру силосов
		IF NEW.raw_material_id IS NOT NULL
		AND v_is_cement
		AND NEW.cement_silo_id IS NOT NULL THEN
			 
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_cement_add_act(reg_cement);	
			 
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;

