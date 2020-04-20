-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		--
		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
				- NEW.required_balance_quant;
		--register actions ra_material_facts
		reg_material_facts.date_time		= ra_date_time;
		reg_material_facts.deb			= (add_quant>0);
		reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
		reg_material_facts.doc_id  		= NEW.id;
		reg_material_facts.material_id		= NEW.material_id;
		reg_material_facts.quant		= abs(add_quant);
		PERFORM ra_material_facts_add_act(reg_material_facts);	
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;

