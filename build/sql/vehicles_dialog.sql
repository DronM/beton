-- View: public.vehicles_dialog

-- DROP VIEW public.vehicles_dialog;

CREATE OR REPLACE VIEW public.vehicles_dialog AS 
	SELECT
		v.id,
		v.plate,
		v.load_capacity,
		v.make,
		v.owner,
		v.feature,
		v.tracker_id,
		v.sim_id,
		v.sim_number,
		NULL::text AS tracker_last_data_descr,
		CASE
			WHEN v.tracker_id IS NULL OR v.tracker_id::text = ''::text THEN NULL::timestamp without time zone
			ELSE (
				SELECT tr.recieved_dt + (now() - timezone('utc'::text, now())::timestamp with time zone)
				FROM car_tracking tr
				WHERE tr.car_id::text = v.tracker_id::text
				ORDER BY tr.period DESC
				LIMIT 1
			)
		END AS tracker_last_dt,
		
		drivers_ref(dr.*) AS drivers_ref,
		v.vehicle_owners,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		/*
		(SELECT 
			r.f_vals->'fields'->'owner'
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,
		*/
		
		v.vehicle_owner_id,
		/*
		(SELECT 
			CASE WHEN r.f_vals->'fields'->'owner'->'keys'->>'id'='null' THEN NULL
				ELSE (r.f_vals->'fields'->'owner'->'keys'->>'id')::int
			END
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owner_id,
		*/
		
		v.vehicle_owners_ar
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate
	;

ALTER TABLE public.vehicles_dialog
  OWNER TO beton;

