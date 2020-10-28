-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
	v_is_cement bool;
	v_dif_store bool;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time-'1 second'::interval);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		
		--attributes
		SELECT
			is_cement
			,dif_store
		INTO
			v_is_cement
			,v_dif_store
		FROM raw_materials
		WHERE id=NEW.material_id;
		
		IF v_is_cement THEN
			--ЦЕМЕНТ
			RAISE EXCEPTION 'Остатки по материалам, учитываемым в силосах, корректируются в разрезе силосов!';
		ELSIF v_dif_store AND NEW.production_site_id IS NULL THEN
			RAISE EXCEPTION 'По материалу % ведется учет остатков в разрезе мест хранения!',(SELECT name FROM raw_materials WHERE id=NEW.material_id);
		ELSE 		
			IF v_dif_store THEN
				--different query
				add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.production_site_id],ARRAY[NEW.material_id])),0);
			ELSE
				add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0);
			END IF;
			add_quant = add_quant - NEW.required_balance_quant;
			
			--RAISE EXCEPTION 'BALANCE=%',add_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.production_site_id	= CASE WHEN v_dif_store THEN NEW.production_site_id ELSE NULL END;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.balance_date_time<>OLD.balance_date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time-'1 second'::interval);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;

