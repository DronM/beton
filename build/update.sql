
-- SUPERUSER CODE
/*
CREATE USER beton WITH PASSWORD '159753';
CREATE DATABASE beton OWNER beton;
GRANT ALL PRIVILEGES ON DATABASE beton TO beton;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO beton;
*/

-- Table: logins

-- DROP TABLE logins;

CREATE TABLE public.logins
(
  id serial NOT NULL,
  date_time_in timestamp with time zone NOT NULL,
  date_time_out timestamp with time zone,
  ip character varying(15) NOT NULL,
  session_id character(128) NOT NULL,
  user_id integer,
  pub_key character(15),
  set_date_time timestamp without time zone DEFAULT now(),
  CONSTRAINT logins_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.logins
  OWNER TO beton;

-- Index: logins_session_id_idx

-- DROP INDEX logins_session_id_idx;

CREATE INDEX public.logins_session_id_idx
  ON public.logins
  USING btree
  (session_id COLLATE pg_catalog."default");

-- Index: users_pub_key_idx

-- DROP INDEX users_pub_key_idx;

CREATE INDEX public.users_pub_key_idx
  ON public.logins
  USING btree
  (pub_key COLLATE pg_catalog."default");

CREATE INDEX public.logins_users_index
  ON public.logins
  USING btree
  (user_id,date_time_in,date_time_out);

-- Function: logins_process()

-- DROP FUNCTION logins_process();

--Trigger function
CREATE OR REPLACE FUNCTION public.logins_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='UPDATE') THEN
		IF NEW.date_time_out IS NOT NULL THEN
			--DELETE FROM doc___t_tmp__ WHERE login_id=NEW.id;
		END IF;
		
		RETURN NEW;
	ELSE 
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.logins_process()
  OWNER TO beton;


-- Trigger: logins_trigger on logins

-- DROP TRIGGER logins_trigger ON logins;

CREATE TRIGGER public.logins_trigger
  AFTER UPDATE OR DELETE
  ON public.logins
  FOR EACH ROW
  EXECUTE PROCEDURE public.logins_process();



-- Table: sessions

-- DROP TABLE sessions;

CREATE TABLE public.sessions
(
  id character(128) NOT NULL,
  data text NOT NULL,
  pub_key character varying(15),
  set_time timestamp without time zone NOT NULL
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.sessions
  OWNER TO beton;

-- Index: sessions_pub_key_idx

-- DROP INDEX sessions_pub_key_idx;

CREATE INDEX public.sessions_pub_key_idx
  ON public.sessions
  USING btree
  (pub_key COLLATE pg_catalog."default");

-- Index: sessions_set_time_idx

-- DROP INDEX public.sessions_set_time_idx;

CREATE INDEX public.sessions_set_time_idx
  ON public.sessions
  USING btree
  (set_time);

-- Function: sess_gc(interval)

-- DROP FUNCTION sess_gc(interval);

CREATE OR REPLACE FUNCTION public.sess_gc(in_lifetime interval)
  RETURNS void AS
$BODY$	
	UPDATE public.logins
	SET date_time_out = now()
	WHERE session_id IN (SELECT id FROM public.sessions WHERE set_time<(now()-in_lifetime));
	
	DELETE FROM public.sessions WHERE set_time < (now()-in_lifetime);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.sess_gc(interval)
  OWNER TO beton;

-- Function: sess_write(character varying, text, character varying)

-- DROP FUNCTION sess_write(character varying, text, character varying);

CREATE OR REPLACE FUNCTION public.sess_write(
    in_id character varying,
    in_data text,
    in_remote_ip character varying)
  RETURNS void AS
$BODY$
BEGIN
	UPDATE public.sessions
	SET
		set_time = now(),
		data = in_data
	WHERE id = in_id;
	
	IF FOUND THEN
		RETURN;
	END IF;
	
	BEGIN
		INSERT INTO public.sessions (id, data, set_time)
		VALUES(in_id, in_data, now());
		
		INSERT INTO public.logins(date_time_in,ip,session_id)
		VALUES(now(),in_remote_ip,in_id);
		
	EXCEPTION WHEN OTHERS THEN
		UPDATE public.sessions
		SET
			set_time = now(),
			data = in_data
		WHERE id = in_id;
	END;
	
	RETURN;

END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.sess_write(character varying, text, character varying)
  OWNER TO beton;


-- ******************* update 04/06/2019 08:23:44 ******************
-- View: public.shipments_dialog

-- DROP VIEW public.shipments_dialog;

CREATE OR REPLACE VIEW public.shipments_dialog AS 
	SELECT
		sh.id,
		sh.date_time,
		sh.ship_date_time,
		sh.quant,
		destinations_ref(dest) As destinations_ref,
		clients_ref(cl) As clients_ref,
		vehicle_schedules_ref(vs,v,d) AS vehicle_schedules_ref,
		sh.shipped,
		sh.client_mark,
		sh.demurrage,
		sh.blanks_exist,
		production_sites_ref(ps) AS production_sites_ref,
		sh.acc_comment,
		
		v.vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_from
						ORDER BY pr_vals.quant_from ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		sh.pump_cost_edit,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS ship_cost,
		sh.ship_cost_edit,
		
		(sh_last.id=sh.id) AS order_last_shipment,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,FALSE) AS ship_cost_default,
		shipments_pump_cost(sh,o,dest,pvh,FALSE) AS pump_cost_default
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN (
		SELECT
			max(sh.ship_date_time) AS ship_date_time,
			sh.order_id,
			sum(sh.quant) AS quant
		FROM shipments AS sh
		GROUP BY sh.order_id
	) AS sh_t ON sh_t.order_id = sh.order_id
	LEFT JOIN (
		SELECT
			t.id,
			t.order_id,
			t.ship_date_time
		FROM shipments AS t
	) AS sh_last ON sh_last.order_id = sh_t.order_id AND sh_last.ship_date_time = sh_t.ship_date_time
	
	ORDER BY sh.date_time;

ALTER TABLE public.shipments_dialog
  OWNER TO beton;



-- ******************* update 04/06/2019 08:27:04 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		--calc_ship_cost(sh.*, dest.*, true) AS cost,
		/*
		CASE
			WHEN dest.id=const_self_ship_dest_id_val() THEN 0
			WHEN o.concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(dest.price,0))			
				END
				*
				CASE
					WHEN sh.quant>=7 THEN sh.quant
					WHEN dest.distance<=60 THEN greatest(5,sh.quant)
					ELSE 7
				END
		END*/
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_to
						ORDER BY pr_vals.quant_to ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		CASE
			WHEN coalesce(sh.quant,0)=0 THEN 0
			ELSE  round(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE)::numeric/sh.quant::numeric,2)
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit
		
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 04/06/2019 09:12:11 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_to
						ORDER BY pr_vals.quant_to ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		/*
		CASE
			WHEN coalesce(sh.quant,0)=0 THEN 0
			ELSE  round(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE)::numeric/sh.quant::numeric,2)
		END*/
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit
		
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 04/06/2019 09:24:10 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_to
						ORDER BY pr_vals.quant_to ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		/*
		CASE
			WHEN coalesce(sh.quant,0)=0 THEN 0
			ELSE  round(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE)::numeric/sh.quant::numeric,2)
		END*/
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 04/06/2019 09:33:10 ******************
﻿-- Function: shipments_pump_cost(shipments, orders, destinations, pump_vehicles, bool)

--DROP FUNCTION shipments_pump_cost(shipments, orders, destinations, pump_vehicles, bool);

CREATE OR REPLACE FUNCTION shipments_pump_cost(in_shipments shipments, in_orders orders, in_destinations destinations,
	in_pump_vehicles pump_vehicles, in_editable bool)
  RETURNS numeric(15,2) AS
$$
	SELECT
		CASE
			WHEN in_orders.pump_vehicle_id IS NULL THEN 0
			WHEN in_editable AND coalesce(in_shipments.pump_cost_edit,FALSE) THEN in_shipments.pump_cost::numeric(15,2)
			--last ship only!!!
			WHEN in_shipments.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=in_orders.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(in_orders.total_edit,FALSE) AND coalesce(in_orders.unload_price,0)>0 THEN in_orders.unload_price::numeric(15,2)
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*in_orders.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = in_pump_vehicles.pump_price_id
							AND in_orders.quant<=pr_vals.quant_to
						ORDER BY pr_vals.quant_to ASC
						LIMIT 1
						)::numeric(15,2)
				END
			ELSE 0	
		END
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION shipments_pump_cost(shipments, orders, destinations, pump_vehicles, bool) OWNER TO beton;



-- ******************* update 04/06/2019 09:40:59 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE date_time = v_date
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		DELETE FROM ra_materials
		WHERE date_time = v_date
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE date_time = v_date
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE date_time = v_date
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE date_time = v_date
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE date_time = v_date
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 10:07:20 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	--RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 10:08:32 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 10:22:06 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	--RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 10:25:34 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 10:30:43 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	--RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 10:33:20 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 10:38:26 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 10:39:04 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	--RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 10:53:54 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 11:08:46 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	--RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 04/06/2019 11:08:46 ******************
-- Function: public.mat_cons_correct_quant(date, integer, numeric)

-- DROP FUNCTION public.mat_cons_correct_quant(date, integer, numeric);

CREATE OR REPLACE FUNCTION public.mat_cons_correct_quant(
    in_date date,
    in_material_id integer,
    in_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_date timestamp without time zone;
	v_date_old_shift timestamp without time zone;
	v_new_quant numeric;
BEGIN
	-- calc date
	v_date = in_date + const_first_shift_start_time_val();
	v_date_old_shift = in_date::date + '07:00:00'::interval;--Раньше время было с 07:00!!
	
	--old consumption quant
	SELECT  coalesce(in_quant,0)-coalesce(sum(quant),0)
		INTO v_new_quant
	FROM ra_materials
	WHERE date_time BETWEEN v_date AND v_date+const_shift_length_time_val()-'00:00:01'::interval
		AND material_id=in_material_id
		AND deb=FALSE AND doc_type IS NOT NULL AND doc_id IS NOT NULL;
	
	--RAISE 'new_quant=%,v_date=%,in_quant=%',v_new_quant,v_date,in_quant;
	
	DELETE FROM ra_material_consumption
	WHERE 
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null;
		
	DELETE FROM ra_materials
	WHERE
		date_time = v_date_old_shift
		AND material_id=in_material_id
		AND doc_id IS null AND doc_type IS null	
		AND deb=false;			
		
	IF v_new_quant<>0 THEN	
		INSERT INTO ra_material_consumption
		(date_time, material_id,material_quant_corrected)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant);
		
		INSERT INTO ra_materials
		(date_time, material_id,quant,deb)
		VALUES
		(v_date_old_shift,in_material_id,v_new_quant,false);
		
	END IF;
	
	
	IF v_new_quant=0 THEN	
		DELETE FROM ra_material_consumption
		WHERE 
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
			
		DELETE FROM ra_materials
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;			
	ELSE
		--ra_material_consumption
		UPDATE ra_material_consumption
		SET material_quant_corrected = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_material_consumption
				(date_time, material_id,material_quant_corrected)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_material_consumption
				SET material_quant_corrected = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null;
			END;	
		END IF;
		
		/* ra_materials*/
		UPDATE ra_materials
		SET quant = v_new_quant
		WHERE
			date_time = v_date_old_shift
			AND material_id=in_material_id
			AND doc_id IS null AND doc_type IS null
			AND deb=false;
		
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO ra_materials
				(date_time, material_id,quant,deb)
				VALUES
				(v_date_old_shift,in_material_id,v_new_quant,false);
			EXCEPTION WHEN OTHERS THEN
				UPDATE ra_materials
				SET quant = v_new_quant
				WHERE 
					date_time = v_date_old_shift
					AND material_id=in_material_id
					AND doc_id IS null AND doc_type IS null
					AND deb=false;
			END;	
		END IF;
	END IF;
	
    RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.mat_cons_correct_quant(date, integer, numeric)
  OWNER TO beton;



-- ******************* update 06/06/2019 07:30:56 ******************
-- VIEW: shipments_for_veh_owner_list

--DROP VIEW shipments_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_veh_owner_list AS
	SELECT
		id,
		ship_date_time,
		destination_id,
		destinations_ref,
		concrete_type_id,
		concrete_types_ref,
		quant,
		vehicle_id,
		vehicles_ref,
		driver_id,
		drivers_ref,
		vehicle_owner_id,
		vehicle_owners_ref,
		cost,
		ship_cost_edit,
		pump_cost_edit,
		demurrage,
		demurrage_cost,
		acc_comment,
		owner_agreed,
		owner_agreed_date_time
		
	FROM shipments_list
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 06/06/2019 07:39:59 ******************
-- VIEW: shipments_pump_for_veh_owner_list

--DROP VIEW shipments_pump_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_pump_for_veh_owner_list AS
	SELECT
		last_ship_id,
		date_time,
		destinations_ref,
		destination_id,
		concrete_type_id,
		concrete_types_ref,
		quant,
		pump_cost,
		pump_vehicle_id,
		pump_vehicles_ref,
		pump_vehicle_owner_id,
		pump_vehicle_owners_ref,
		owner_pump_agreed,
		owner_pump_agreed_date_time,
		acc_comment
		
		
	FROM shipments_pump_list
	;
	
ALTER VIEW shipments_pump_for_veh_owner_list OWNER TO beton;


-- ******************* update 06/06/2019 09:12:40 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20010',
		'Shipment_Controller',
		'get_list',
		'ShipmentForVehOwnerList',
		'Документы',
		'Отгрузки для владельцев ТС',
		FALSE
		);
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20011',
		'Shipment_Controller',
		'get_pump_list',
		'ShipmentPumpList',
		'Документы',
		'Отгрузки (насосы) для владельцев ТС',
		FALSE
		);
	

-- ******************* update 06/06/2019 10:24:52 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_to
						ORDER BY pr_vals.quant_to ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		/*
		CASE
			WHEN coalesce(sh.quant,0)=0 THEN 0
			ELSE  round(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE)::numeric/sh.quant::numeric,2)
		END*/
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC NULLS FIRST;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 06/06/2019 10:30:01 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_to
						ORDER BY pr_vals.quant_to ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		/*
		CASE
			WHEN coalesce(sh.quant,0)=0 THEN 0
			ELSE  round(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE)::numeric/sh.quant::numeric,2)
		END*/
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	--ORDER BY sh.date_time DESC NULLS FIRST
	;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 06/06/2019 10:30:26 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_to
						ORDER BY pr_vals.quant_to ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		/*
		CASE
			WHEN coalesce(sh.quant,0)=0 THEN 0
			ELSE  round(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE)::numeric/sh.quant::numeric,2)
		END*/
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC
	;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 07/06/2019 07:05:30 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC
	LIMIT 60
	;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 07/06/2019 07:08:49 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC
	--LIMIT 60
	;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 07/06/2019 07:12:11 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC
	LIMIT 60
	;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 07/06/2019 07:19:41 ******************
-- View: public.shipments_list

-- DROP VIEW shipment_dates_list;
-- DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC
	--LIMIT 60
	;

ALTER TABLE public.shipments_list
  OWNER TO beton;



-- ******************* update 07/06/2019 16:32:04 ******************
﻿-- Function: shipments_cost(destinations, int, date, shipments, bool)

--DROP FUNCTION shipments_cost(destinations, int, date, shipments, bool);

CREATE OR REPLACE FUNCTION shipments_cost(in_destinations destinations, in_concrete_type_id int, in_date date, in_shipments shipments, in_editable bool)
  RETURNS numeric(15,2) AS
$$
	SELECT
		(CASE
			WHEN in_editable AND coalesce(in_shipments.ship_cost_edit,FALSE) THEN in_shipments.ship_cost
			WHEN in_destinations.id=const_self_ship_dest_id_val() THEN 0
			WHEN in_concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(in_destinations.special_price,FALSE) THEN coalesce(in_destinations.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=in_date AND sh_p.distance_to>=in_destinations.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(in_destinations.price,0))			
				END
				*
				CASE
					WHEN in_shipments.quant>=7 THEN in_shipments.quant
					WHEN in_destinations.distance<=60 THEN greatest(5,in_shipments.quant)
					ELSE 7
				END
		END)::numeric(15,2)
	;
$$
  LANGUAGE sql IMMUTABLE--VOLATILE
  COST 100;
ALTER FUNCTION shipments_cost(destinations, int, date, shipments, bool) OWNER TO beton;



-- ******************* update 07/06/2019 16:33:09 ******************
﻿-- Function: shipments_cost(destinations, int, date, shipments, bool)

--DROP FUNCTION shipments_cost(destinations, int, date, shipments, bool);

CREATE OR REPLACE FUNCTION shipments_cost(in_destinations destinations, in_concrete_type_id int, in_date date, in_shipments shipments, in_editable bool)
  RETURNS numeric(15,2) AS
$$
	SELECT
		(CASE
			WHEN in_editable AND coalesce(in_shipments.ship_cost_edit,FALSE) THEN in_shipments.ship_cost
			WHEN in_destinations.id=const_self_ship_dest_id_val() THEN 0
			WHEN in_concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(in_destinations.special_price,FALSE) THEN coalesce(in_destinations.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=in_date AND sh_p.distance_to>=in_destinations.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(in_destinations.price,0))			
				END
				*
				CASE
					WHEN in_shipments.quant>=7 THEN in_shipments.quant
					WHEN in_destinations.distance<=60 THEN greatest(5,in_shipments.quant)
					ELSE 7
				END
		END)::numeric(15,2)
	;
$$
  LANGUAGE sql VOLATILE --IMMUTABLE VOLATILE
  COST 100;
ALTER FUNCTION shipments_cost(destinations, int, date, shipments, bool) OWNER TO beton;



-- ******************* update 07/06/2019 16:36:37 ******************
﻿-- Function: shipments_cost(destinations, int, date, shipments, bool)

--DROP FUNCTION shipments_cost(destinations, int, date, shipments, bool);

CREATE OR REPLACE FUNCTION shipments_cost(in_destinations destinations, in_concrete_type_id int, in_date date, in_shipments shipments, in_editable bool)
  RETURNS numeric(15,2) AS
$$
	SELECT
		(CASE
			WHEN in_editable AND coalesce(in_shipments.ship_cost_edit,FALSE) THEN in_shipments.ship_cost
			WHEN in_destinations.id=const_self_ship_dest_id_val() THEN 0
			WHEN in_concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(in_destinations.special_price,FALSE) THEN coalesce(in_destinations.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=in_date AND sh_p.distance_to>=in_destinations.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(in_destinations.price,0))			
				END
				*
				CASE
					WHEN in_shipments.quant>=7 THEN in_shipments.quant
					WHEN in_destinations.distance<=60 THEN greatest(5,in_shipments.quant)
					ELSE 7
				END
		END)::numeric(15,2)
	;
$$
  LANGUAGE sql STABLE --IMMUTABLE VOLATILE
  COST 100;
ALTER FUNCTION shipments_cost(destinations, int, date, shipments, bool) OWNER TO beton;



-- ******************* update 07/06/2019 16:37:15 ******************
﻿-- Function: shipments_cost(destinations, int, date, shipments, bool)

--DROP FUNCTION shipments_cost(destinations, int, date, shipments, bool);

CREATE OR REPLACE FUNCTION shipments_cost(in_destinations destinations, in_concrete_type_id int, in_date date, in_shipments shipments, in_editable bool)
  RETURNS numeric(15,2) AS
$$
	SELECT
		(CASE
			WHEN in_editable AND coalesce(in_shipments.ship_cost_edit,FALSE) THEN in_shipments.ship_cost
			WHEN in_destinations.id=const_self_ship_dest_id_val() THEN 0
			WHEN in_concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(in_destinations.special_price,FALSE) THEN coalesce(in_destinations.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=in_date AND sh_p.distance_to>=in_destinations.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(in_destinations.price,0))			
				END
				*
				CASE
					WHEN in_shipments.quant>=7 THEN in_shipments.quant
					WHEN in_destinations.distance<=60 THEN greatest(5,in_shipments.quant)
					ELSE 7
				END
		END)::numeric(15,2)
	;
$$
  LANGUAGE sql VOLATILE --IMMUTABLE VOLATILE
  COST 100;
ALTER FUNCTION shipments_cost(destinations, int, date, shipments, bool) OWNER TO beton;



-- ******************* update 07/06/2019 16:42:27 ******************
-- View: public.shipments_list

 --DROP VIEW shipments_for_veh_owner_list;
 --DROP VIEW shipment_dates_list;
 --DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		--shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		(CASE
			WHEN coalesce(sh.ship_cost_edit,FALSE) THEN sh.ship_cost
			WHEN dest.id=const_self_ship_dest_id_val() THEN 0
			WHEN o.concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(dest.price,0))			
				END
				*
				CASE
					WHEN sh.quant>=7 THEN sh.quant
					WHEN dest.distance<=60 THEN greatest(5,sh.quant)
					ELSE 7
				END
		END)::numeric(15,2)
		AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		v_own.id AS vehicle_owner_id,
		
		--shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0
				WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost::numeric(15,2)
				--last ship only!!!
				WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
				THEN
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
				ELSE 0	
			END
		) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC
	--LIMIT 60
	;

ALTER TABLE public.shipments_list OWNER TO beton;



-- ******************* update 07/06/2019 16:44:23 ******************
-- VIEW: shipments_for_veh_owner_list

--DROP VIEW shipments_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_veh_owner_list AS
	SELECT
		id,
		ship_date_time,
		destination_id,
		destinations_ref,
		concrete_type_id,
		concrete_types_ref,
		quant,
		vehicle_id,
		vehicles_ref,
		driver_id,
		drivers_ref,
		vehicle_owner_id,
		vehicle_owners_ref,
		cost,
		ship_cost_edit,
		pump_cost_edit,
		demurrage,
		demurrage_cost,
		acc_comment,
		owner_agreed,
		owner_agreed_date_time
		
	FROM shipments_list
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 07/06/2019 16:45:13 ******************
-- View: shipment_dates_list

-- DROP VIEW shipment_dates_list;

CREATE OR REPLACE VIEW shipment_dates_list AS 
	SELECT
		sh.ship_date_time::date AS ship_date,
		
		sh.concrete_type_id,
		sh.concrete_types_ref::text,
		
		sh.destination_id,
		sh.destinations_ref::text,
		
		sh.client_id,
		sh.clients_ref::text,
		
		sh.production_site_id,
		sh.production_sites_ref::text,
		
		sum(sh.quant) AS quant,
		sum(sh.cost) AS ship_cost,
		
		sum(sh.demurrage) AS demurrage,
		sum(sh.demurrage_cost) AS demurrage_cost
		
	FROM shipments_list sh
	/*LEFT JOIN shipments sh_t ON sh_t.id = sh.id
	LEFT JOIN orders o ON o.id = sh_t.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	*/
	GROUP BY
		sh.ship_date_time::date,
		sh.concrete_type_id,
		sh.concrete_types_ref::text,
		sh.destination_id,
		sh.destinations_ref::text,
		sh.client_id,
		sh.clients_ref::text,
		sh.production_site_id,
		sh.production_sites_ref::text
		
	ORDER BY sh.ship_date_time::date DESC;

ALTER TABLE shipment_dates_list
  OWNER TO beton;



-- ******************* update 13/06/2019 15:54:47 ******************
-- VIEW: shipments_for_veh_owner_list

--DROP VIEW shipments_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_veh_owner_list AS
	SELECT
		id,
		ship_date_time,
		destination_id,
		destinations_ref,
		concrete_type_id,
		concrete_types_ref,
		quant,
		vehicle_id,
		vehicles_ref,
		driver_id,
		drivers_ref,
		vehicle_owner_id,
		vehicle_owners_ref,
		cost,
		ship_cost_edit,
		pump_cost_edit,
		demurrage,
		demurrage_cost,
		acc_comment,
		owner_agreed,
		owner_agreed_date_time,
		0 AS cost_for_driver
		
	FROM shipments_list
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 13/06/2019 16:14:02 ******************
-- VIEW: shipments_for_veh_owner_list

DROP VIEW shipments_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_veh_owner_list AS
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.destination_id,
		sh.destinations_ref,
		sh.concrete_type_id,
		sh.concrete_types_ref,
		sh.quant,
		sh.vehicle_id,
		sh.vehicles_ref,
		sh.driver_id,
		sh.drivers_ref,
		sh.vehicle_owner_id,
		sh.vehicle_owners_ref,
		sh.cost,
		sh.ship_cost_edit,
		sh.pump_cost_edit,
		sh.demurrage,
		sh.demurrage_cost,
		sh.acc_comment,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		(WITH
		act_price AS (SELECT h.date AS d FROM shipment_for_driver_costs_h h WHERE h.date<=sh.ship_date_time::date ORDER BY h.date DESC LIMIT 1)
		SELECT shdr_cost.price
		FROM shipment_for_driver_costs AS shdr_cost
		WHERE
			shdr_cost.date=(SELECT d FROM act_price)
			AND shdr_cost.distance_to<=dest.distance OR shdr_cost.id=(SELECT t.id FROM shipment_for_driver_costs t WHERE t.date=(SELECT d FROM act_price) ORDER BY t.distance_to LIMIT 1)

		ORDER BY shdr_cost.distance_to DESC
		LIMIT 1
		)*sh.quant AS cost_for_driver
		
	FROM shipments_list sh
	LEFT JOIN destinations AS dest ON dest.id=destination_id
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 14/06/2019 16:38:38 ******************
-- VIEW: operator_list

--DROP VIEW operator_list;

CREATE OR REPLACE VIEW operator_list AS
	SELECT
		u.id,
		u.name,
		u.email,
		u.phone_cel,
		production_sites_ref(ps) AS production_sites_ref
	FROM users AS u
	LEFT JOIN production_sites AS ps ON ps.id=u.production_site_id
	WHERE role_id='operator' AND NOT coalesce(banned,FALSE)
	ORDER BY u.name
	;
	
ALTER VIEW operator_list OWNER TO beton;


-- ******************* update 14/06/2019 16:39:49 ******************
-- VIEW: operator_list

DROP VIEW operator_list;
/*
CREATE OR REPLACE VIEW operator_list AS
	SELECT
		u.id,
		u.name,
		u.email,
		u.phone_cel,
		production_sites_ref(ps) AS production_sites_ref
	FROM users AS u
	LEFT JOIN production_sites AS ps ON ps.id=u.production_site_id
	WHERE role_id='operator' AND NOT coalesce(banned,FALSE)
	ORDER BY u.name
	;
	
ALTER VIEW operator_list OWNER TO beton;
*/


-- ******************* update 14/06/2019 16:40:50 ******************
-- VIEW: user_operator_list

--DROP VIEW user_operator_list;

CREATE OR REPLACE VIEW user_operator_list AS
	SELECT
		u.id,
		u.name,
		u.email,
		u.phone_cel,
		production_sites_ref(ps) AS production_sites_ref
	FROM users AS u
	LEFT JOIN production_sites AS ps ON ps.id=u.production_site_id
	WHERE role_id='operator' AND NOT coalesce(banned,FALSE)
	ORDER BY u.name
	;
	
ALTER VIEW user_operator_list OWNER TO beton;



-- ******************* update 14/06/2019 16:59:17 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10028',
		'User_Controller',
		'get_list',
		'UserOperatorList',
		'Справочники',
		'Список операторов',
		FALSE
		);
	

-- ******************* update 15/06/2019 08:23:59 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20012',
		'Shipment_Controller',
		'get_list_for_client_veh_owner',
		'ShipmentForClientVehOwnerList',
		'Документы',
		'Отгрузки по клиенту-владельцу ТС',
		FALSE
		);
	

-- ******************* update 15/06/2019 08:38:55 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.concrete_type_id,
		sh.concrete_types_ref,
		sh.quant,
		sh.vehicle_id,
		sh.vehicles_ref,
		sh.driver_id,
		sh.drivers_ref,
		sh.vehicle_owner_id,
		sh.vehicle_owners_ref
		
	FROM shipments_list sh
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 15/06/2019 08:52:19 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.concrete_type_id,
		sh.concrete_types_ref,
		sh.quant,
		sh.vehicle_id,
		sh.vehicles_ref,
		sh.driver_id,
		sh.drivers_ref,
		sh.vehicle_owner_id,
		sh.vehicle_owners_ref,
		sh.client_id
		
	FROM shipments_list sh
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 18/06/2019 06:18:35 ******************
-- View: public.order_pumps_list_view

 DROP VIEW public.order_pumps_list_view;

CREATE OR REPLACE VIEW public.order_pumps_list_view AS 
	SELECT
		order_num(o.*) AS number,
		clients_ref(cl) AS clients_ref,
		o.client_id,
		destinations_ref(d) AS destinations_ref,
		o.destination_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,
		o.unload_type,
		o.comment_text AS comment_text,
		o.descr AS descr,		
		o.date_time,
		o.quant,
		o.id AS order_id,
		op.viewed,
		op.comment,
		users_ref(u) AS users_ref,
		o.user_id,
		o.phone_cel,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id
		
		
	FROM orders o
	LEFT JOIN order_pumps op ON o.id = op.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	LEFT JOIN (
		SELECT
			t.order_id,
			sum(t.quant) AS quant
		FROM shipments t
		GROUP BY t.order_id
	) AS ships ON ships.order_id = o.id
	
	WHERE o.pump_vehicle_id IS NOT NULL
		AND o.unload_type<>'none'
		AND (coalesce(o.quant,0) - ships.quant) <> 0
	ORDER BY o.date_time DESC;

ALTER TABLE public.order_pumps_list_view
  OWNER TO beton;



-- ******************* update 19/06/2019 10:16:07 ******************
-- View: public.order_pumps_list_view

-- DROP VIEW public.order_pumps_list_view;

CREATE OR REPLACE VIEW public.order_pumps_list_view AS 
	SELECT
		order_num(o.*) AS number,
		clients_ref(cl) AS clients_ref,
		o.client_id,
		destinations_ref(d) AS destinations_ref,
		o.destination_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,
		o.unload_type,
		o.comment_text AS comment_text,
		o.descr AS descr,		
		o.date_time,
		o.quant,
		o.id AS order_id,
		op.viewed,
		op.comment,
		users_ref(u) AS users_ref,
		o.user_id,
		o.phone_cel,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id
		
		
	FROM orders o
	LEFT JOIN order_pumps op ON o.id = op.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	LEFT JOIN (
		SELECT
			t.order_id,
			sum(t.quant) AS quant
		FROM shipments t
		GROUP BY t.order_id
	) AS ships ON ships.order_id = o.id
	
	WHERE o.pump_vehicle_id IS NOT NULL
		AND o.unload_type<>'none'
		AND (coalesce(o.quant,0) - coalesce(ships.quant,0)) <> 0
	ORDER BY o.date_time DESC;

ALTER TABLE public.order_pumps_list_view
  OWNER TO beton;



-- ******************* update 20/06/2019 05:39:22 ******************

		CREATE TABLE concrete_costs_for_owner_h
		(id serial NOT NULL,create_date date,comment_text text,CONSTRAINT concrete_costs_for_owner_h_pkey PRIMARY KEY (id)
		);
		ALTER TABLE concrete_costs_for_owner_h OWNER TO beton;
		CREATE TABLE concrete_costs_for_owner
		(id serial NOT NULL,header_id int NOT NULL REFERENCES concrete_costs_for_owner_h(id),concrete_type_id int REFERENCES concrete_types(id),price  numeric(15,2),CONSTRAINT concrete_costs_for_owner_pkey PRIMARY KEY (id)
		);
		ALTER TABLE concrete_costs_for_owner OWNER TO beton;
		ALTER TABLE vehicle_owners ADD COLUMN concrete_costs_for_owner_h_id int REFERENCES concrete_costs_for_owner_h(id);



-- ******************* update 20/06/2019 05:41:59 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10029',
		'ConcreteCostForOwnerHeader_Controller',
		'get_list',
		'ConcreteCostForOwnerHeaderList',
		'Справочники',
		'Прайс бетон для владельцев',
		FALSE
		);
	

-- ******************* update 20/06/2019 05:56:34 ******************
-- Function: public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h)

-- DROP FUNCTION public.concrete_costs_for_owner_h(concrete_costs_for_owner_h);

CREATE OR REPLACE FUNCTION public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.comment_text||' ('||to_char($1.create_date,'DD/MM/YY')||')',
		'dataType','concrete_costs_for_owner_h'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h) OWNER TO beton;



-- ******************* update 20/06/2019 05:56:34 ******************
-- Function: public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h)

-- DROP FUNCTION public.concrete_costs_for_owner_h(concrete_costs_for_owner_h);

CREATE OR REPLACE FUNCTION public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.comment_text||' ('||to_char($1.create_date,'DD/MM/YY')||')',
		'dataType','concrete_costs_for_owner_h'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h) OWNER TO beton;



-- ******************* update 20/06/2019 05:56:40 ******************
-- Function: public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h)

-- DROP FUNCTION public.concrete_costs_for_owner_h(concrete_costs_for_owner_h);

CREATE OR REPLACE FUNCTION public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.comment_text||' ('||to_char($1.create_date,'DD/MM/YY')||')',
		'dataType','concrete_costs_for_owner_h'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h) OWNER TO beton;



-- ******************* update 20/06/2019 05:57:15 ******************
-- Function: public.vehicles_ref(vehicles)

-- DROP FUNCTION public.vehicles_ref(vehicles);

CREATE OR REPLACE FUNCTION public.vehicles_ref(vehicles)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.plate,
		'dataType','vehicles'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicles_ref(vehicles) OWNER TO beton;



-- ******************* update 20/06/2019 06:13:28 ******************
-- VIEW: concrete_costs_for_owner_list

--DROP VIEW concrete_costs_for_owner_list;

CREATE OR REPLACE VIEW concrete_costs_for_owner_list AS
	SELECT
		t.id,
		t.header_id,
		t.price,
		t.concrete_type_id,
		concrete_types_ref(ctp) AS concrete_types_ref
	FROM concrete_costs_for_owner t
	LEFT JOIN concrete_types AS ctp ON ctp.id=t.concrete_type_id
	ORDER BY t.header_id,ctp.name
	;
	
ALTER VIEW concrete_costs_for_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 06:14:47 ******************
-- VIEW: vehicle_owners_list

--DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		concrete_costs_for_owner_h_ref(pr) AS concrete_costs_for_owner_h_ref
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=own.concrete_costs_for_owner_h_id
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO beton;


-- ******************* update 20/06/2019 06:59:43 ******************
-- VIEW: assigned_vehicles_list

--DROP VIEW assigned_vehicles_list;

CREATE OR REPLACE VIEW assigned_vehicles_list AS
	SELECT
		sh.id,
		sh.date_time,
		destinations_ref(dest) AS destinations_ref,
		drivers_ref(dr) AS drivers_ref,
		vehicles_ref(vh) AS vehicles_ref,
		production_sites_ref(ps) AS production_sites_ref,
		sh.quant,
		sh.production_site_id AS production_site_id
		
	FROM shipments AS sh
	LEFT JOIN orders o ON o.id=sh.order_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_schedules AS vsc ON vsc.id=sh.vehicle_schedule_id
	LEFT JOIN drivers AS dr ON dr.id=vsc.driver_id
	LEFT JOIN vehicles AS vh ON vh.id=vsc.vehicle_id
	LEFT JOIN production_sites AS ps ON ps.id=sh.production_site_id
	WHERE sh.ship_date_time IS NULL
		AND sh.date_time BETWEEN get_shift_start(now()::timestamp) AND get_shift_end(get_shift_start(now()::timestamp))
	ORDER BY ps.name,sh.date_time ASC
	;
	
ALTER VIEW assigned_vehicles_list OWNER TO beton;


-- ******************* update 20/06/2019 07:05:36 ******************
-- View: public.order_pumps_list_view

-- DROP VIEW public.order_pumps_list_view;

CREATE OR REPLACE VIEW public.order_pumps_list_view AS 
	SELECT
		order_num(o.*) AS number,
		clients_ref(cl) AS clients_ref,
		o.client_id,
		destinations_ref(d) AS destinations_ref,
		o.destination_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,
		o.unload_type,
		o.comment_text AS comment_text,
		o.descr AS descr,		
		o.date_time,
		o.quant,
		o.id AS order_id,
		op.viewed,
		op.comment,
		users_ref(u) AS users_ref,
		o.user_id,
		o.phone_cel,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id
		
		
	FROM orders o
	LEFT JOIN order_pumps op ON o.id = op.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	LEFT JOIN (
		SELECT
			t.order_id,
			sum(t.quant) AS quant
		FROM shipments t
		GROUP BY t.order_id
	) AS ships ON ships.order_id = o.id
	
	WHERE o.pump_vehicle_id IS NOT NULL
		AND o.unload_type<>'none'
		AND (coalesce(o.quant,0) - coalesce(ships.quant,0)) <> 0
	ORDER BY o.date_time ASC;

ALTER TABLE public.order_pumps_list_view
  OWNER TO beton;



-- ******************* update 20/06/2019 07:27:24 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		0 AS cost_shipment,
		0 AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 07:29:31 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		0 AS cost_shipment,
		0 AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 07:29:58 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		0 AS cost_shipment,
		0 AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 07:36:37 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		0 AS cost_shipment,
		coalesce(pr.price) AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owners AS vown ON vown.client_id=o.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.id=vown.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 07:42:27 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price) AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owners AS vown ON vown.client_id=o.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.id=vown.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 07:43:32 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price) AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owners AS vown ON vown.client_id=o.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.id=vown.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 07:47:28 ******************
﻿-- Function: shipments_cost(destinations, int, date, shipments, bool)

--DROP FUNCTION shipments_cost(destinations, int, date, shipments, bool);

CREATE OR REPLACE FUNCTION shipments_cost(in_destinations destinations, in_concrete_type_id int, in_date date, in_shipments shipments, in_editable bool)
  RETURNS numeric(15,2) AS
$$
	SELECT
		coalesce(
		(CASE
			WHEN in_editable AND coalesce(in_shipments.ship_cost_edit,FALSE) THEN in_shipments.ship_cost
			WHEN in_destinations.id=const_self_ship_dest_id_val() THEN 0
			WHEN in_concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(in_destinations.special_price,FALSE) THEN coalesce(in_destinations.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=in_date AND sh_p.distance_to>=in_destinations.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(in_destinations.price,0))			
				END
				*
				CASE
					WHEN in_shipments.quant>=7 THEN in_shipments.quant
					WHEN in_destinations.distance<=60 THEN greatest(5,in_shipments.quant)
					ELSE 7
				END
		END)::numeric(15,2)
		,0)
	;
$$
  LANGUAGE sql VOLATILE --IMMUTABLE VOLATILE
  COST 100;
ALTER FUNCTION shipments_cost(destinations, int, date, shipments, bool) OWNER TO beton;



-- ******************* update 20/06/2019 07:49:39 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0) AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owners AS vown ON vown.client_id=o.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.id=vown.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 07:56:44 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0) AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owners AS vown ON vown.client_id=o.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id=vown.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 07:58:43 ******************

	CREATE UNIQUE INDEX concrete_costs_for_owner_header_concrete_idx
	ON concrete_costs_for_owner(header_id,concrete_type_id);



-- ******************* update 20/06/2019 08:26:55 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owners AS vown ON vown.client_id=o.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id=vown.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 20/06/2019 09:02:00 ******************

		ALTER TABLE vehicle_owner_concrete_prices ADD COLUMN concrete_costs_for_owner_h_id int REFERENCES concrete_costs_for_owner_h(id);



-- ******************* update 20/06/2019 09:05:25 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10030',
		'VehicleOwnerConcretePrice_Controller',
		'get_list',
		'VehicleOwnerConcretePriceList',
		'Справочники',
		'История прайсов по бетону для владельцев',
		FALSE
		);
	

-- ******************* update 20/06/2019 09:14:43 ******************
-- VIEW: vehicle_owner_concrete_prices_list

--DROP VIEW vehicle_owner_concrete_prices_list;

CREATE OR REPLACE VIEW vehicle_owner_concrete_prices_list AS
	SELECT
		t.vehicle_owner_id,
		t.date,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		concrete_costs_for_owner_h_ref(pr_h) AS concrete_costs_for_owner_h_ref
		
	FROM vehicle_owner_concrete_prices AS t
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h pr_h ON pr_h.id=t.concrete_costs_for_owner_h_id
	;
	
ALTER VIEW vehicle_owner_concrete_prices_list OWNER TO beton;


-- ******************* update 20/06/2019 12:10:26 ******************

		CREATE TABLE vehicle_owner_clients
		(vehicle_owner_id int NOT NULL REFERENCES vehicle_owners(id),client_id int NOT NULL REFERENCES clients(id),CONSTRAINT vehicle_owner_clients_pkey PRIMARY KEY (vehicle_owner_id,client_id)
		);
		ALTER TABLE vehicle_owner_clients OWNER TO beton;



-- ******************* update 20/06/2019 12:14:07 ******************
-- VIEW: vehicle_owner_clients_list

--DROP VIEW vehicle_owner_clients_list;

CREATE OR REPLACE VIEW vehicle_owner_clients_list AS
	SELECT
		t.vehicle_owner_id,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref
		  
	FROM vehicle_owner_clients t
	LEFT JOIN clients cl ON cl.id=t.client_id
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	;
	
ALTER VIEW vehicle_owner_clients_list OWNER TO beton;


-- ******************* update 20/06/2019 12:16:35 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10031',
		'VehicleOwnerClient_Controller',
		'get_list',
		'VehicleOwnerClientList',
		'Справочники',
		'Клиенты владельцев ТС',
		FALSE
		);
	

-- ******************* update 20/06/2019 12:33:50 ******************
-- VIEW: vehicle_owners_list

--DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		concrete_costs_for_owner_h_ref(pr) AS concrete_costs_for_owner_h_ref,
		vown_cl.client_list
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=own.concrete_costs_for_owner_h_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO beton;


-- ******************* update 20/06/2019 12:43:14 ******************
-- VIEW: vehicle_owners_list

--DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		concrete_costs_for_owner_h_ref(pr_temp) AS concrete_costs_for_owner_h_ref,
		vown_cl.client_list,
		concrete_costs_for_owner_h_ref(pr) AS last_concrete_costs_for_owner_h_ref
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN concrete_costs_for_owner_h AS pr_temp ON pr_temp.id=own.concrete_costs_for_owner_h_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id=own.id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO beton;


-- ******************* update 21/06/2019 07:22:46 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 21/06/2019 07:28:46 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_vehicle_owner_accord_from_day
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_vehicle_owner_accord_from_day OWNER TO beton;
		INSERT INTO const_vehicle_owner_accord_from_day (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Номер дня месяца'
			,'Номер дня месяца, начиная с которого владельцы ТС могу согласовывать отгрузки за предыдущий месяц'
			,5
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_vehicle_owner_accord_from_day_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_vehicle_owner_accord_from_day LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_vehicle_owner_accord_from_day_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_vehicle_owner_accord_from_day_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_vehicle_owner_accord_from_day SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_vehicle_owner_accord_from_day_set_val(Int) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_vehicle_owner_accord_from_day_view AS
		SELECT
			'vehicle_owner_accord_from_day'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_vehicle_owner_accord_from_day AS t
		;
		ALTER VIEW const_vehicle_owner_accord_from_day_view OWNER TO beton;
		--constant value table
		CREATE TABLE IF NOT EXISTS const_vehicle_owner_accord_to_day
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_vehicle_owner_accord_to_day OWNER TO beton;
		INSERT INTO const_vehicle_owner_accord_to_day (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Номер дня месяца'
			,'Номер дня месяца, до которого владельцы ТС могу согласовывать отгрузки за предыдущий месяц'
			,20
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_vehicle_owner_accord_to_day_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_vehicle_owner_accord_to_day LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_vehicle_owner_accord_to_day_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_vehicle_owner_accord_to_day_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_vehicle_owner_accord_to_day SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_vehicle_owner_accord_to_day_set_val(Int) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_vehicle_owner_accord_to_day_view AS
		SELECT
			'vehicle_owner_accord_to_day'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_vehicle_owner_accord_to_day AS t
		;
		ALTER VIEW const_vehicle_owner_accord_to_day_view OWNER TO beton;
		CREATE OR REPLACE VIEW constants_list_view AS
		SELECT *
		FROM const_doc_per_page_count_view
		UNION ALL
		SELECT *
		FROM const_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_order_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_backup_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_id_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_view
		UNION ALL
		SELECT *
		FROM const_chart_step_min_view
		UNION ALL
		SELECT *
		FROM const_day_shift_length_view
		UNION ALL
		SELECT *
		FROM const_days_allowed_with_broken_tracker_view
		UNION ALL
		SELECT *
		FROM const_def_order_unload_speed_view
		UNION ALL
		SELECT *
		FROM const_demurrage_coast_per_hour_view
		UNION ALL
		SELECT *
		FROM const_first_shift_start_time_view
		UNION ALL
		SELECT *
		FROM const_geo_zone_check_points_count_view
		UNION ALL
		SELECT *
		FROM const_map_default_lat_view
		UNION ALL
		SELECT *
		FROM const_map_default_lon_view
		UNION ALL
		SELECT *
		FROM const_max_hour_load_view
		UNION ALL
		SELECT *
		FROM const_max_vehicle_at_work_view
		UNION ALL
		SELECT *
		FROM const_min_demurrage_time_view
		UNION ALL
		SELECT *
		FROM const_min_quant_for_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_no_tracker_signal_warn_interval_view
		UNION ALL
		SELECT *
		FROM const_ord_mark_if_no_ship_time_view
		UNION ALL
		SELECT *
		FROM const_order_auto_place_tolerance_view
		UNION ALL
		SELECT *
		FROM const_order_step_min_view
		UNION ALL
		SELECT *
		FROM const_own_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_raw_mater_plcons_rep_def_days_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_id_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_view
		UNION ALL
		SELECT *
		FROM const_shift_for_orders_length_time_view
		UNION ALL
		SELECT *
		FROM const_shift_length_time_view
		UNION ALL
		SELECT *
		FROM const_ship_coast_for_self_ship_destination_view
		UNION ALL
		SELECT *
		FROM const_speed_change_for_order_autolocate_view
		UNION ALL
		SELECT *
		FROM const_vehicle_unload_time_view
		UNION ALL
		SELECT *
		FROM const_avg_mat_cons_dev_day_count_view
		UNION ALL
		SELECT *
		FROM const_days_for_plan_procur_view
		UNION ALL
		SELECT *
		FROM const_lab_min_sample_count_view
		UNION ALL
		SELECT *
		FROM const_lab_days_for_avg_view
		UNION ALL
		SELECT *
		FROM const_city_ext_view
		UNION ALL
		SELECT *
		FROM const_def_lang_view
		UNION ALL
		SELECT *
		FROM const_efficiency_warn_k_view
		UNION ALL
		SELECT *
		FROM const_zone_violation_alarm_interval_view
		UNION ALL
		SELECT *
		FROM const_weather_update_interval_sec_view
		UNION ALL
		SELECT *
		FROM const_call_history_count_view
		UNION ALL
		SELECT *
		FROM const_water_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_from_day_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_to_day_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	

-- ******************* update 21/06/2019 08:51:23 ******************
﻿-- Function: shipment_accord_allowed(in_ship_date date)

-- DROP FUNCTION shipment_accord_allowed(in_ship_date date);

CREATE OR REPLACE FUNCTION shipment_accord_allowed(in_ship_date date)
  RETURNS table(
  	d_from date,
  	d_to date
  ) AS
$$
	WITH
			mon AS (
				SELECT
					CASE WHEN extract('month' FROM in_ship_date)=1 THEN 12
						ELSE extract('month' FROM in_ship_date)-1
					END AS v
			),
			d_from AS (
				SELECT (
					(CASE WHEN (SELECT v FROM mon)=12 THEN extract('year' FROM in_ship_date)-1 ELSE extract('year' FROM in_ship_date) END)::text
					||'-'|| (CASE WHEN (SELECT v FROM mon)<10 THEN '0' ELSE '' END )||(SELECT v FROM mon) ||'-01'
				)::date AS v
			)
	SELECT	
		(SELECT v FROM d_from) AS d_from,
		((SELECT v FROM d_from) + '1 month'::interval - '1 day'::interval)::date AS d_to
	;	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION shipment_accord_allowed(in_ship_date date) OWNER TO beton;


-- ******************* update 21/06/2019 09:06:09 ******************
﻿-- Function: shipment_accord_allowed(in_ship_date date)

-- DROP FUNCTION shipment_accord_allowed(in_ship_date date);

CREATE OR REPLACE FUNCTION shipment_accord_allowed(in_ship_date date)
  RETURNS table(
  	d_from date,
  	d_to date
  ) AS
$$
	WITH
			mon AS (
				SELECT
					CASE WHEN extract('month' FROM in_ship_date)=12 THEN 1
						ELSE extract('month' FROM in_ship_date)+1
					END AS v
			),
			accord_from_d AS (SELECT const_vehicle_owner_accord_from_day_val() v),
			accord_to_d AS (SELECT const_vehicle_owner_accord_to_day_val() v),
			year_mon AS (
				SELECT
					(CASE
						WHEN (SELECT v FROM mon)=12 THEN extract('year' FROM in_ship_date)+1
						ELSE extract('year' FROM in_ship_date)
					END)::text||
					'-'||
					(CASE
						WHEN (SELECT v FROM mon)<10 THEN '0'
						ELSE ''
					END)||
					(SELECT v FROM mon)::text ||'-'
					AS v				
			)
	SELECT
		(
		(SELECT v FROM year_mon)||
		(CASE WHEN (SELECT v FROM accord_from_d)<10 THEN '0' ELSE '0' END) || (SELECT v FROM accord_from_d)
		)::date AS d_from,
		(
		(SELECT v FROM year_mon)||
		(CASE WHEN (SELECT v FROM accord_to_d)<10 THEN '0' ELSE '0' END) || (SELECT v FROM accord_to_d)
		)::date AS d_to
	;	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION shipment_accord_allowed(in_ship_date date) OWNER TO beton;


-- ******************* update 22/06/2019 06:04:58 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END AS other_owner_pump_cost
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 22/06/2019 06:06:38 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		NULL vehicle_id,
		NULL vehicles_ref,
		NULL driver_id,
		NULL drivers_ref,
		NULL vehicle_owner_id,
		NULL AS vehicle_owners_ref,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END AS cost_other_owner_pump
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 22/06/2019 06:57:36 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END AS cost_other_owner_pumps,
		
		vown_cl.vehicle_owner_id
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 22/06/2019 08:35:53 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 23/06/2019 06:46:41 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'30013',
		'VehicleOwnerTotReport_Controller',
		'get_tot_report',
		'VehicleOwnerTotReport',
		'Формы',
		'Итоги для владельца ТС',
		FALSE
		);
	

-- ******************* update 26/06/2019 06:05:47 ******************
-- VIEW: vehicle_owners_list

--DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		concrete_costs_for_owner_h_ref(pr_temp) AS concrete_costs_for_owner_h_ref,
		coalesce(vown_cl.client_list,'') AS client_list,
		concrete_costs_for_owner_h_ref(pr) AS last_concrete_costs_for_owner_h_ref
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN concrete_costs_for_owner_h AS pr_temp ON pr_temp.id=own.concrete_costs_for_owner_h_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id=own.id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO beton;


-- ******************* update 26/06/2019 06:06:07 ******************
-- VIEW: vehicle_owners_list

--DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		concrete_costs_for_owner_h_ref(pr_temp) AS concrete_costs_for_owner_h_ref,
		coalesce(vown_cl.client_list,' ') AS client_list,
		concrete_costs_for_owner_h_ref(pr) AS last_concrete_costs_for_owner_h_ref
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN concrete_costs_for_owner_h AS pr_temp ON pr_temp.id=own.concrete_costs_for_owner_h_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id=own.id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO beton;


-- ******************* update 26/06/2019 11:55:39 ******************

		ALTER TABLE shipments ADD COLUMN acc_comment_shipment text;



-- ******************* update 26/06/2019 11:57:31 ******************
-- View: public.shipments_dialog

 DROP VIEW public.shipments_dialog;

CREATE OR REPLACE VIEW public.shipments_dialog AS 
	SELECT
		sh.id,
		sh.date_time,
		sh.ship_date_time,
		sh.quant,
		destinations_ref(dest) As destinations_ref,
		clients_ref(cl) As clients_ref,
		vehicle_schedules_ref(vs,v,d) AS vehicle_schedules_ref,
		sh.shipped,
		sh.client_mark,
		sh.demurrage,
		sh.blanks_exist,
		production_sites_ref(ps) AS production_sites_ref,
		sh.acc_comment,
		sh.acc_comment_shipment,
		
		v.vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_from
						ORDER BY pr_vals.quant_from ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		sh.pump_cost_edit,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS ship_cost,
		sh.ship_cost_edit,
		
		(sh_last.id=sh.id) AS order_last_shipment,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,FALSE) AS ship_cost_default,
		shipments_pump_cost(sh,o,dest,pvh,FALSE) AS pump_cost_default
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN (
		SELECT
			max(sh.ship_date_time) AS ship_date_time,
			sh.order_id,
			sum(sh.quant) AS quant
		FROM shipments AS sh
		GROUP BY sh.order_id
	) AS sh_t ON sh_t.order_id = sh.order_id
	LEFT JOIN (
		SELECT
			t.id,
			t.order_id,
			t.ship_date_time
		FROM shipments AS t
	) AS sh_last ON sh_last.order_id = sh_t.order_id AND sh_last.ship_date_time = sh_t.ship_date_time
	
	ORDER BY sh.date_time;

ALTER TABLE public.shipments_dialog
  OWNER TO beton;



-- ******************* update 26/06/2019 11:57:43 ******************
-- View: public.shipments_list

DROP VIEW shipments_for_veh_owner_list;
DROP VIEW shipment_dates_list;
DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		--shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		(CASE
			WHEN coalesce(sh.ship_cost_edit,FALSE) THEN sh.ship_cost
			WHEN dest.id=const_self_ship_dest_id_val() THEN 0
			WHEN o.concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(dest.price,0))			
				END
				*
				CASE
					WHEN sh.quant>=7 THEN sh.quant
					WHEN dest.distance<=60 THEN greatest(5,sh.quant)
					ELSE 7
				END
		END)::numeric(15,2)
		AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		sh.acc_comment_shipment,
		v_own.id AS vehicle_owner_id,
		
		--shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0
				WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost::numeric(15,2)
				--last ship only!!!
				WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
				THEN
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
				ELSE 0	
			END
		) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC
	--LIMIT 60
	;

ALTER TABLE public.shipments_list OWNER TO beton;



-- ******************* update 26/06/2019 11:57:51 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 26/06/2019 11:58:03 ******************
-- View: shipment_dates_list

-- DROP VIEW shipment_dates_list;

CREATE OR REPLACE VIEW shipment_dates_list AS 
	SELECT
		sh.ship_date_time::date AS ship_date,
		
		sh.concrete_type_id,
		sh.concrete_types_ref::text,
		
		sh.destination_id,
		sh.destinations_ref::text,
		
		sh.client_id,
		sh.clients_ref::text,
		
		sh.production_site_id,
		sh.production_sites_ref::text,
		
		sum(sh.quant) AS quant,
		sum(sh.cost) AS ship_cost,
		
		sum(sh.demurrage) AS demurrage,
		sum(sh.demurrage_cost) AS demurrage_cost
		
	FROM shipments_list sh
	/*LEFT JOIN shipments sh_t ON sh_t.id = sh.id
	LEFT JOIN orders o ON o.id = sh_t.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	*/
	GROUP BY
		sh.ship_date_time::date,
		sh.concrete_type_id,
		sh.concrete_types_ref::text,
		sh.destination_id,
		sh.destinations_ref::text,
		sh.client_id,
		sh.clients_ref::text,
		sh.production_site_id,
		sh.production_sites_ref::text
		
	ORDER BY sh.ship_date_time::date DESC;

ALTER TABLE shipment_dates_list
  OWNER TO beton;



-- ******************* update 26/06/2019 12:00:20 ******************
-- VIEW: shipments_for_veh_owner_list

--DROP VIEW shipments_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_veh_owner_list AS
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.destination_id,
		sh.destinations_ref,
		sh.concrete_type_id,
		sh.concrete_types_ref,
		sh.quant,
		sh.vehicle_id,
		sh.vehicles_ref,
		sh.driver_id,
		sh.drivers_ref,
		sh.vehicle_owner_id,
		sh.vehicle_owners_ref,
		sh.cost,
		sh.ship_cost_edit,
		sh.pump_cost_edit,
		sh.demurrage,
		sh.demurrage_cost,
		sh.acc_comment,
		sh.acc_comment_shipment,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		(WITH
		act_price AS (SELECT h.date AS d FROM shipment_for_driver_costs_h h WHERE h.date<=sh.ship_date_time::date ORDER BY h.date DESC LIMIT 1)
		SELECT shdr_cost.price
		FROM shipment_for_driver_costs AS shdr_cost
		WHERE
			shdr_cost.date=(SELECT d FROM act_price)
			AND shdr_cost.distance_to<=dest.distance OR shdr_cost.id=(SELECT t.id FROM shipment_for_driver_costs t WHERE t.date=(SELECT d FROM act_price) ORDER BY t.distance_to LIMIT 1)

		ORDER BY shdr_cost.distance_to DESC
		LIMIT 1
		)*sh.quant AS cost_for_driver
		
	FROM shipments_list sh
	LEFT JOIN destinations AS dest ON dest.id=destination_id
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 26/06/2019 12:45:11 ******************

WITH
	--миксеры,водители,простой
	ships AS (
		SELECT
			sum(cost) AS cost,
			sum(cost_for_driver) AS cost_for_driver,
			sum(demurrage_cost) AS demurrage_cost
		FROM shipments_for_veh_owner_list AS t
		WHERE
			t.vehicle_owner_id = 156
			AND t.ship_date_time BETWEEN '2019-05-01 06:00' AND '2019-06-01 05:59:59'
	)
	
	--насосы
	,pumps AS (
		SELECT
			sum(t.pump_cost) AS cost
		FROM shipments_pump_list t
		WHERE
			t.pump_vehicle_owner_id = 156
			AND t.date_time BETWEEN '2019-05-01 06:00' AND '2019-06-01 05:59:59'
	)
	,
	client_ships AS (
		SELECT
			sum(t.cost_concrete) AS cost_concrete,
			sum(t.cost_shipment) AS cost_shipment
		FROM shipments_for_client_veh_owner_list t
		WHERE	
			t.vehicle_owner_id = 156
			AND t.ship_date BETWEEN '2019-05-01 06:00' AND '2019-06-01 05:59:59'
	)
SELECT
	(SELECT coalesce(cost,0) FROM ships) AS ship_cost,
	(SELECT coalesce(cost_for_driver,0) FROM ships) AS ship_for_driver_cost,
	(SELECT coalesce(demurrage_cost,0) FROM ships) AS ship_demurrage_cost,
	(SELECT coalesce(cost,0) FROM pumps) AS pumps_cost,
	(SELECT coalesce(cost_concrete,0) FROM client_ships) AS client_ships_concrete_cost,
	(SELECT coalesce(cost_shipment,0) FROM client_ships) AS client_ships_shipment_cost


-- ******************* update 26/06/2019 14:07:52 ******************
-- VIEW: vehicle_owner_clients_list

--DROP VIEW vehicle_owner_clients_list;

CREATE OR REPLACE VIEW vehicle_owner_clients_list AS
	SELECT
		t.vehicle_owner_id,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref,
		concrete_costs_for_owner_h_ref(pr) AS last_concrete_costs_for_owner_h_ref
		  
	FROM vehicle_owner_clients t
	LEFT JOIN clients cl ON cl.id=t.client_id
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id=vown.id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	;
	
ALTER VIEW vehicle_owner_clients_list OWNER TO beton;


-- ******************* update 26/06/2019 14:14:08 ******************
-- VIEW: vehicle_owner_concrete_prices_list

--DROP VIEW vehicle_owner_concrete_prices_list;

CREATE OR REPLACE VIEW vehicle_owner_concrete_prices_list AS
	SELECT
		t.vehicle_owner_id,
		t.date,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		concrete_costs_for_owner_h_ref(pr_h) AS concrete_costs_for_owner_h_ref
		
	FROM vehicle_owner_concrete_prices AS t
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h pr_h ON pr_h.id=t.concrete_costs_for_owner_h_id
	LEFT JOIN clients cl ON cl.id=t.client_id
	;
	
ALTER VIEW vehicle_owner_concrete_prices_list OWNER TO beton;


-- ******************* update 26/06/2019 14:14:28 ******************
-- VIEW: vehicle_owner_concrete_prices_list

--DROP VIEW vehicle_owner_concrete_prices_list;

CREATE OR REPLACE VIEW vehicle_owner_concrete_prices_list AS
	SELECT
		t.vehicle_owner_id,
		t.date,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		concrete_costs_for_owner_h_ref(pr_h) AS concrete_costs_for_owner_h_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref
		
	FROM vehicle_owner_concrete_prices AS t
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h pr_h ON pr_h.id=t.concrete_costs_for_owner_h_id
	LEFT JOIN clients cl ON cl.id=t.client_id
	;
	
ALTER VIEW vehicle_owner_concrete_prices_list OWNER TO beton;


-- ******************* update 26/06/2019 14:21:09 ******************
-- VIEW: vehicle_owner_concrete_prices_list

--DROP VIEW vehicle_owner_concrete_prices_list;

CREATE OR REPLACE VIEW vehicle_owner_concrete_prices_list AS
	SELECT
		t.vehicle_owner_id,
		t.date,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		concrete_costs_for_owner_h_ref(pr_h) AS concrete_costs_for_owner_h_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref
		
	FROM vehicle_owner_concrete_prices AS t
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h pr_h ON pr_h.id=t.concrete_costs_for_owner_h_id
	LEFT JOIN clients cl ON cl.id=t.client_id
	;
	
ALTER VIEW vehicle_owner_concrete_prices_list OWNER TO beton;


-- ******************* update 27/06/2019 07:33:36 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		(SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 27/06/2019 10:35:32 ******************
-- VIEW: vehicle_owners_list

DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		concrete_costs_for_owner_h_ref(pr_temp) AS concrete_costs_for_owner_h_ref,
		coalesce(vown_cl.client_list,' ') AS client_list
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN concrete_costs_for_owner_h AS pr_temp ON pr_temp.id=own.concrete_costs_for_owner_h_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id=own.id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO beton;


-- ******************* update 27/06/2019 10:36:54 ******************
-- VIEW: vehicle_owners_list

DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		coalesce(vown_cl.client_list,' ') AS client_list
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN concrete_costs_for_owner_h AS pr_temp ON pr_temp.id=own.concrete_costs_for_owner_h_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id=own.id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO beton;


-- ******************* update 27/06/2019 10:37:20 ******************
-- VIEW: vehicle_owners_list

DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		coalesce(vown_cl.client_list,' ') AS client_list
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id
	) AS pr_last ON pr_last.vehicle_owner_id=own.id
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO beton;


-- ******************* update 27/06/2019 10:38:03 ******************
-- VIEW: vehicle_owners_list

--DROP VIEW vehicle_owners_list;

CREATE OR REPLACE VIEW vehicle_owners_list AS
	SELECT
		own.id,
		own.name,
		clients_ref(cl) AS clients_ref,
		users_ref(u) AS users_ref,
		coalesce(vown_cl.client_list,' ') AS client_list
		
	FROM vehicle_owners AS own
	LEFT JOIN clients AS cl ON cl.id=own.client_id
	LEFT JOIN users AS u ON u.id=own.user_id
	LEFT JOIN (
		SELECT
			t.vehicle_owner_id,
			string_agg(t_cl.name,', ') AS client_list
		FROM vehicle_owner_clients t
		LEFT JOIN clients t_cl ON t_cl.id=t.client_id
		GROUP BY t.vehicle_owner_id
	) AS vown_cl ON vown_cl.vehicle_owner_id = own.id
	
	ORDER BY own.name
	;
	
ALTER VIEW vehicle_owners_list OWNER TO beton;


-- ******************* update 27/06/2019 10:43:48 ******************
-- VIEW: vehicle_owner_clients_list

--DROP VIEW vehicle_owner_clients_list;

CREATE OR REPLACE VIEW vehicle_owner_clients_list AS
	SELECT
		t.vehicle_owner_id,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref,
		concrete_costs_for_owner_h_ref(pr) AS last_concrete_costs_for_owner_h_ref
		  
	FROM vehicle_owner_clients t
	LEFT JOIN clients cl ON cl.id=t.client_id
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id,
			t_pr.client_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id=vown.id AND pr_last.client_id=vown.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.date = pr_last.max_date AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	;
	
ALTER VIEW vehicle_owner_clients_list OWNER TO beton;


-- ******************* update 27/06/2019 11:02:21 ******************
-- VIEW: vehicle_owner_clients_list

--DROP VIEW vehicle_owner_clients_list;

CREATE OR REPLACE VIEW vehicle_owner_clients_list AS
	SELECT
		t.vehicle_owner_id,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref,
		concrete_costs_for_owner_h_ref(pr) AS last_concrete_costs_for_owner_h_ref
		  
	FROM vehicle_owner_clients t
	LEFT JOIN clients cl ON cl.id=t.client_id
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id,
			t_pr.client_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id=vown.id AND pr_last.client_id=vown.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h
		ON pr_h.date = pr_last.max_date
		AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
		AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	;
	
ALTER VIEW vehicle_owner_clients_list OWNER TO beton;


-- ******************* update 27/06/2019 11:04:44 ******************
-- VIEW: vehicle_owner_clients_list

--DROP VIEW vehicle_owner_clients_list;

CREATE OR REPLACE VIEW vehicle_owner_clients_list AS
	SELECT
		t.vehicle_owner_id,
		vehicle_owners_ref(vown) AS vehicle_owners_ref,
		t.client_id,
		clients_ref(cl) AS clients_ref,
		concrete_costs_for_owner_h_ref(pr) AS last_concrete_costs_for_owner_h_ref
		  
	FROM vehicle_owner_clients t
	LEFT JOIN clients cl ON cl.id=t.client_id
	LEFT JOIN vehicle_owners vown ON vown.id=t.vehicle_owner_id
	
	LEFT JOIN (
		SELECT
			max(t_pr.date) AS max_date,
			t_pr.vehicle_owner_id,
			t_pr.client_id
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id=vown.id AND pr_last.client_id=t.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h
		ON pr_h.date = pr_last.max_date
		AND pr_h.vehicle_owner_id=pr_last.vehicle_owner_id
		AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner_h AS pr ON pr.id=pr_h.concrete_costs_for_owner_h_id
	;
	
ALTER VIEW vehicle_owner_clients_list OWNER TO beton;


-- ******************* update 27/06/2019 14:03:57 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 27/06/2019 14:11:27 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(pr.price,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(pr.price,0)*o.quant::numeric + 
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 28/06/2019 11:39:34 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=156 AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=156 AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric +
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	
	/*
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	*/
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 28/06/2019 11:41:07 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time::date AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric +
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	
	/*
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	*/
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 28/06/2019 14:24:35 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric +
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	
	/*
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	*/
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 03/07/2019 05:33:14 ******************

		ALTER TABLE shipments ADD COLUMN pump_for_client_cost  numeric(15,2),ADD COLUMN pump_for_client_cost_edit bool
			DEFAULT FALSE;



-- ******************* update 03/07/2019 05:37:02 ******************
-- View: public.shipments_list

--DROP VIEW shipments_for_veh_owner_list;
--DROP VIEW shipment_dates_list;
--DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		--shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		(CASE
			WHEN coalesce(sh.ship_cost_edit,FALSE) THEN sh.ship_cost
			WHEN dest.id=const_self_ship_dest_id_val() THEN 0
			WHEN o.concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(dest.price,0))			
				END
				*
				CASE
					WHEN sh.quant>=7 THEN sh.quant
					WHEN dest.distance<=60 THEN greatest(5,sh.quant)
					ELSE 7
				END
		END)::numeric(15,2)
		AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		sh.acc_comment_shipment,
		v_own.id AS vehicle_owner_id,
		
		--shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0
				WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost::numeric(15,2)
				--last ship only!!!
				WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
				THEN
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
				ELSE 0	
			END
		) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit,
		
		sh.pump_for_client_cost_edit,
		(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0
				WHEN coalesce(sh.pump_for_client_cost_edit,FALSE) THEN sh.pump_for_client_cost::numeric(15,2)
				--last ship only!!!
				WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
				THEN
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
				ELSE 0	
			END
		) AS pump_for_client_cost
		
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC
	--LIMIT 60
	;

ALTER TABLE public.shipments_list OWNER TO beton;



-- ******************* update 03/07/2019 06:05:53 ******************
-- View: public.shipments_dialog

-- DROP VIEW public.shipments_dialog;

CREATE OR REPLACE VIEW public.shipments_dialog AS 
	SELECT
		sh.id,
		sh.date_time,
		sh.ship_date_time,
		sh.quant,
		destinations_ref(dest) As destinations_ref,
		clients_ref(cl) As clients_ref,
		vehicle_schedules_ref(vs,v,d) AS vehicle_schedules_ref,
		sh.shipped,
		sh.client_mark,
		sh.demurrage,
		sh.blanks_exist,
		production_sites_ref(ps) AS production_sites_ref,
		sh.acc_comment,
		sh.acc_comment_shipment,
		
		v.vehicle_owner_id,
		
		/*
		CASE
			WHEN o.pump_vehicle_id IS NULL THEN 0
			WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost
			--last ship only!!!
			WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
			THEN
				CASE
					WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
					ELSE
						(SELECT
							CASE
								WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
								ELSE coalesce(pr_vals.price_m,0)*o.quant
							END
						FROM pump_prices_values AS pr_vals
						WHERE pr_vals.pump_price_id = pvh.pump_price_id
							AND dest.distance<=pr_vals.quant_from
						ORDER BY pr_vals.quant_from ASC
						LIMIT 1
						)
				END
			ELSE 0	
		END*/
		shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		sh.pump_cost_edit,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS ship_cost,
		sh.ship_cost_edit,
		
		(sh_last.id=sh.id) AS order_last_shipment,
		
		shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,FALSE) AS ship_cost_default,
		shipments_pump_cost(sh,o,dest,pvh,FALSE) AS pump_cost_default,
		
		sh.pump_for_client_cost_edit,
		(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0
				WHEN coalesce(sh.pump_for_client_cost_edit,FALSE) THEN sh.pump_for_client_cost::numeric(15,2)
				--last ship only!!!
				WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
				THEN
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
				ELSE 0	
			END
		) AS pump_for_client_cost,
		(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0
				--last ship only!!!
				WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
				THEN
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
				ELSE 0	
			END
		) AS pump_for_client_cost_default
		
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN (
		SELECT
			max(sh.ship_date_time) AS ship_date_time,
			sh.order_id,
			sum(sh.quant) AS quant
		FROM shipments AS sh
		GROUP BY sh.order_id
	) AS sh_t ON sh_t.order_id = sh.order_id
	LEFT JOIN (
		SELECT
			t.id,
			t.order_id,
			t.ship_date_time
		FROM shipments AS t
	) AS sh_last ON sh_last.order_id = sh_t.order_id AND sh_last.ship_date_time = sh_t.ship_date_time
	
	ORDER BY sh.date_time;

ALTER TABLE public.shipments_dialog
  OWNER TO beton;



-- ******************* update 03/07/2019 06:41:14 ******************
-- VIEW: shipments_for_veh_client_owner_list

--DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_for_client_cost_edit,FALSE) THEN last_sh.pump_for_client_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric +
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	
	/*
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	*/
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 04/07/2019 15:59:30 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		clients_ref(cl) AS clients_ref,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_for_client_cost_edit,FALSE) THEN last_sh.pump_for_client_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		--простой
		coalesce(demurrage.cost,0) AS cost_demurrage,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric +
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		
		+coalesce(demurrage.cost,0)
		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	
	/*
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	*/
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			sum(shipments_demurrage_cost(t.demurrage::interval)) AS cost		
		FROM shipments AS t
		GROUP BY t.order_id
	) AS demurrage ON demurrage.order_id=o.id
	
	LEFT JOIN clients cl ON cl.id = o.client_id
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 04/07/2019 16:04:38 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		clients_ref(cl) AS clients_ref,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_for_client_cost_edit,FALSE) THEN last_sh.pump_for_client_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		--простой
		coalesce(demurrage.cost,0) AS cost_demurrage,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric +
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		
		+coalesce(demurrage.cost,0)
		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	
	/*
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	*/
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			sum(coalesce(shipments_demurrage_cost(t.demurrage::interval),0.00)) AS cost		
		FROM shipments AS t
		GROUP BY t.order_id
	) AS demurrage ON demurrage.order_id=o.id
	
	LEFT JOIN clients cl ON cl.id = o.client_id
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 04/07/2019 16:08:48 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		clients_ref(cl) AS clients_ref,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_for_client_cost_edit,FALSE) THEN last_sh.pump_for_client_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		--простой
		coalesce(demurrage.cost,0.00) AS cost_demurrage,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric +
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		
		+coalesce(demurrage.cost,0.00)
		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	
	/*
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	*/
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			sum(coalesce(shipments_demurrage_cost(t.demurrage::interval),0.00)) AS cost		
		FROM shipments AS t
		GROUP BY t.order_id
	) AS demurrage ON demurrage.order_id=o.id
	
	LEFT JOIN clients cl ON cl.id = o.client_id
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 04/07/2019 16:14:19 ******************
-- VIEW: shipments_for_veh_client_owner_list

DROP VIEW shipments_for_client_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_client_veh_owner_list AS
	SELECT
		o.id,
		o.date_time AS ship_date,
		o.concrete_type_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		o.quant,
		o.client_id AS client_id,
		clients_ref(cl) AS clients_ref,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric AS cost_concrete,
		
		--стоимость чужего насоса, если есть
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_for_client_cost_edit,FALSE) THEN last_sh.pump_for_client_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2) AS cost_other_owner_pump,
		
		vown_cl.vehicle_owner_id,
		
		
		--простой
		coalesce(demurrage.cost,0.00)::numeric(15,2) AS cost_demurrage,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) + 
		coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric +
		coalesce(
		CASE
			WHEN o.pump_vehicle_id IS NULL OR pvh_v.vehicle_owner_id=vown_cl.vehicle_owner_id THEN 0::numeric(15,2)
			WHEN coalesce(last_sh.pump_cost_edit,FALSE) THEN last_sh.pump_cost::numeric(15,2)
			WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)::numeric(15,2)
			
		END,0)::numeric(15,2)		
		
		+coalesce(demurrage.cost,0.00)
		
		AS cost_total
		
	FROM orders o
	LEFT JOIN concrete_types AS ct ON ct.id=o.concrete_type_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owner_clients AS vown_cl ON vown_cl.client_id=o.client_id	
	
	/*
	LEFT JOIN (
		SELECT
			t_pr.vehicle_owner_id,
			t_pr.client_id,
			max(t_pr.date) AS last_date
		FROM vehicle_owner_concrete_prices AS t_pr
		GROUP BY t_pr.vehicle_owner_id,t_pr.client_id
	) AS pr_last ON pr_last.vehicle_owner_id = vown_cl.vehicle_owner_id AND pr_last.client_id = vown_cl.client_id
	
	LEFT JOIN vehicle_owner_concrete_prices AS pr_h ON pr_h.vehicle_owner_id=pr_last.vehicle_owner_id AND pr_h.date=pr_last.last_date AND pr_h.client_id=pr_last.client_id
	LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_h.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
	*/
	
	LEFT JOIN (
		SELECT
			t.order_id,
			max(t.ship_date_time) AS ship_date_time
		FROM shipments t
		GROUP BY t.order_id
	) AS last_sh_t ON last_sh_t.order_id = o.id	
	LEFT JOIN shipments last_sh ON last_sh.order_id = last_sh_t.order_id AND last_sh.ship_date_time = last_sh_t.ship_date_time
	
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	
	LEFT JOIN (
		SELECT
			t.order_id,
			sum(coalesce(shipments_demurrage_cost(t.demurrage::interval),0.00)) AS cost		
		FROM shipments AS t
		GROUP BY t.order_id
	) AS demurrage ON demurrage.order_id=o.id
	
	LEFT JOIN clients cl ON cl.id = o.client_id
	
	ORDER BY o.date_time DESC
	;
	
ALTER VIEW shipments_for_client_veh_owner_list OWNER TO beton;


-- ******************* update 05/07/2019 14:27:24 ******************
﻿-- Function: shipments_quant_for_cost(in_quant numeric,in_distance numeric)

-- DROP FUNCTION shipments_quant_for_cost(in_quant numeric,in_distance numeric);

CREATE OR REPLACE FUNCTION shipments_quant_for_cost(in_quant numeric,in_distance numeric)
  RETURNS numeric AS
$$
	SELECT
		CASE
			WHEN in_quant>=7 THEN in_quant
			WHEN in_distance<=60 THEN greatest(5,in_quant)
			ELSE 7
		END
	;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION shipments_quant_for_cost(in_quant numeric,in_distance numeric) OWNER TO beton;


-- ******************* update 05/07/2019 14:28:11 ******************
-- VIEW: shipments_for_veh_owner_list

DROP VIEW shipments_for_veh_owner_list;

CREATE OR REPLACE VIEW shipments_for_veh_owner_list AS
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.destination_id,
		sh.destinations_ref,
		sh.concrete_type_id,
		sh.concrete_types_ref,
		sh.quant,
		sh.vehicle_id,
		sh.vehicles_ref,
		sh.driver_id,
		sh.drivers_ref,
		sh.vehicle_owner_id,
		sh.vehicle_owners_ref,
		sh.cost,
		sh.ship_cost_edit,
		sh.pump_cost_edit,
		sh.demurrage,
		sh.demurrage_cost,
		sh.acc_comment,
		sh.acc_comment_shipment,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		(WITH
		act_price AS (
			SELECT h.date AS d
			FROM shipment_for_driver_costs_h h
			WHERE h.date<=sh.ship_date_time::date
			ORDER BY h.date DESC
			LIMIT 1
		)
		SELECT shdr_cost.price
		FROM shipment_for_driver_costs AS shdr_cost
		WHERE
			shdr_cost.date=(SELECT d FROM act_price)
			AND shdr_cost.distance_to<=dest.distance
			OR shdr_cost.id=(
				SELECT t.id
				FROM shipment_for_driver_costs t
				WHERE t.date=(SELECT d FROM act_price)
				ORDER BY t.distance_to LIMIT 1
			)

		ORDER BY shdr_cost.distance_to DESC
		LIMIT 1
		) * shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric) AS cost_for_driver
		
	FROM shipments_list sh
	LEFT JOIN destinations AS dest ON dest.id=destination_id
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 05/07/2019 14:29:07 ******************
-- View: public.shipments_list

--DROP VIEW shipments_for_veh_owner_list;
--DROP VIEW shipment_dates_list;
--DROP VIEW public.shipments_list;

CREATE OR REPLACE VIEW public.shipments_list AS 
	SELECT
		sh.id,
		sh.ship_date_time,
		sh.quant,
		
		--shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
		(CASE
			WHEN coalesce(sh.ship_cost_edit,FALSE) THEN sh.ship_cost
			WHEN dest.id=const_self_ship_dest_id_val() THEN 0
			WHEN o.concrete_type_id=12 THEN const_water_ship_cost_val()
			ELSE
				CASE
					WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(dest.price,0))			
				END
				*
				shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)
				/*
				CASE
					WHEN sh.quant>=7 THEN sh.quant
					WHEN dest.distance<=60 THEN greatest(5,sh.quant)
					ELSE 7
				END
				*/
		END)::numeric(15,2)
		AS cost,
		
		sh.shipped,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.concrete_type_id,		
		v.owner,
		
		vehicles_ref(v) AS vehicles_ref,
		vs.vehicle_id,
		
		drivers_ref(d) AS drivers_ref,
		vs.driver_id,
		
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		shipments_demurrage_cost(sh.demurrage::interval) AS demurrage_cost,
		sh.demurrage,
		
		sh.client_mark,
		sh.blanks_exist,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh.production_site_id,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
		sh.acc_comment,
		sh.acc_comment_shipment,
		v_own.id AS vehicle_owner_id,
		
		--shipments_pump_cost(sh,o,dest,pvh,TRUE) AS pump_cost,
		(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0
				WHEN coalesce(sh.pump_cost_edit,FALSE) THEN sh.pump_cost::numeric(15,2)
				--last ship only!!!
				WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
				THEN
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
				ELSE 0	
			END
		) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		sh.owner_agreed,
		sh.owner_agreed_date_time,
		sh.owner_pump_agreed,
		sh.owner_pump_agreed_date_time,
		
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
		CASE
			WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
			ELSE
			coalesce(
				(SELECT sh_p.price
				FROM shipment_for_owner_costs sh_p
				WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
				ORDER BY sh_p.date DESC,sh_p.distance_to ASC
				LIMIT 1
				),			
			coalesce(dest.price,0))			
		END AS ship_price,
		
		coalesce(sh.ship_cost_edit,FALSE) AS ship_cost_edit,
		coalesce(sh.pump_cost_edit,FALSE) AS pump_cost_edit,
		
		sh.pump_for_client_cost_edit,
		(SELECT
			CASE
				WHEN o.pump_vehicle_id IS NULL THEN 0
				WHEN coalesce(sh.pump_for_client_cost_edit,FALSE) THEN sh.pump_for_client_cost::numeric(15,2)
				--last ship only!!!
				WHEN sh.id = (SELECT this_ship.id FROM shipments AS this_ship WHERE this_ship.order_id=o.id ORDER BY this_ship.ship_date_time DESC LIMIT 1)
				THEN
					CASE
						WHEN coalesce(o.total_edit,FALSE) AND coalesce(o.unload_price,0)>0 THEN o.unload_price::numeric(15,2)
						ELSE
							(SELECT
								CASE
									WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
									ELSE coalesce(pr_vals.price_m,0)*o.quant
								END
							FROM pump_prices_values AS pr_vals
							WHERE pr_vals.pump_price_id = pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
				ELSE 0	
			END
		) AS pump_for_client_cost
		
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	LEFT JOIN users u ON u.id = sh.user_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	ORDER BY sh.date_time DESC
	--LIMIT 60
	;

ALTER TABLE public.shipments_list OWNER TO beton;



-- ******************* update 06/07/2019 07:02:18 ******************
-- VIEW: logins_list

--DROP VIEW logins_list;

CREATE OR REPLACE VIEW logins_list AS
	SELECT
		t.id,
		t.date_time_in,
		t.date_time_out,
		t.ip,
		t.user_id,
		users_ref(u) AS users_ref,
		t.pub_key,
		t.set_date_time
		
	FROM logins AS t
	LEFT JOIN users u ON u.id=t.user_id
	;
	
ALTER VIEW logins_list OWNER TO beton;


-- ******************* update 06/07/2019 07:07:21 ******************
-- VIEW: logins_list

--DROP VIEW logins_list;

CREATE OR REPLACE VIEW logins_list AS
	SELECT
		t.id,
		t.date_time_in,
		t.date_time_out,
		t.ip,
		t.user_id,
		users_ref(u) AS users_ref,
		t.pub_key,
		t.set_date_time
		
	FROM logins AS t
	LEFT JOIN users u ON u.id=t.user_id
	ORDER BY t.date_time_in
	;
	
ALTER VIEW logins_list OWNER TO beton;


-- ******************* update 06/07/2019 07:13:44 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20013',
		'Login_Controller',
		'get_list',
		'LoginList',
		'Документы',
		'Лог активности',
		FALSE
		);
	

-- ******************* update 06/07/2019 07:17:12 ******************
-- VIEW: logins_list

--DROP VIEW logins_list;

CREATE OR REPLACE VIEW logins_list AS
	SELECT
		t.id,
		t.date_time_in,
		t.date_time_out,
		t.ip,
		t.user_id,
		users_ref(u) AS users_ref,
		t.pub_key,
		t.set_date_time
		
	FROM logins AS t
	LEFT JOIN users u ON u.id=t.user_id
	ORDER BY t.date_time_in DESC
	;
	
ALTER VIEW logins_list OWNER TO beton;


-- ******************* update 06/07/2019 07:21:23 ******************
-- VIEW: logins_list

--DROP VIEW logins_list;

CREATE OR REPLACE VIEW logins_list AS
	SELECT
		t.id,
		t.date_time_in,
		t.date_time_out,
		t.ip,
		t.user_id,
		users_ref(u) AS users_ref,
		t.pub_key,
		t.set_date_time
		
	FROM logins AS t
	LEFT JOIN users u ON u.id=t.user_id
	WHERE t.user_id IS NOT NULL
	ORDER BY t.date_time_in DESC
	;
	
ALTER VIEW logins_list OWNER TO beton;


-- ******************* update 09/07/2019 16:04:51 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_show_time_for_shipped_vehicles
		(name text, descr text, val interval,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_show_time_for_shipped_vehicles OWNER TO beton;
		INSERT INTO const_show_time_for_shipped_vehicles (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Время показа отргруженных ТС'
			,'Время, в течении которого показывать отгруженные ТС на большом экране'
			,
				'00:30'
			,'Interval'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_show_time_for_shipped_vehicles_val()
		RETURNS interval AS
		$BODY$
			SELECT val::interval AS val FROM const_show_time_for_shipped_vehicles LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_show_time_for_shipped_vehicles_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_show_time_for_shipped_vehicles_set_val(Interval)
		RETURNS void AS
		$BODY$
			UPDATE const_show_time_for_shipped_vehicles SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_show_time_for_shipped_vehicles_set_val(Interval) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_show_time_for_shipped_vehicles_view AS
		SELECT
			'show_time_for_shipped_vehicles'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_show_time_for_shipped_vehicles AS t
		;
		ALTER VIEW const_show_time_for_shipped_vehicles_view OWNER TO beton;
		CREATE OR REPLACE VIEW constants_list_view AS
		SELECT *
		FROM const_doc_per_page_count_view
		UNION ALL
		SELECT *
		FROM const_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_order_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_backup_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_id_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_view
		UNION ALL
		SELECT *
		FROM const_chart_step_min_view
		UNION ALL
		SELECT *
		FROM const_day_shift_length_view
		UNION ALL
		SELECT *
		FROM const_days_allowed_with_broken_tracker_view
		UNION ALL
		SELECT *
		FROM const_def_order_unload_speed_view
		UNION ALL
		SELECT *
		FROM const_demurrage_coast_per_hour_view
		UNION ALL
		SELECT *
		FROM const_first_shift_start_time_view
		UNION ALL
		SELECT *
		FROM const_geo_zone_check_points_count_view
		UNION ALL
		SELECT *
		FROM const_map_default_lat_view
		UNION ALL
		SELECT *
		FROM const_map_default_lon_view
		UNION ALL
		SELECT *
		FROM const_max_hour_load_view
		UNION ALL
		SELECT *
		FROM const_max_vehicle_at_work_view
		UNION ALL
		SELECT *
		FROM const_min_demurrage_time_view
		UNION ALL
		SELECT *
		FROM const_min_quant_for_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_no_tracker_signal_warn_interval_view
		UNION ALL
		SELECT *
		FROM const_ord_mark_if_no_ship_time_view
		UNION ALL
		SELECT *
		FROM const_order_auto_place_tolerance_view
		UNION ALL
		SELECT *
		FROM const_order_step_min_view
		UNION ALL
		SELECT *
		FROM const_own_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_raw_mater_plcons_rep_def_days_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_id_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_view
		UNION ALL
		SELECT *
		FROM const_shift_for_orders_length_time_view
		UNION ALL
		SELECT *
		FROM const_shift_length_time_view
		UNION ALL
		SELECT *
		FROM const_ship_coast_for_self_ship_destination_view
		UNION ALL
		SELECT *
		FROM const_speed_change_for_order_autolocate_view
		UNION ALL
		SELECT *
		FROM const_vehicle_unload_time_view
		UNION ALL
		SELECT *
		FROM const_avg_mat_cons_dev_day_count_view
		UNION ALL
		SELECT *
		FROM const_days_for_plan_procur_view
		UNION ALL
		SELECT *
		FROM const_lab_min_sample_count_view
		UNION ALL
		SELECT *
		FROM const_lab_days_for_avg_view
		UNION ALL
		SELECT *
		FROM const_city_ext_view
		UNION ALL
		SELECT *
		FROM const_def_lang_view
		UNION ALL
		SELECT *
		FROM const_efficiency_warn_k_view
		UNION ALL
		SELECT *
		FROM const_zone_violation_alarm_interval_view
		UNION ALL
		SELECT *
		FROM const_weather_update_interval_sec_view
		UNION ALL
		SELECT *
		FROM const_call_history_count_view
		UNION ALL
		SELECT *
		FROM const_water_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_from_day_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_to_day_view
		UNION ALL
		SELECT *
		FROM const_show_time_for_shipped_vehicles_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	

-- ******************* update 09/07/2019 16:14:27 ******************
-- VIEW: shipped_vehicles_list

--DROP VIEW shipped_vehicles_list;

CREATE OR REPLACE VIEW shipped_vehicles_list AS
	SELECT
		t.id,
		now()-ship_date_time AS elapsed_time,
		destinations_ref(dest) AS destinations_ref,
		drivers_ref(dr) AS drivers_ref,
		vehicles_ref(v) AS vehicles_ref,
		production_sites_ref(ps) AS production_sites_ref
	FROM shipments AS t
	LEFT JOIN orders AS o ON o.id=t.order_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id=t.vehicle_schedule_id
	LEFT JOIN vehicles AS v ON v.id=vsch.vehicle_id
	LEFT JOIN drivers AS dr ON dr.id=vsch.driver_id
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	WHERE t.shipped AND (t.ship_date_time BETWEEN now()-const_show_time_for_shipped_vehicles_val() AND now())
	;
	
ALTER VIEW shipped_vehicles_list OWNER TO beton;


-- ******************* update 09/07/2019 16:19:45 ******************
-- VIEW: shipped_vehicles_list

--DROP VIEW shipped_vehicles_list;

CREATE OR REPLACE VIEW shipped_vehicles_list AS
	SELECT
		t.id,
		now()-t.ship_date_time AS elapsed_time,
		destinations_ref(dest) AS destinations_ref,
		drivers_ref(dr) AS drivers_ref,
		vehicles_ref(v) AS vehicles_ref,
		production_sites_ref(ps) AS production_sites_ref
	FROM shipments AS t
	LEFT JOIN orders AS o ON o.id=t.order_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id=t.vehicle_schedule_id
	LEFT JOIN vehicles AS v ON v.id=vsch.vehicle_id
	LEFT JOIN drivers AS dr ON dr.id=vsch.driver_id
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	WHERE t.shipped AND (t.ship_date_time BETWEEN now()-const_show_time_for_shipped_vehicles_val() AND now())
	ORDER BY t.ship_date_time DESC
	;
	
ALTER VIEW shipped_vehicles_list OWNER TO beton;


-- ******************* update 09/07/2019 16:33:35 ******************
-- VIEW: shipped_vehicles_list

--DROP VIEW shipped_vehicles_list;

CREATE OR REPLACE VIEW shipped_vehicles_list AS
	SELECT
		t.id,
		date_trunc('minute', now()-t.ship_date_time) AS elapsed_time,
		destinations_ref(dest) AS destinations_ref,
		drivers_ref(dr) AS drivers_ref,
		vehicles_ref(v) AS vehicles_ref,
		production_sites_ref(ps) AS production_sites_ref
	FROM shipments AS t
	LEFT JOIN orders AS o ON o.id=t.order_id
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id=t.vehicle_schedule_id
	LEFT JOIN vehicles AS v ON v.id=vsch.vehicle_id
	LEFT JOIN drivers AS dr ON dr.id=vsch.driver_id
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	WHERE t.shipped AND (t.ship_date_time BETWEEN now()-const_show_time_for_shipped_vehicles_val() AND now())
	ORDER BY t.ship_date_time DESC
	;
	
ALTER VIEW shipped_vehicles_list OWNER TO beton;


-- ******************* update 10/07/2019 06:20:53 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_tracker_malfunction_tel_list
		(name text, descr text, val json,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_tracker_malfunction_tel_list OWNER TO beton;
		INSERT INTO const_tracker_malfunction_tel_list (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Список телефонов для сообщений о неисправном трекере'
			,'На какие телефоны отправлять сообщение о неработающих трекерах'
			,NULL
			,'JSON'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_tracker_malfunction_tel_list_val()
		RETURNS json AS
		$BODY$
			SELECT val::json AS val FROM const_tracker_malfunction_tel_list LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_tracker_malfunction_tel_list_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_tracker_malfunction_tel_list_set_val(JSON)
		RETURNS void AS
		$BODY$
			UPDATE const_tracker_malfunction_tel_list SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_tracker_malfunction_tel_list_set_val(JSON) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_tracker_malfunction_tel_list_view AS
		SELECT
			'tracker_malfunction_tel_list'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_tracker_malfunction_tel_list AS t
		;
		ALTER VIEW const_tracker_malfunction_tel_list_view OWNER TO beton;
		CREATE OR REPLACE VIEW constants_list_view AS
		SELECT *
		FROM const_doc_per_page_count_view
		UNION ALL
		SELECT *
		FROM const_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_order_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_backup_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_id_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_view
		UNION ALL
		SELECT *
		FROM const_chart_step_min_view
		UNION ALL
		SELECT *
		FROM const_day_shift_length_view
		UNION ALL
		SELECT *
		FROM const_days_allowed_with_broken_tracker_view
		UNION ALL
		SELECT *
		FROM const_def_order_unload_speed_view
		UNION ALL
		SELECT *
		FROM const_demurrage_coast_per_hour_view
		UNION ALL
		SELECT *
		FROM const_first_shift_start_time_view
		UNION ALL
		SELECT *
		FROM const_geo_zone_check_points_count_view
		UNION ALL
		SELECT *
		FROM const_map_default_lat_view
		UNION ALL
		SELECT *
		FROM const_map_default_lon_view
		UNION ALL
		SELECT *
		FROM const_max_hour_load_view
		UNION ALL
		SELECT *
		FROM const_max_vehicle_at_work_view
		UNION ALL
		SELECT *
		FROM const_min_demurrage_time_view
		UNION ALL
		SELECT *
		FROM const_min_quant_for_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_no_tracker_signal_warn_interval_view
		UNION ALL
		SELECT *
		FROM const_ord_mark_if_no_ship_time_view
		UNION ALL
		SELECT *
		FROM const_order_auto_place_tolerance_view
		UNION ALL
		SELECT *
		FROM const_order_step_min_view
		UNION ALL
		SELECT *
		FROM const_own_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_raw_mater_plcons_rep_def_days_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_id_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_view
		UNION ALL
		SELECT *
		FROM const_shift_for_orders_length_time_view
		UNION ALL
		SELECT *
		FROM const_shift_length_time_view
		UNION ALL
		SELECT *
		FROM const_ship_coast_for_self_ship_destination_view
		UNION ALL
		SELECT *
		FROM const_speed_change_for_order_autolocate_view
		UNION ALL
		SELECT *
		FROM const_vehicle_unload_time_view
		UNION ALL
		SELECT *
		FROM const_avg_mat_cons_dev_day_count_view
		UNION ALL
		SELECT *
		FROM const_days_for_plan_procur_view
		UNION ALL
		SELECT *
		FROM const_lab_min_sample_count_view
		UNION ALL
		SELECT *
		FROM const_lab_days_for_avg_view
		UNION ALL
		SELECT *
		FROM const_city_ext_view
		UNION ALL
		SELECT *
		FROM const_def_lang_view
		UNION ALL
		SELECT *
		FROM const_efficiency_warn_k_view
		UNION ALL
		SELECT *
		FROM const_zone_violation_alarm_interval_view
		UNION ALL
		SELECT *
		FROM const_weather_update_interval_sec_view
		UNION ALL
		SELECT *
		FROM const_call_history_count_view
		UNION ALL
		SELECT *
		FROM const_water_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_from_day_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_to_day_view
		UNION ALL
		SELECT *
		FROM const_show_time_for_shipped_vehicles_view
		UNION ALL
		SELECT *
		FROM const_tracker_malfunction_tel_list_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	

-- ******************* update 10/07/2019 06:48:20 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_low_efficiency_tel_list
		(name text, descr text, val json,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_low_efficiency_tel_list OWNER TO beton;
		INSERT INTO const_low_efficiency_tel_list (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Список телефонов для сообщений о низком состоянии эффективности'
			,'На какие телефоны отправлять сообщение о низком состоянии эффективности'
			,NULL
			,'JSON'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_low_efficiency_tel_list_val()
		RETURNS json AS
		$BODY$
			SELECT val::json AS val FROM const_low_efficiency_tel_list LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_low_efficiency_tel_list_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_low_efficiency_tel_list_set_val(JSON)
		RETURNS void AS
		$BODY$
			UPDATE const_low_efficiency_tel_list SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_low_efficiency_tel_list_set_val(JSON) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_low_efficiency_tel_list_view AS
		SELECT
			'low_efficiency_tel_list'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_low_efficiency_tel_list AS t
		;
		ALTER VIEW const_low_efficiency_tel_list_view OWNER TO beton;
		CREATE OR REPLACE VIEW constants_list_view AS
		SELECT *
		FROM const_doc_per_page_count_view
		UNION ALL
		SELECT *
		FROM const_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_order_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_backup_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_id_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_view
		UNION ALL
		SELECT *
		FROM const_chart_step_min_view
		UNION ALL
		SELECT *
		FROM const_day_shift_length_view
		UNION ALL
		SELECT *
		FROM const_days_allowed_with_broken_tracker_view
		UNION ALL
		SELECT *
		FROM const_def_order_unload_speed_view
		UNION ALL
		SELECT *
		FROM const_demurrage_coast_per_hour_view
		UNION ALL
		SELECT *
		FROM const_first_shift_start_time_view
		UNION ALL
		SELECT *
		FROM const_geo_zone_check_points_count_view
		UNION ALL
		SELECT *
		FROM const_map_default_lat_view
		UNION ALL
		SELECT *
		FROM const_map_default_lon_view
		UNION ALL
		SELECT *
		FROM const_max_hour_load_view
		UNION ALL
		SELECT *
		FROM const_max_vehicle_at_work_view
		UNION ALL
		SELECT *
		FROM const_min_demurrage_time_view
		UNION ALL
		SELECT *
		FROM const_min_quant_for_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_no_tracker_signal_warn_interval_view
		UNION ALL
		SELECT *
		FROM const_ord_mark_if_no_ship_time_view
		UNION ALL
		SELECT *
		FROM const_order_auto_place_tolerance_view
		UNION ALL
		SELECT *
		FROM const_order_step_min_view
		UNION ALL
		SELECT *
		FROM const_own_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_raw_mater_plcons_rep_def_days_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_id_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_view
		UNION ALL
		SELECT *
		FROM const_shift_for_orders_length_time_view
		UNION ALL
		SELECT *
		FROM const_shift_length_time_view
		UNION ALL
		SELECT *
		FROM const_ship_coast_for_self_ship_destination_view
		UNION ALL
		SELECT *
		FROM const_speed_change_for_order_autolocate_view
		UNION ALL
		SELECT *
		FROM const_vehicle_unload_time_view
		UNION ALL
		SELECT *
		FROM const_avg_mat_cons_dev_day_count_view
		UNION ALL
		SELECT *
		FROM const_days_for_plan_procur_view
		UNION ALL
		SELECT *
		FROM const_lab_min_sample_count_view
		UNION ALL
		SELECT *
		FROM const_lab_days_for_avg_view
		UNION ALL
		SELECT *
		FROM const_city_ext_view
		UNION ALL
		SELECT *
		FROM const_def_lang_view
		UNION ALL
		SELECT *
		FROM const_efficiency_warn_k_view
		UNION ALL
		SELECT *
		FROM const_zone_violation_alarm_interval_view
		UNION ALL
		SELECT *
		FROM const_weather_update_interval_sec_view
		UNION ALL
		SELECT *
		FROM const_call_history_count_view
		UNION ALL
		SELECT *
		FROM const_water_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_from_day_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_to_day_view
		UNION ALL
		SELECT *
		FROM const_show_time_for_shipped_vehicles_view
		UNION ALL
		SELECT *
		FROM const_tracker_malfunction_tel_list_view
		UNION ALL
		SELECT *
		FROM const_low_efficiency_tel_list_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	

-- ******************* update 10/07/2019 06:51:04 ******************
DELETE FROM const_efficiency_warn_k;
		INSERT INTO const_efficiency_warn_k (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Значение состояния ниже которого отправляется сообщение'
			,''
			,-60
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_efficiency_warn_k_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_efficiency_warn_k LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_efficiency_warn_k_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_efficiency_warn_k_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_efficiency_warn_k SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_efficiency_warn_k_set_val(Int) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_efficiency_warn_k_view AS
		SELECT
			'efficiency_warn_k'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_efficiency_warn_k AS t
		;
		ALTER VIEW const_efficiency_warn_k_view OWNER TO beton;
		CREATE OR REPLACE VIEW constants_list_view AS
		SELECT *
		FROM const_doc_per_page_count_view
		UNION ALL
		SELECT *
		FROM const_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_order_grid_refresh_interval_view
		UNION ALL
		SELECT *
		FROM const_backup_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_id_view
		UNION ALL
		SELECT *
		FROM const_base_geo_zone_view
		UNION ALL
		SELECT *
		FROM const_chart_step_min_view
		UNION ALL
		SELECT *
		FROM const_day_shift_length_view
		UNION ALL
		SELECT *
		FROM const_days_allowed_with_broken_tracker_view
		UNION ALL
		SELECT *
		FROM const_def_order_unload_speed_view
		UNION ALL
		SELECT *
		FROM const_demurrage_coast_per_hour_view
		UNION ALL
		SELECT *
		FROM const_first_shift_start_time_view
		UNION ALL
		SELECT *
		FROM const_geo_zone_check_points_count_view
		UNION ALL
		SELECT *
		FROM const_map_default_lat_view
		UNION ALL
		SELECT *
		FROM const_map_default_lon_view
		UNION ALL
		SELECT *
		FROM const_max_hour_load_view
		UNION ALL
		SELECT *
		FROM const_max_vehicle_at_work_view
		UNION ALL
		SELECT *
		FROM const_min_demurrage_time_view
		UNION ALL
		SELECT *
		FROM const_min_quant_for_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_no_tracker_signal_warn_interval_view
		UNION ALL
		SELECT *
		FROM const_ord_mark_if_no_ship_time_view
		UNION ALL
		SELECT *
		FROM const_order_auto_place_tolerance_view
		UNION ALL
		SELECT *
		FROM const_order_step_min_view
		UNION ALL
		SELECT *
		FROM const_own_vehicles_feature_view
		UNION ALL
		SELECT *
		FROM const_raw_mater_plcons_rep_def_days_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_id_view
		UNION ALL
		SELECT *
		FROM const_self_ship_dest_view
		UNION ALL
		SELECT *
		FROM const_shift_for_orders_length_time_view
		UNION ALL
		SELECT *
		FROM const_shift_length_time_view
		UNION ALL
		SELECT *
		FROM const_ship_coast_for_self_ship_destination_view
		UNION ALL
		SELECT *
		FROM const_speed_change_for_order_autolocate_view
		UNION ALL
		SELECT *
		FROM const_vehicle_unload_time_view
		UNION ALL
		SELECT *
		FROM const_avg_mat_cons_dev_day_count_view
		UNION ALL
		SELECT *
		FROM const_days_for_plan_procur_view
		UNION ALL
		SELECT *
		FROM const_lab_min_sample_count_view
		UNION ALL
		SELECT *
		FROM const_lab_days_for_avg_view
		UNION ALL
		SELECT *
		FROM const_city_ext_view
		UNION ALL
		SELECT *
		FROM const_def_lang_view
		UNION ALL
		SELECT *
		FROM const_efficiency_warn_k_view
		UNION ALL
		SELECT *
		FROM const_zone_violation_alarm_interval_view
		UNION ALL
		SELECT *
		FROM const_weather_update_interval_sec_view
		UNION ALL
		SELECT *
		FROM const_call_history_count_view
		UNION ALL
		SELECT *
		FROM const_water_ship_cost_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_from_day_view
		UNION ALL
		SELECT *
		FROM const_vehicle_owner_accord_to_day_view
		UNION ALL
		SELECT *
		FROM const_show_time_for_shipped_vehicles_view
		UNION ALL
		SELECT *
		FROM const_tracker_malfunction_tel_list_view
		UNION ALL
		SELECT *
		FROM const_low_efficiency_tel_list_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	


-- ******************* update 10/07/2019 14:19:38 ******************
-- Function: ra_material_consumption_dates_list_new(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION ra_material_consumption_dates_list_new(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION ra_material_consumption_dates_list_new(
    in_date_time_from timestamp without time zone,
    in_date_time_to timestamp without time zone)
  RETURNS SETOF record AS
$BODY$
DECLARE
	materials raw_materials%rowtype;
	dyn_cols text;
	dyn_cols_tot text;
	q text;
	dyn_col_cnt int;
BEGIN
	dyn_cols = '';
	dyn_cols_tot='';
	dyn_col_cnt = 0;
	FOR materials IN 
		SELECT id FROM raw_materials WHERE name<>'' ORDER BY id	
	LOOP
		dyn_col_cnt = dyn_col_cnt + 1;
		dyn_cols = dyn_cols||', ';
		dyn_cols = dyn_cols
		|| '(SELECT SUM(consump.material_quant) FROM consump WHERE consump.date_time=consump_d.date_time AND consump.material_id='|| materials.id ||'::int) AS mat'|| dyn_col_cnt ||'_quant';
		dyn_cols_tot = dyn_cols_tot||','|| '(SELECT SUM(consump.material_quant) FROM consump WHERE consump.material_id='|| materials.id ||'::int) AS mat'|| dyn_col_cnt ||'_quant';
	END LOOP;	

	RETURN QUERY EXECUTE 
	--q=
		'WITH consump AS (
			SELECT
				get_shift_start(date_time) AS date_time,
				material_id,
				ROUND(SUM(concrete_quant),2) AS concrete_quant,
				ROUND(SUM(material_quant),3) AS material_quant
			FROM ra_material_consumption
			WHERE date_time BETWEEN '''|| in_date_time_from ||'''::timestamp AND '''|| in_date_time_to ||'''::timestamp
			GROUP BY get_shift_start(date_time),material_id
			ORDER BY date_time)
		(SELECT
			consump_d.date_time AS shift,
			get_shift_end(consump_d.date_time) AS shift_to,
			get_shift_descr(consump_d.date_time)::text AS shift_descr,
			date10_time8_descr(consump_d.date_time)::text AS shift_from_descr,
			date10_time8_descr(get_shift_end(consump_d.date_time))::text AS shift_to_descr,
			(SELECT SUM(concrete_quant) FROM consump WHERE consump.date_time=consump_d.date_time) AS concrete_quant
		'|| dyn_cols ||'
		FROM consump AS consump_d
		GROUP BY shift
		ORDER BY shift)

		';	
	--RAISE '%',q;
	--RETURN QUERY EXECUTE q;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION ra_material_consumption_dates_list_new(timestamp without time zone, timestamp without time zone)
  OWNER TO beton;



-- ******************* update 10/07/2019 16:07:13 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'30013',
		'RawMaterial_Controller',
		'total_list',
		'MatTotalList',
		'Формы',
		'Общая таблица',
		FALSE
		);
	

-- ******************* update 11/07/2019 12:59:30 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'30014',
		'RawMaterial_Controller',
		'correct_list',
		'MatCorrectList',
		'Формы',
		'Корректировка расхода',
		FALSE
		);
	

-- ******************* update 11/07/2019 14:14:17 ******************
-- Function: public.clients_ref(clients)

-- DROP FUNCTION public.clients_ref(clients);

CREATE OR REPLACE FUNCTION public.clients_ref(clients)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name||CASE WHEN $1.inn IS NOT NULL AND length($1.inn)>0 THEN ', '||$1.inn ELSE '' END,
		'dataType','clients'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.clients_ref(clients) OWNER TO beton;


