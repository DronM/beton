-- FUNCTION: public.lab_entry_update(integer, text, text, text, text,int)

-- DROP FUNCTION public.lab_entry_update(integer, text, text, text, text,int);

CREATE OR REPLACE FUNCTION public.lab_entry_update(
	in_shipment_id integer,
	in_samples text,
	in_materials text,
	in_ok2 text,
	in_time text,
	in_rate_date_id int)
    RETURNS void
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
AS $BODY$
BEGIN
--RAISE EXCEPTION 'in_rate_date_id=%',in_rate_date_id;
	UPDATE lab_entries
	SET
		samples = in_samples,
		materials = in_materials,
		ok2 = in_ok2,
		time = in_time,
		rate_date_id = in_rate_date_id
	WHERE shipment_id=in_shipment_id;
	IF NOT FOUND THEN
		--BEGIN
			INSERT INTO lab_entries
				(shipment_id,samples,materials,ok2,time,rate_date_id)
			VALUES (in_shipment_id,in_samples,in_materials,in_ok2,in_time,in_rate_date_id);
		/*EXCEPTION WHEN OTHERS THEN
			UPDATE lab_entries
			SET
				samples = in_samples,
				materials = in_materials,
				ok2 = in_ok2,
				time = in_time,
				rate_date_id = in_rate_date_id
			WHERE shipment_id=in_shipment_id;
		END;
		*/
	END IF;

END;
$BODY$;

ALTER FUNCTION public.lab_entry_update(integer, text, text, text, text,int)
    OWNER TO beton;

