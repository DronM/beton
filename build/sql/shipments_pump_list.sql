-- View: public.shipments_pump_list

-- DROP VIEW public.shipments_pump_list;

CREATE OR REPLACE VIEW public.shipments_pump_list AS 
	SELECT * FROM shipments_list
	WHERE pump_vehicle_id IS NOT NULL
	;
ALTER TABLE public.shipments_pump_list
  OWNER TO ;

