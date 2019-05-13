-- Function: public.order_process()

-- DROP FUNCTION public.order_process();

CREATE OR REPLACE FUNCTION public.order_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_OP='INSERT') OR ((TG_OP='UPDATE') AND (NEW.date_time::date!=OLD.date_time::date)) THEN
		SELECT coalesce(MAX(number),0)+1
		INTO NEW.number
		FROM orders AS o WHERE o.date_time::date=NEW.date_time::date;		
	END IF;
	
	IF TG_OP='INSERT' THEN
		NEW.last_modif_user_id = NEW.user_id;		
	END IF;
	NEW.last_modif_date_time = now();
	
	NEW.date_time_to = get_order_date_time_to(NEW.date_time,NEW.quant::numeric, NEW.unload_speed::numeric, const_order_step_min_val());

	IF NEW.lang_id IS NULL THEN
		NEW.lang_id = 1;
	END IF;
	/*
	round_minutes(New.date_time +
		to_char( (floor(60* NEW.quant/NEW.unload_speed)::text || ' minutes')::interval, 'HH24:MI')::interval,
		const_order_step_min_val()
		);
	*/
	--RAISE 'v_end_time_min=%',NEW.time_to;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.order_process()
  OWNER TO beton;

