-- View: public.pump_veh_list

-- DROP VIEW public.pump_veh_list CASCADE;

CREATE OR REPLACE VIEW public.pump_veh_list AS 
	SELECT
		pv.id,
		pv.phone_cel,
		vehicles_ref(v) AS pump_vehicles_ref,
		pump_prices_ref(ppr) AS pump_prices_ref,
		
		v.make,
		v.owner,
		v.feature,
		v.plate,
		pv.deleted,
		pv.pump_length,
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		(SELECT
			owners.r->'fields'->'owner'
		FROM
		(
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS r
		) AS owners
		ORDER BY owners.r->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,
		
		pv.comment_text,
		
		--v.vehicle_owner_id,
		(SELECT
			CASE WHEN owners.r->'fields'->'owner'->'keys'->>'id'='null' THEN NULL
				ELSE (owners.r->'fields'->'owner'->'keys'->>'id')::int
			END	
		FROM
		(
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS r
		) AS owners
		ORDER BY owners.r->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owner_id,
		
		
		pv.phone_cels,
		pv.pump_prices,
		
		v.vehicle_owners_ar
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_list
  OWNER TO beton;

