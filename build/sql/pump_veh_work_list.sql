-- View: public.pump_veh_work_list

-- DROP VIEW public.pump_veh_work_list CASCADE;

CREATE OR REPLACE VIEW public.pump_veh_work_list AS 
	SELECT
		pv.id,
		pv.phone_cel,
		vehicles_ref(v) AS pump_vehicles_ref,
		pump_prices_ref(ppr) AS pump_prices_ref,
		
		v.make,
		v.owner,
		v.feature,
		v.plate
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	WHERE coalesce(pv.deleted,FALSE)=FALSE
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_work_list
  OWNER TO beton;

