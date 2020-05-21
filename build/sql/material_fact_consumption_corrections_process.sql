-- Function: public.material_fact_consumption_corrections_process()

-- DROP FUNCTION public.material_fact_consumption_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumption_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		
		--Определить силос и дату по номеру производства
		SELECT
			date_time,
			cement_silo_id
		INTO
			NEW.date_time,
			NEW.cement_silo_id
		FROM material_fact_consumptions
		WHERE production_site_id = NEW.production_site_id AND production_id = NEW.production_id AND raw_material_id=NEW.material_id;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_consumption_correction'::doc_types,NEW.id,NEW.date_time::timestamp without time zone);
		END IF;


		IF NEW.quant <> 0 THEN
			--register actions ra_material_facts		
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption_correction'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= NEW.quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;

		IF (SELECT is_cement FROM raw_materials WHERE id=NEW.material_id)
		AND NEW.cement_silo_id IS NOT NULL THEN
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption_correction'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= NEW.quant;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;

		
		IF (TG_OP='INSERT' OR (TG_OP='UPDATE' AND OLD.quant<>NEW.quant)) THEN
			UPDATE productions
			SET
				material_tolerance_violated = productions_get_mat_tolerance_violated(
						NEW.production_site_id,
						NEW.production_id
				)
			WHERE production_site_id=NEW.production_site_id AND production_id=NEW.production_id;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_consumption_correction'::doc_types,NEW.id,NEW.date_time::timestamp without time zone);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_consumption_correction'::doc_types,OLD.id);
		
		--Определить силос и дату по номеру производства
		SELECT
			date_time,
			cement_silo_id
		INTO
			NEW.date_time,
			NEW.cement_silo_id
		FROM material_fact_consumptions
		WHERE production_site_id = NEW.production_site_id AND production_id = NEW.production_id AND raw_material_id=NEW.material_id;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_consumption_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_consumption_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_consumption_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumption_corrections_process()
  OWNER TO beton;
