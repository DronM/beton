-- Function: public.raw_material_cons_rate_dates_process()

-- DROP FUNCTION public.raw_material_cons_rate_dates_process();

CREATE OR REPLACE FUNCTION public.raw_material_cons_rate_dates_process()
  RETURNS trigger AS
$BODY$
BEGIN	
	IF TG_OP='DELETE' AND TG_WHEN='BEFORE' THEN
		DELETE FROM raw_material_cons_rates WHERE rate_date_id=OLD.id;
		
		RETURN OLD;
		
	ELSIF TG_OP='INSERT' AND TG_WHEN='AFTER' THEN
		INSERT INTO
		raw_material_cons_rates
		(rate_date_id,
		concrete_type_id,
		raw_material_id,
		rate)
		(SELECT
			NEW.id,
			mr.concrete_type_id,
			mr.raw_material_id,
			mr.rate
		FROM raw_material_cons_rates mr
		WHERE mr.rate_date_id=
			(SELECT t.id
			FROM raw_material_cons_rate_dates AS t
			WHERE t.id<>NEW.id
			ORDER BY t.dt DESC LIMIT 1
			)
		);
		RETURN NEW;
	END IF;
	
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.raw_material_cons_rate_dates_process()
  OWNER TO beton;

