-- View: shipment_times_list

 DROP VIEW shipment_times_list;

CREATE OR REPLACE VIEW shipment_times_list AS 
	SELECT
		sh.id,
		
		o.client_id,		
		cl.name AS client_descr,
		
		o.destination_id,
		dest.name AS destination_descr,
		
		sh.quant,
		
		vh.vehicle_id,
		vehicles.plate AS vehicle_descr,
		
		vh.driver_id,
		drivers.name AS driver_descr,
		
		vh.assign_date_time,
		to_char(vh.assign_date_time,'dd/mm/yyyy HH24:MI') As assign_date_time_descr,
		sh.ship_date_time,
		to_char(sh.ship_date_time,'dd/mm/yyyy HH24:MI') As ship_date_time_descr,
		
		sh.production_site_id,
		production_sites.name AS production_site_descr,
		
		
		greatest(
			round(
				(date_part('epoch'::text,
					coalesce(vh.assign_date_time - 
						--any previous ship of the same shift
						(SELECT t_sh.ship_date_time
						FROM shipments AS t_sh
						WHERE t_sh.ship_date_time<vh.assign_date_time
							AND t_sh.ship_date_time>=get_shift_start(vh.assign_date_time)
						ORDER BY t_sh.ship_date_time DESC
						LIMIT 1
						)
					,'00:00:00'::interval)
					) / 60::double precision
				)::numeric
			,0)
		,0)
		AS dispatcher_fail_min,
				
		shipment_time_norm(sh.quant::numeric) AS ship_time_norm,
		
		round((date_part('epoch'::text, sh.ship_date_time - vh.assign_date_time) / 60::double precision)::numeric,0)
		- shipment_time_norm(sh.quant::numeric)::numeric
		AS operator_fail_min,
		
		--together
		greatest(
			round(
				(date_part('epoch'::text,
					coalesce(vh.assign_date_time - 
						--any previous ship of the same shift
						(SELECT t_sh.ship_date_time
						FROM shipments AS t_sh
						WHERE t_sh.ship_date_time<vh.assign_date_time
							AND t_sh.ship_date_time>=get_shift_start(vh.assign_date_time)
						ORDER BY t_sh.ship_date_time DESC
						LIMIT 1
						)
					,'00:00:00'::interval)
					) / 60::double precision
				)::numeric
			,0)
		,0)		
		+ (round((date_part('epoch'::text, sh.ship_date_time - vh.assign_date_time) / 60::double precision)::numeric, 0) - shipment_time_norm(sh.quant::numeric)::numeric)
		AS total_fail_min
		
		/*
		CASE
		WHEN round(
			(date_part('epoch'::text, COALESCE(vh.assign_date_time - (
			( SELECT t2.date_time
			FROM shipments t1
			LEFT JOIN vehicle_schedule_states t2 ON t2.shipment_id = t1.id AND t2.state = 'busy'::vehicle_states
			WHERE t1.date_time < sh.date_time AND get_shift_start(t1.date_time) = get_shift_start(sh.date_time)
			ORDER BY t1.date_time DESC
			LIMIT 1)
			), '00:00:00'::interval)) / 60::double precision)::numeric, 0) > 0::numeric
			THEN
				round((date_part('epoch'::text, COALESCE(vh.assign_date_time - (
				( SELECT t2.date_time
				FROM shipments t1
				LEFT JOIN vehicle_schedule_states t2 ON t2.shipment_id = t1.id AND t2.state = 'busy'::vehicle_states
				WHERE t1.date_time < sh.date_time AND get_shift_start(t1.date_time) = get_shift_start(sh.date_time)
				ORDER BY t1.date_time DESC
				LIMIT 1)
		), '00:00:00'::interval)) / 60::double precision)::numeric, 0)
		
		ELSE 0::numeric
		END AS dispatcher_fail_min,
		
		shipment_time_norm(sh.quant::numeric) AS ship_time_norm,
		round((date_part('epoch'::text, sh.ship_date_time - vh.assign_date_time) / 60::double precision)::numeric, 0) - shipment_time_norm(sh.quant::numeric)::numeric AS operator_fail_min,
		CASE
		WHEN round((date_part('epoch'::text, COALESCE(vh.assign_date_time - (( SELECT t2.date_time
		FROM shipments t1
		LEFT JOIN vehicle_schedule_states t2 ON t2.shipment_id = t1.id AND t2.state = 'busy'::vehicle_states
		WHERE t1.date_time < sh.date_time AND get_shift_start(t1.date_time) = get_shift_start(sh.date_time)
		ORDER BY t1.date_time DESC
		LIMIT 1)), '00:00:00'::interval)) / 60::double precision)::numeric, 0) > 0::numeric THEN round((date_part('epoch'::text, COALESCE(vh.assign_date_time - (( SELECT t2.date_time
		FROM shipments t1
		LEFT JOIN vehicle_schedule_states t2 ON t2.shipment_id = t1.id AND t2.state = 'busy'::vehicle_states
		WHERE t1.date_time < sh.date_time AND get_shift_start(t1.date_time) = get_shift_start(sh.date_time)
		ORDER BY t1.date_time DESC
		LIMIT 1)), '00:00:00'::interval)) / 60::double precision)::numeric, 0)
		ELSE 0::numeric
		END + (round((date_part('epoch'::text, sh.ship_date_time - vh.assign_date_time) / 60::double precision)::numeric, 0) - shipment_time_norm(sh.quant::numeric)::numeric) AS total_fail_min
		*/
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN (
		SELECT
			t.shipment_id,
			max(t.date_time) AS assign_date_time,
			vs.vehicle_id,
			vs.driver_id
		FROM vehicle_schedule_states t
		LEFT JOIN vehicle_schedules vs ON vs.id = t.schedule_id
		WHERE t.state = 'assigned'::vehicle_states
		GROUP BY t.shipment_id, vs.vehicle_id,vs.driver_id
	) vh ON vh.shipment_id = sh.id
	
	LEFT JOIN drivers ON drivers.id = vh.driver_id
	LEFT JOIN vehicles ON vehicles.id = vh.vehicle_id
	LEFT JOIN production_sites ON production_sites.id = sh.production_site_id
	
	ORDER BY sh.ship_date_time DESC;

ALTER TABLE shipment_times_list
  OWNER TO beton;

