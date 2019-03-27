-- Function: order_process()

-- DROP FUNCTION order_process();

CREATE OR REPLACE FUNCTION order_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_OP='INSERT') OR ((TG_OP='UPDATE') AND (NEW.date_time::date!=OLD.date_time::date)) THEN
		SELECT coalesce(MAX(number),0)+1
		INTO NEW.number
		FROM orders AS o WHERE o.date_time::date=NEW.date_time::date;
	END IF;
	
	NEW.date_time_to = get_order_date_time_to(New.date_time,NEW.quant::numeric, NEW.unload_speed::numeric, constant_order_step_min());

	IF NEW.lang_id IS NULL THEN
		NEW.lang_id = 1;
	END IF;
	/*
	round_minutes(New.date_time +
		to_char( (floor(60* NEW.quant/NEW.unload_speed)::text || ' minutes')::interval, 'HH24:MI')::interval,
		constant_order_step_min()
		);
	*/
	--RAISE 'v_end_time_min=%',NEW.time_to;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION order_process()
  OWNER TO beton;

