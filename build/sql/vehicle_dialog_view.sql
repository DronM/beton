-- View: public.vehicle_dialog_view

 DROP VIEW public.vehicle_dialog_view;

CREATE OR REPLACE VIEW public.vehicle_dialog_view AS 
	SELECT
		v.id,
		v.plate,
		v.load_capacity,
		v.driver_id,
		dr.name AS driver_descr,		
		v.make,
		v.owner,
		v.feature,
		v.tracker_id,
		v.sim_id,
		v.sim_number,
		NULL AS tracker_last_data_descr,
		CASE
		WHEN v.tracker_id IS NULL OR v.tracker_id::text = ''::text THEN NULL
		ELSE (
			SELECT
				tr.recieved_dt + (now() - timezone('utc'::text, now())::timestamp with time zone)
			FROM car_tracking tr
			WHERE tr.car_id::text = v.tracker_id::text
			ORDER BY tr.period DESC
			LIMIT 1
		)
		END AS tracker_last_dt,
		
		drivers_ref(dr) AS drivers_ref
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id;

ALTER TABLE public.vehicle_dialog_view
  OWNER TO beton;

