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
		v.plate,
		pv.pump_length,
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		v.vehicle_owner_id AS pump_vehicle_owner_id
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	WHERE coalesce(pv.deleted,FALSE)=FALSE	
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_work_list
  OWNER TO beton;

