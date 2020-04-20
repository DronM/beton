-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant
		INTO v_quant
		FROM rg_cement_balance(ARRAY[NEW.cement_silo_id]) AS rg;
		--'cement_silo_balance_reset'::doc_types,NEW.id
		--RAISE EXCEPTION 'v_quant=%',v_quant;
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= CASE WHEN v_quant>0 THEN FALSE ELSE TRUE END;
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;

