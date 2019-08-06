-- Function: public.bad_coord_check()

-- DROP FUNCTION public.bad_coord_check();

CREATE OR REPLACE FUNCTION public.bad_coord_check()
  RETURNS trigger AS
$BODY$
BEGIN
	/*
	IF EXTRACT(YEAR FROM NEW.period::date)='2080' THEN
		IF NEW.gps_valid=1 THEN
			NEW.period=NEW.recieved_dt;
		ELSE
			--skeep bad record
			RETURN NULL;
		END IF;
	*/
	IF NEW.period>((now() at time zone 'UTC')+'5 minutes'::interval) THEN
		IF NEW.gps_valid=0 OR NEW.from_memory=1 THEN
			--skeep bad record
			IF NEW.car_id<>'5035507430' THEN
				RETURN NULL;		
			END IF;
		ELSE
			NEW.period=NEW.recieved_dt;
		END IF;
	ELSIF (now() at time zone 'UTC'-NEW.period)>'2 days'::interval THEN
		RETURN NULL;
	END IF;

	RETURN NEW;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.bad_coord_check()
  OWNER TO beton;

