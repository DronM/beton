-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	--RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;

