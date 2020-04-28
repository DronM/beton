-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(NEW.date_time,ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 AND v_quant<>0 THEN		
			--здесь определяем свое количество по регистру материалов
			--SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(NEW.date_time,ARRAY[v_material_id]) AS rg;					
			--v_quant = NEW.quant_required - coalesce(v_quant,0);
			
			--RAISE EXCEPTION 'v_quant=%',v_quant;
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= abs(v_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;

