-- Function: public.doc_material_procurements_process()

-- DROP FUNCTION public.doc_material_procurements_process();

CREATE OR REPLACE FUNCTION public.doc_material_procurements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_act ra_materials%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER') AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN					
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;

		--register actions ra_materials
		reg_act.date_time		= NEW.date_time;
		reg_act.deb			= true;
		reg_act.doc_type  		= 'material_procurement'::doc_types;
		reg_act.doc_id  		= NEW.id;
		reg_act.material_id		= NEW.material_id;
		reg_act.quant			= NEW.quant_net;
		PERFORM ra_materials_add_act(reg_act);	
		
		IF NEW.material_id <> (const_cement_material_val()->'keys'->>'id')::int THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= true;
			reg_material_facts.doc_type  		= 'material_procurement'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= NEW.quant_net;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.cement_silos_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= true;
			reg_cement.doc_type  		= 'material_procurement'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.quant_net;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
				
		RETURN NEW;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);

		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;
						
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		RETURN OLD;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--detail tables
		
		--register actions										
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);
		
		--log
		PERFORM doc_log_delete('material_procurement'::doc_types,OLD.id);
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_material_procurements_process()
  OWNER TO beton;

