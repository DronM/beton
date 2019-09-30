--DROP FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)

CREATE OR REPLACE FUNCTION material_fact_consumptions_add(material_fact_consumptions)
RETURNS void as $$
BEGIN
    UPDATE material_fact_consumptions
    SET
    	upload_date_time = $1.upload_date_time,
    	upload_user_id = $1.upload_user_id,
    	concrete_quant = $1.concrete_quant,
    	material_quant = $1.material_quant,
    	material_quant_req = $1.material_quant_req
    	
    WHERE production_site_id = $1.production_site_id
    	AND date_time = $1.date_time
    	AND concrete_type_production_descr = $1.concrete_type_production_descr
    	AND raw_material_production_descr = $1.raw_material_production_descr
    	AND vehicle_production_descr = $1.vehicle_production_descr
    	;
    
    IF FOUND THEN
        RETURN;
    END IF;
    
    BEGIN
        INSERT INTO material_fact_consumptions 
        VALUES ($1.*);
       
    EXCEPTION WHEN unique_violation THEN
	    UPDATE material_fact_consumptions
	    SET
	    	upload_date_time = $1.upload_date_time,
	    	upload_user_id = $1.upload_user_id,
	    	concrete_quant = $1.concrete_quant,
	    	material_quant = $1.material_quant,
	    	material_quant_req = $1.material_quant_req
	    	
	    WHERE production_site_id = $1.production_site_id
	    	AND date_time = $1.date_time
	    	AND concrete_type_production_descr = $1.concrete_type_production_descr
	    	AND raw_material_production_descr = $1.raw_material_production_descr
	    	AND vehicle_production_descr = $1.vehicle_production_descr
	    	;
    END;
    
    RETURN;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add(material_fact_consumptions) OWNER TO ;

