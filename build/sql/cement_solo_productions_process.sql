-- Function: public.cement_silo_productions_process()

-- DROP FUNCTION public.shipment_process();

CREATE OR REPLACE FUNCTION public.cement_silo_productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_OP='INSERT' THEN
		--пытаемся определить авто по описанию элкон
		NEW.vehicle_id = vehicles_define_on_production_descr(NEW.production_vehicle_descr,NEW.production_date_time::timestamp);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_productions_process() OWNER TO ;

