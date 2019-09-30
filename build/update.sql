
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



-- ******************* update 12/07/2019 13:46:48 ******************
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
		clients_ref(cl) AS clients_ref,
		
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0) AS cost_shipment,
		
		--БЕТОН
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
		
		--ИТОГИ
		coalesce((SELECT
			sum(shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE))
		FROM shipments AS sh
		WHERE sh.order_id=o.id
		),0)
		--БЕТОН 
		+coalesce(
			(SELECT
				pr.price
			FROM vehicle_owner_concrete_prices AS pr_t
			LEFT JOIN concrete_costs_for_owner AS pr ON pr.header_id = pr_t.concrete_costs_for_owner_h_id AND pr.concrete_type_id=o.concrete_type_id
			WHERE pr_t.vehicle_owner_id=vown_cl.vehicle_owner_id AND pr_t.client_id=o.client_id AND pr_t.date<=o.date_time
			ORDER BY pr_t.date DESC
			LIMIT 1)
		,0)*o.quant::numeric
		
		--стоимость чужего насоса, если есть
		+coalesce(
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
			
		END,0)::numeric(15,2)
		
		--простой
		+coalesce(demurrage.cost,0.00)::numeric(15,2)
		
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


-- ******************* update 07/08/2019 12:53:26 ******************
-- Function: sess_write(character varying, text, character varying)

-- DROP FUNCTION sess_write(character varying, text, character varying);

CREATE OR REPLACE FUNCTION sess_enc_write(
    in_id character varying,
    in_data text,
    in_key text,
    in_remote_ip character varying)
  RETURNS void AS
$BODY$
BEGIN
	UPDATE sessions
	SET
		set_time = now(),
		data_enc = PGP_SYM_DECRYPT(in_data_enc,in_key)
	WHERE id = in_id;
	
	IF FOUND THEN
		RETURN;
	END IF;
	
	BEGIN
		INSERT INTO sessions (id, data_enc, set_time,session_key)
		VALUES(in_id, PGP_SYM_DECRYPT(in_data,in_key), now(),in_id);
		
		INSERT INTO logins(date_time_in,ip,session_id)
		VALUES(now(),in_remote_ip,in_id);
		
	EXCEPTION WHEN unique_violation THEN
		UPDATE sessions
		SET
			set_time = now(),
			data_enc = PGP_SYM_DECRYPT(in_data_enc,in_key)
		WHERE id = in_id;
	END;
	
	RETURN;

END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sess_enc_write(character varying, text, text, character varying)
  OWNER TO beton;



-- ******************* update 07/08/2019 12:57:14 ******************
-- Function: sess_enc_write(character varying, text, character varying)

-- DROP FUNCTION sess_enc_write(character varying, text, character varying);

CREATE OR REPLACE FUNCTION sess_enc_write(
    in_id character varying,
    in_data text,
    in_key text,
    in_remote_ip character varying)
  RETURNS void AS
$BODY$
BEGIN
	UPDATE sessions
	SET
		set_time = now(),
		data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
	WHERE id = in_id;
	
	IF FOUND THEN
		RETURN;
	END IF;
	
	BEGIN
		INSERT INTO sessions (id, data_enc, set_time,session_key)
		VALUES(in_id, PGP_SYM_DECRYPT(in_data,in_key), now(),in_id);
		
		INSERT INTO logins(date_time_in,ip,session_id)
		VALUES(now(),in_remote_ip,in_id);
		
	EXCEPTION WHEN unique_violation THEN
		UPDATE sessions
		SET
			set_time = now(),
			data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
		WHERE id = in_id;
	END;
	
	RETURN;

END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sess_enc_write(character varying, text, text, character varying)
  OWNER TO beton;



-- ******************* update 07/08/2019 12:58:16 ******************
-- Function: sess_enc_read(character varying, text)

-- DROP FUNCTION sess_enc_read(character varying, text);

CREATE OR REPLACE FUNCTION sess_enc_read(in_id character varying,in_key text)
  RETURNS text AS
$BODY$
	SELECT PGP_SYM_DECRYPT(data_enc,in_key) FROM sessions WHERE id = in_id;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION sess_enc_read(character varying, text)
  OWNER TO beton;



-- ******************* update 07/08/2019 13:00:12 ******************
-- Function: sess_enc_read(character varying, text)

-- DROP FUNCTION sess_enc_read(character varying, text);

CREATE OR REPLACE FUNCTION sess_enc_read(in_id character varying,in_key text)
  RETURNS text AS
$BODY$
	SELECT PGP_SYM_DECRYPT(data_enc,in_key) FROM sessions WHERE id = in_id LIMIT 1;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION sess_enc_read(character varying, text)
  OWNER TO beton;



-- ******************* update 07/08/2019 13:26:23 ******************
-- Function: sess_enc_write(character varying, text, character varying)

-- DROP FUNCTION sess_enc_write(character varying, text, character varying);

CREATE OR REPLACE FUNCTION sess_enc_write(
    in_id character varying,
    in_data text,
    in_key text,
    in_remote_ip character varying)
  RETURNS void AS
$BODY$
BEGIN
	UPDATE sessions
	SET
		set_time = now(),
		data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
	WHERE id = in_id;
	
	IF FOUND THEN
		RETURN;
	END IF;
	
	BEGIN
		INSERT INTO sessions (id, data_enc, set_time,session_key)
		VALUES(in_id, PGP_SYM_DECRYPT(in_data,in_key), now(),in_id);
		
		INSERT INTO logins(date_time_in,ip,session_id)
		VALUES(now(),in_remote_ip,in_id);
		
	EXCEPTION WHEN unique_violation THEN
		UPDATE sessions
		SET
			set_time = now(),
			data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
		WHERE id = in_id;
	END;
	
	RETURN;

END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sess_enc_write(character varying, text, text, character varying)
  OWNER TO beton;



-- ******************* update 07/08/2019 13:27:48 ******************
-- Function: sess_enc_write(character varying, text, character varying)

 DROP FUNCTION sess_enc_write(character varying, text,text, character varying);

CREATE OR REPLACE FUNCTION sess_enc_write(
    in_id character varying,
    in_data_enc text,
    in_key text,
    in_remote_ip character varying)
  RETURNS void AS
$BODY$
BEGIN
	UPDATE sessions
	SET
		set_time = now(),
		data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
	WHERE id = in_id;
	
	IF FOUND THEN
		RETURN;
	END IF;
	
	BEGIN
		INSERT INTO sessions (id, data_enc, set_time,session_key)
		VALUES(in_id, PGP_SYM_DECRYPT(in_data,in_key), now(),in_id);
		
		INSERT INTO logins(date_time_in,ip,session_id)
		VALUES(now(),in_remote_ip,in_id);
		
	EXCEPTION WHEN unique_violation THEN
		UPDATE sessions
		SET
			set_time = now(),
			data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
		WHERE id = in_id;
	END;
	
	RETURN;

END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sess_enc_write(character varying, text, text, character varying)
  OWNER TO beton;



-- ******************* update 07/08/2019 13:40:55 ******************
-- Function: sess_enc_write(character varying, text, character varying)

-- DROP FUNCTION sess_enc_write(character varying, text,text, character varying);

CREATE OR REPLACE FUNCTION sess_enc_write(
    in_id character varying,
    in_data_enc text,
    in_key text,
    in_remote_ip character varying)
  RETURNS void AS
$BODY$
BEGIN
	UPDATE sessions
	SET
		set_time = now(),
		data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
	WHERE id = in_id;
	
	IF FOUND THEN
		RETURN;
	END IF;
	
	BEGIN
		INSERT INTO sessions (id, data_enc, set_time,session_key)
		VALUES(in_id, PGP_SYM_ENCRYPT(in_data_enc,in_key), now(),in_id);
		
		INSERT INTO logins(date_time_in,ip,session_id)
		VALUES(now(),in_remote_ip,in_id);
		
	EXCEPTION WHEN unique_violation THEN
		UPDATE sessions
		SET
			set_time = now(),
			data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
		WHERE id = in_id;
	END;
	
	RETURN;

END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sess_enc_write(character varying, text, text, character varying)
  OWNER TO beton;



-- ******************* update 08/08/2019 16:13:30 ******************
-- Function: sess_enc_write(character varying, text, character varying)

-- DROP FUNCTION sess_enc_write(character varying, text,text, character varying);

CREATE OR REPLACE FUNCTION sess_enc_write(
    in_id character varying,
    in_data_enc text,
    in_key text,
    in_remote_ip character varying)
  RETURNS void AS
$BODY$
BEGIN
	UPDATE sessions
	SET
		set_time = now(),
		data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
	WHERE id = in_id;
	
	IF FOUND THEN
		RETURN;
	END IF;
	
	BEGIN
		INSERT INTO sessions (id, data_enc, set_time)
		VALUES(in_id, PGP_SYM_ENCRYPT(in_data_enc,in_key), now());
		
		INSERT INTO logins(date_time_in,ip,session_id)
		VALUES(now(),in_remote_ip,in_id);
		
	EXCEPTION WHEN unique_violation THEN
		UPDATE sessions
		SET
			set_time = now(),
			data_enc = PGP_SYM_ENCRYPT(in_data_enc,in_key)
		WHERE id = in_id;
	END;
	
	RETURN;

END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sess_enc_write(character varying, text, text, character varying)
  OWNER TO beton;



-- ******************* update 22/08/2019 14:50:13 ******************


-- ******************* update 22/08/2019 14:51:33 ******************


-- ******************* update 22/08/2019 14:52:28 ******************
-- Function: public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)

-- DROP FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval);

CREATE OR REPLACE FUNCTION public.vehicle_track_with_stops(
    IN in_vehicle_id integer,
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone,
    IN stop_dur_interval interval)
  RETURNS TABLE(vehicle_id integer, plate text, period timestamp without time zone, period_str text, lon_str text, lat_str text, speed numeric, ns character, ew character, recieved_dt timestamp without time zone, recieved_dt_str text, odometer integer, engine_on_str text, voltage numeric, heading numeric, heading_str text, lon double precision, lat double precision) AS
$BODY$
DECLARE tr_stops_row RECORD;
	tr_stops_curs refcursor;
	v_stop_started boolean;
	v_date_time_from timestamp without time zone;
	v_date_time_to timestamp without time zone;
BEGIN
	v_date_time_from = in_date_time_from + age(now(),now() at time zone 'UTC');
	v_date_time_to = in_date_time_to + age(now(),now() at time zone 'UTC');
	
	OPEN tr_stops_curs SCROLL FOR
		SELECT 
			vehicles.id AS vehicle_id,
			vehicles.plate::text AS plate,
			tr.period+age(now(),now() at time zone 'UTC') AS period,
			date5_time5_descr(tr.period+age(now(),now() at time zone 'UTC'))::text AS period_str,
			tr.longitude::text As lon_str,
			tr.latitude::text AS lat_str,
			round(tr.speed,0)::numeric AS speed,
			tr.ns,
			tr.ew,
			tr.recieved_dt+age(now(),now() at time zone 'UTC') AS recieved_dt,
			date5_time5_descr(tr.recieved_dt+age(now(),now() at time zone 'UTC'))::text AS recieved_dt_str,
			tr.odometer,
			engine_descr(tr.engine_on)::text AS engine_on_str,
			tr.voltage,
			tr.heading,
			heading_descr(tr.heading)::text AS heading_str,
			tr.lon,
			tr.lat
		FROM car_tracking AS tr
		LEFT JOIN vehicles ON vehicles.tracker_id=tr.car_id
		--WHERE tr.period+age(now(),now() at time zone 'UTC') BETWEEN in_date_time_from AND in_date_time_to
		WHERE tr.period BETWEEN v_date_time_from AND v_date_time_to
		AND vehicles.id=in_vehicle_id
		AND tr.gps_valid=1;

	v_stop_started = false;
	LOOP
		FETCH NEXT FROM tr_stops_curs INTO tr_stops_row;
		IF  FOUND=false THEN
			--no more rows
			EXIT;
		END IF;

		IF NOT v_stop_started AND tr_stops_row.speed>0 THEN
			--move point
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
			RETURN NEXT;
		ELSIF NOT v_stop_started AND tr_stops_row.speed=0 THEN	
			--new stop - check duration
			v_stop_started = true;
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
		ELSIF v_stop_started AND tr_stops_row.speed>0 THEN	
			--end of stop
			v_stop_started = false;
			
			IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
				RETURN NEXT;
			END IF;
		END IF;
	END LOOP;

	IF v_stop_started THEN	
		--end of stop or end of period
		IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
			RETURN NEXT;
		END IF;
	END IF;

	CLOSE tr_stops_curs;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)
  OWNER TO beton;



-- ******************* update 22/08/2019 14:53:10 ******************
-- Function: public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)

-- DROP FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval);

CREATE OR REPLACE FUNCTION public.vehicle_track_with_stops(
    IN in_vehicle_id integer,
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone,
    IN stop_dur_interval interval)
  RETURNS TABLE(vehicle_id integer, plate text, period timestamp without time zone, period_str text, lon_str text, lat_str text, speed numeric, ns character, ew character, recieved_dt timestamp without time zone, recieved_dt_str text, odometer integer, engine_on_str text, voltage numeric, heading numeric, heading_str text, lon double precision, lat double precision) AS
$BODY$
DECLARE tr_stops_row RECORD;
	tr_stops_curs refcursor;
	v_stop_started boolean;
	v_date_time_from timestamp without time zone;
	v_date_time_to timestamp without time zone;
BEGIN
	v_date_time_from = in_date_time_from + age(now(),now() at time zone 'UTC');
	v_date_time_to = in_date_time_to + age(now(),now() at time zone 'UTC');
	
	OPEN tr_stops_curs SCROLL FOR
		SELECT 
			vehicles.id AS vehicle_id,
			vehicles.plate::text AS plate,
			tr.period+age(now(),now() at time zone 'UTC') AS period,
			date5_time5_descr(tr.period+age(now(),now() at time zone 'UTC'))::text AS period_str,
			tr.longitude::text As lon_str,
			tr.latitude::text AS lat_str,
			round(tr.speed,0)::numeric AS speed,
			tr.ns,
			tr.ew,
			tr.recieved_dt+age(now(),now() at time zone 'UTC') AS recieved_dt,
			date5_time5_descr(tr.recieved_dt+age(now(),now() at time zone 'UTC'))::text AS recieved_dt_str,
			tr.odometer,
			engine_descr(tr.engine_on)::text AS engine_on_str,
			tr.voltage,
			tr.heading,
			heading_descr(tr.heading)::text AS heading_str,
			tr.lon,
			tr.lat
		FROM car_tracking AS tr
		LEFT JOIN vehicles ON vehicles.tracker_id=tr.car_id
		--WHERE tr.period+age(now(),now() at time zone 'UTC') BETWEEN in_date_time_from AND in_date_time_to
		WHERE tr.period BETWEEN v_date_time_from AND v_date_time_to
		AND vehicles.id=in_vehicle_id
		AND tr.gps_valid=1;

	v_stop_started = false;
	LOOP
		FETCH NEXT FROM tr_stops_curs INTO tr_stops_row;
		IF  FOUND=false THEN
			--no more rows
			EXIT;
		END IF;

		IF NOT v_stop_started AND tr_stops_row.speed>0 THEN
			--move point
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
			RETURN NEXT;
		ELSIF NOT v_stop_started AND tr_stops_row.speed=0 THEN	
			--new stop - check duration
			v_stop_started = true;
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
		ELSIF v_stop_started AND tr_stops_row.speed>0 THEN	
			--end of stop
			v_stop_started = false;
			
			IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
				RETURN NEXT;
			END IF;
		END IF;
	END LOOP;

	IF v_stop_started THEN	
		--end of stop or end of period
		IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
			RETURN NEXT;
		END IF;
	END IF;

	CLOSE tr_stops_curs;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)
  OWNER TO beton;



-- ******************* update 22/08/2019 14:53:41 ******************
-- Function: public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)

-- DROP FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval);

CREATE OR REPLACE FUNCTION public.vehicle_track_with_stops(
    IN in_vehicle_id integer,
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone,
    IN stop_dur_interval interval)
  RETURNS TABLE(vehicle_id integer, plate text, period timestamp without time zone, period_str text, lon_str text, lat_str text, speed numeric, ns character, ew character, recieved_dt timestamp without time zone, recieved_dt_str text, odometer integer, engine_on_str text, voltage numeric, heading numeric, heading_str text, lon double precision, lat double precision) AS
$BODY$
DECLARE tr_stops_row RECORD;
	tr_stops_curs refcursor;
	v_stop_started boolean;
	v_date_time_from timestamp without time zone;
	v_date_time_to timestamp without time zone;
BEGIN
	v_date_time_from = in_date_time_from + age(now(),now() at time zone 'UTC');
	v_date_time_to = in_date_time_to + age(now(),now() at time zone 'UTC');
	
	OPEN tr_stops_curs SCROLL FOR
		SELECT 
			vehicles.id AS vehicle_id,
			vehicles.plate::text AS plate,
			tr.period+age(now(),now() at time zone 'UTC') AS period,
			date5_time5_descr(tr.period+age(now(),now() at time zone 'UTC'))::text AS period_str,
			tr.longitude::text As lon_str,
			tr.latitude::text AS lat_str,
			round(tr.speed,0)::numeric AS speed,
			tr.ns,
			tr.ew,
			tr.recieved_dt+age(now(),now() at time zone 'UTC') AS recieved_dt,
			date5_time5_descr(tr.recieved_dt+age(now(),now() at time zone 'UTC'))::text AS recieved_dt_str,
			tr.odometer,
			engine_descr(tr.engine_on)::text AS engine_on_str,
			tr.voltage,
			tr.heading,
			heading_descr(tr.heading)::text AS heading_str,
			tr.lon,
			tr.lat
		FROM car_tracking AS tr
		LEFT JOIN vehicles ON vehicles.tracker_id=tr.car_id
		--WHERE tr.period+age(now(),now() at time zone 'UTC') BETWEEN in_date_time_from AND in_date_time_to
		WHERE tr.period BETWEEN v_date_time_from AND v_date_time_to
		AND vehicles.id=in_vehicle_id
		AND tr.gps_valid=1;

	v_stop_started = false;
	LOOP
		FETCH NEXT FROM tr_stops_curs INTO tr_stops_row;
		IF  FOUND=false THEN
			--no more rows
			EXIT;
		END IF;

		IF NOT v_stop_started AND tr_stops_row.speed>0 THEN
			--move point
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
			RETURN NEXT;
		ELSIF NOT v_stop_started AND tr_stops_row.speed=0 THEN	
			--new stop - check duration
			v_stop_started = true;
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
		ELSIF v_stop_started AND tr_stops_row.speed>0 THEN	
			--end of stop
			v_stop_started = false;
			
			IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
				RETURN NEXT;
			END IF;
		END IF;
	END LOOP;

	IF v_stop_started THEN	
		--end of stop or end of period
		IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
			RETURN NEXT;
		END IF;
	END IF;

	CLOSE tr_stops_curs;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)
  OWNER TO beton;



-- ******************* update 22/08/2019 14:58:05 ******************
-- Function: public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)

-- DROP FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval);

CREATE OR REPLACE FUNCTION public.vehicle_track_with_stops(
    IN in_vehicle_id integer,
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone,
    IN stop_dur_interval interval)
  RETURNS TABLE(vehicle_id integer, plate text, period timestamp without time zone, period_str text, lon_str text, lat_str text, speed numeric, ns character, ew character, recieved_dt timestamp without time zone, recieved_dt_str text, odometer integer, engine_on_str text, voltage numeric, heading numeric, heading_str text, lon double precision, lat double precision) AS
$BODY$
DECLARE tr_stops_row RECORD;
	tr_stops_curs refcursor;
	v_stop_started boolean;
	v_date_time_from timestamp without time zone;
	v_date_time_to timestamp without time zone;
BEGIN
	v_date_time_from = in_date_time_from + age(now(),now() at time zone 'UTC');
	v_date_time_to = in_date_time_to + age(now(),now() at time zone 'UTC');
	
	OPEN tr_stops_curs SCROLL FOR
		SELECT 
			vehicles.id AS vehicle_id,
			vehicles.plate::text AS plate,
			tr.period+age(now(),now() at time zone 'UTC') AS period,
			date5_time5_descr(tr.period+age(now(),now() at time zone 'UTC'))::text AS period_str,
			tr.longitude::text As lon_str,
			tr.latitude::text AS lat_str,
			round(tr.speed,0)::numeric AS speed,
			tr.ns,
			tr.ew,
			tr.recieved_dt+age(now(),now() at time zone 'UTC') AS recieved_dt,
			date5_time5_descr(tr.recieved_dt+age(now(),now() at time zone 'UTC'))::text AS recieved_dt_str,
			tr.odometer,
			engine_descr(tr.engine_on)::text AS engine_on_str,
			tr.voltage,
			tr.heading,
			heading_descr(tr.heading)::text AS heading_str,
			tr.lon,
			tr.lat
		FROM car_tracking AS tr
		LEFT JOIN vehicles ON vehicles.tracker_id=tr.car_id
		--WHERE tr.period+age(now(),now() at time zone 'UTC') BETWEEN in_date_time_from AND in_date_time_to
		WHERE tr.period BETWEEN v_date_time_from AND v_date_time_to
		AND vehicles.id=in_vehicle_id
		AND tr.gps_valid=1;

	v_stop_started = false;
	LOOP
		FETCH NEXT FROM tr_stops_curs INTO tr_stops_row;
		IF  FOUND=false THEN
			--no more rows
			EXIT;
		END IF;

		IF NOT v_stop_started AND tr_stops_row.speed>0 THEN
			--move point
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
			RETURN NEXT;
		ELSIF NOT v_stop_started AND tr_stops_row.speed=0 THEN	
			--new stop - check duration
			v_stop_started = true;
			vehicle_id	= tr_stops_row.vehicle_id;
			plate		= tr_stops_row.plate;
			period		= tr_stops_row.period;
			period_str 	= tr_stops_row.period_str;
			lon_str		= tr_stops_row.lon_str;
			lat_str		= tr_stops_row.lat_str;
			speed		= tr_stops_row.speed;
			ns		= tr_stops_row.ns;
			ew 		= tr_stops_row.ew;
			recieved_dt	= tr_stops_row.recieved_dt;
			recieved_dt_str = tr_stops_row.recieved_dt_str;
			odometer	= tr_stops_row.odometer;
			engine_on_str	= tr_stops_row.engine_on_str;
			voltage		= tr_stops_row.voltage;
			heading		= tr_stops_row.heading;
			heading_str	= tr_stops_row.heading_str;
			lon		= tr_stops_row.lon;
			lat		= tr_stops_row.lat;
		ELSIF v_stop_started AND tr_stops_row.speed>0 THEN	
			--end of stop
			v_stop_started = false;
			
			IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
				RETURN NEXT;
			END IF;
		END IF;
	END LOOP;

	IF v_stop_started THEN	
		--end of stop or end of period
		IF (tr_stops_row.period - period)::interval>=stop_dur_interval THEN
			RETURN NEXT;
		END IF;
	END IF;

	CLOSE tr_stops_curs;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.vehicle_track_with_stops(integer, timestamp without time zone, timestamp without time zone, interval)
  OWNER TO beton;



-- ******************* update 16/09/2019 16:29:58 ******************
-- Function: public.shipment_process()

-- DROP FUNCTION public.shipment_process();

CREATE OR REPLACE FUNCTION public.shipment_process()
  RETURNS trigger AS
$BODY$
DECLARE quant_rest numeric;
	v_vehicle_load_capacity vehicles.load_capacity%TYPE DEFAULT 0;
	v_vehicle_state vehicle_states;
	v_vehicle_plate vehicles.plate%TYPE;
	v_vehicle_feature vehicles.feature%TYPE;
	v_ord_date_time timestamp;
	v_destination_id int;
	--v_shift_open boolean;
BEGIN
	/*
	IF (TG_OP='UPDATE' AND NEW.shipped AND OLD.shipped) THEN
		--closed shipment, but trying to change smth
		RAISE EXCEPTION 'Для возможности изменения отмените отгрузку!';
	END IF;
	*/

	IF (TG_WHEN='BEFORE' AND TG_OP='UPDATE' AND OLD.shipped=true) THEN
		--register actions
		PERFORM ra_materials_remove_acts('shipment'::doc_types,NEW.id);
		PERFORM ra_material_consumption_remove_acts('shipment'::doc_types,NEW.id);
	END IF;
	
	IF (TG_WHEN='BEFORE' AND TG_OP='UPDATE'
	AND (OLD.vehicle_schedule_id<>NEW.vehicle_schedule_id OR OLD.id<>NEW.id)
	)
	THEN
		--
		DELETE FROM vehicle_schedule_states t WHERE t.shipment_id = OLD.id AND t.schedule_id = OLD.vehicle_schedule_id;	
	END IF;
	
	-- vehicle data
	IF (TG_OP='INSERT' OR (TG_OP='UPDATE' AND NEW.shipped=false AND OLD.shipped=false)) THEN
		SELECT v.load_capacity,v.plate,v.feature INTO v_vehicle_load_capacity, v_vehicle_plate,v_vehicle_feature
		FROM vehicle_schedules AS vs
		LEFT JOIN vehicles As v ON v.id=vs.vehicle_id
		WHERE vs.id=NEW.vehicle_schedule_id;	

		IF (v_vehicle_feature IS NULL)
		OR (
			(v_vehicle_feature<>const_own_vehicles_feature_val())
			AND (v_vehicle_feature<>const_backup_vehicles_feature_val()) 
		) THEN
			--check destination. const_self_ship_dest_id_val only allowed!!!
			SELECT orders.destination_id INTO v_destination_id FROM orders WHERE orders.id=NEW.order_id;
			IF v_destination_id <> const_self_ship_dest_id_val() THEN
				RAISE EXCEPTION 'Данному автомобилю запрещено вывозить на этот объект!';
			END IF;
		END IF;
	END IF;

	--check vehicle state && open shift
	IF (TG_OP='INSERT') THEN
		/*
		SELECT true INTO v_shift_open FROM shifts WHERE shifts.date = NEW.date_time::date;
		IF NOT FOUND THEN
			RAISE EXCEPTION 'Смена "%" не открыта!',get_shift_descr(NEW.date_time);
		END IF;
		*/
		
		SELECT vehicle_schedule_states.state INTO v_vehicle_state
		FROM vehicle_schedule_states
		WHERE schedule_id=NEW.vehicle_schedule_id
		ORDER BY date_time DESC NULLS LAST
		LIMIT 1;
		
		/*IF v_vehicle_state != 'free'::vehicle_states THEN
			RAISE EXCEPTION 'Автомобиль "%" в статусе "%", должен быть 
				"%"',v_vehicle_plate,get_vehicle_states_descr(v_vehicle_state),get_vehicle_states_descr('free'::vehicle_states);
		END IF;
		*/
	END IF;

	IF (TG_OP='INSERT' OR (TG_OP='UPDATE' AND NEW.shipped=false AND OLD.shipped=false)) THEN
		-- ********** check balance ****************************************
		SELECT o.quant-SUM(COALESCE(s.quant,0)),o.date_time INTO quant_rest,v_ord_date_time FROM orders AS o
		LEFT JOIN shipments AS s ON s.order_id=o.id	
		WHERE o.id = NEW.order_id
		GROUP BY o.quant,o.date_time;

		--order shift date MUST overlap shipment shift date!		
		IF get_shift_start(NEW.date_time)<>get_shift_start(v_ord_date_time) THEN
			RAISE EXCEPTION 'Заявка из другой смены!';
		END IF;
		

		IF (TG_OP='UPDATE') THEN
			quant_rest:= quant_rest + OLD.quant;
		END IF;
		
		IF (quant_rest<NEW.quant::numeric) THEN
			RAISE EXCEPTION 'Остаток по данной заявке: %, запрошено: %',quant_descr(quant_rest::numeric),quant_descr(NEW.quant::numeric);
		END IF;
		-- ********** check balance ****************************************

		
		-- *********  check load capacity *************************************		
		IF v_vehicle_load_capacity < NEW.quant THEN
			RAISE EXCEPTION 'Грузоподъемность автомобиля: "%", запрошено: %',quant_descr(v_vehicle_load_capacity::numeric),quant_descr(NEW.quant::numeric);
		END IF;
		-- *********  check load capacity *************************************
	END IF;

	IF TG_OP='UPDATE' THEN
		IF (NEW.shipped AND OLD.shipped=false) THEN
			NEW.ship_date_time = current_timestamp;
		ELSEIF (OLD.shipped AND NEW.shipped=false) THEN
			NEW.ship_date_time = null;
		END IF;
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.shipment_process()
  OWNER TO beton;



-- ******************* update 16/09/2019 16:37:25 ******************

		ALTER TABLE pump_vehicles ADD COLUMN phone_cels jsonb;



-- ******************* update 16/09/2019 16:41:29 ******************
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
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		pv.comment_text,
		
		v.vehicle_owner_id,
		
		pv.phone_cels
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_list
  OWNER TO beton;



-- ******************* update 16/09/2019 16:41:52 ******************
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
		v.vehicle_owner_id AS pump_vehicle_owner_id,
		
		pv.phone_cels
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	WHERE coalesce(pv.deleted,FALSE)=FALSE	
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_work_list
  OWNER TO beton;



-- ******************* update 23/09/2019 12:36:20 ******************
--DROP FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)
RETURNS void as $$
BEGIN
    UPDATE material_fact_consumptions
    SET
    	upload_date_time = now(),
    	upload_user_id = $2,
    	concrete_quant = $1.concrete_quant,
    	material_quant = $1.material_quant,
    	material_quant_req = $1.material_quant_req
    	
    WHERE production_site_id = $1.production_site_id
    	AND date_time = $1.date_time
    	AND concrete_type_production_descr = $1.concrete_type_production_descr
    	AND raw_material_production_descr = $1.raw_material_production_descr
    	AND vehicle_production_descr = $1.vehicle_production_descr
    	;
    
    IF FOUND THEN
        RETURN;
    END IF;
    
    BEGIN
        INSERT INTO material_fact_consumptions (
        	production_site_id,
        	upload_date_time,
        	upload_user_id,
        	date_time,
        	concrete_type_production_descr,
        	raw_material_production_descr,
        	vehicle_production_descr,
        	concrete_quant,
        	material_quant,
        	material_quant_req
       	)
        VALUES (
        	$1.production_site_id,
        	now(),
        	$2,
        	$1.date_time,
        	$1.concrete_type_production_descr,
        	$1.raw_material_production_descr,
        	$1.vehicle_production_descr,
        	$1.concrete_quant,
        	$1.material_quant,
        	$1.material_quant_req
        );
    EXCEPTION WHEN OTHERS THEN
	    UPDATE material_fact_consumptions
	    SET
	    	upload_date_time = now(),
	    	upload_user_id = $2,
	    	concrete_quant = $1.concrete_quant,
	    	material_quant = $1.material_quant,
	    	material_quant_req = $1.material_quant_req
	    	
	    WHERE production_site_id = $1.production_site_id
	    	AND date_time = $1.date_time
	    	AND concrete_type_production_descr = $1.concrete_type_production_descr
	    	AND raw_material_production_descr = $1.raw_material_production_descr
	    	AND vehicle_production_descr = $1.vehicle_production_descr
	    	;
    END;
    RETURN;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add(material_fact_consumptions,int) OWNER TO beton;


-- ******************* update 24/09/2019 10:33:14 ******************
--DROP FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)
RETURNS void as $$
BEGIN
    UPDATE material_fact_consumptions
    SET
    	upload_date_time = now(),
    	upload_user_id = $2,
    	concrete_quant = $1.concrete_quant,
    	material_quant = $1.material_quant,
    	material_quant_req = $1.material_quant_req
    	
    WHERE production_site_id = $1.production_site_id
    	AND date_time = $1.date_time
    	AND concrete_type_production_descr = $1.concrete_type_production_descr
    	AND raw_material_production_descr = $1.raw_material_production_descr
    	AND vehicle_production_descr = $1.vehicle_production_descr
    	;
    
    IF FOUND THEN
        RETURN;
    END IF;
    
    BEGIN
        INSERT INTO material_fact_consumptions (
        	production_site_id,
        	upload_date_time,
        	upload_user_id,
        	date_time,
        	concrete_type_production_descr,
        	raw_material_production_descr,
        	vehicle_production_descr,
        	concrete_quant,
        	material_quant,
        	material_quant_req
       	)
        VALUES (
        	$1.production_site_id,
        	now(),
        	$2,
        	$1.date_time,
        	$1.concrete_type_production_descr,
        	$1.raw_material_production_descr,
        	$1.vehicle_production_descr,
        	$1.concrete_quant,
        	$1.material_quant,
        	$1.material_quant_req
        );
    EXCEPTION WHEN OTHERS THEN
	    UPDATE material_fact_consumptions
	    SET
	    	upload_date_time = now(),
	    	upload_user_id = $2,
	    	concrete_quant = $1.concrete_quant,
	    	material_quant = $1.material_quant,
	    	material_quant_req = $1.material_quant_req
	    	
	    WHERE production_site_id = $1.production_site_id
	    	AND date_time = $1.date_time
	    	AND concrete_type_production_descr = $1.concrete_type_production_descr
	    	AND raw_material_production_descr = $1.raw_material_production_descr
	    	AND vehicle_production_descr = $1.vehicle_production_descr
	    	;
    END;
    RETURN;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add(material_fact_consumptions,int) OWNER TO beton;


-- ******************* update 24/09/2019 10:48:20 ******************
-- VIEW: concrete_type_map_to_production_list

--DROP VIEW concrete_type_map_to_production_list;

CREATE OR REPLACE VIEW concrete_type_map_to_production_list AS
	SELECT
		t.id,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.production_descr
	FROM concrete_type_map_to_production AS t
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	;
	
ALTER VIEW concrete_type_map_to_production_list OWNER TO beton;


-- ******************* update 24/09/2019 10:53:19 ******************
-- VIEW: raw_material_map_to_production_list

--DROP VIEW raw_material_map_to_production_list;

CREATE OR REPLACE VIEW raw_material_map_to_production_list AS
	SELECT
		t.id,
		t.date_time,
		materials_ref(mat) AS raw_materials_ref,
		t.production_descr
	FROM raw_material_map_to_production AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	;
	
ALTER VIEW raw_material_map_to_production_list OWNER TO beton;


-- ******************* update 24/09/2019 10:54:26 ******************
-- VIEW: vehicle_map_to_production_list

--DROP VIEW vehicle_map_to_production_list;

CREATE OR REPLACE VIEW vehicle_map_to_production_list AS
	SELECT
		t.id,
		vehicles_ref(vh) AS vehicles_ref,
		t.production_descr
	FROM vehicle_map_to_production AS t
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	;
	
ALTER VIEW vehicle_map_to_production_list OWNER TO beton;


-- ******************* update 24/09/2019 11:00:00 ******************
-- VIEW: raw_material_map_to_production_list

--DROP VIEW raw_material_map_to_production_list;

CREATE OR REPLACE VIEW raw_material_map_to_production_list AS
	SELECT
		t.id,
		t.date_time,
		materials_ref(mat) AS raw_materials_ref,
		t.production_descr
	FROM raw_material_map_to_production AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	ORDER BY mat.name,t.date_time DESC
	;
	
ALTER VIEW raw_material_map_to_production_list OWNER TO beton;


-- ******************* update 24/09/2019 11:08:01 ******************
-- VIEW: vehicle_map_to_production_list

--DROP VIEW vehicle_map_to_production_list;

CREATE OR REPLACE VIEW vehicle_map_to_production_list AS
	SELECT
		t.id,
		vehicles_ref(vh) AS vehicles_ref,
		t.production_descr
	FROM vehicle_map_to_production AS t
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	ORDER BY vh.plate
	;
	
ALTER VIEW vehicle_map_to_production_list OWNER TO beton;


-- ******************* update 24/09/2019 11:08:35 ******************
-- VIEW: concrete_type_map_to_production_list

--DROP VIEW concrete_type_map_to_production_list;

CREATE OR REPLACE VIEW concrete_type_map_to_production_list AS
	SELECT
		t.id,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.production_descr
	FROM concrete_type_map_to_production AS t
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	ORDER BY ct.name
	;
	
ALTER VIEW concrete_type_map_to_production_list OWNER TO beton;


-- ******************* update 24/09/2019 11:09:30 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10032',
		'RawMaterialMapToProduction_Controller',
		'get_list',
		'RawMaterialMapToProductionList',
		'Справочники',
		'Соответствие материалов в производстве и в бетоне',
		FALSE
		);
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10033',
		'VahicleMapToProduction_Controller',
		'get_list',
		'VahicleMapToProductionList',
		'Справочники',
		'Соответствие ТС в производстве и в бетоне',
		FALSE
		);
		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10034',
		'ConcreteTypeMapToProduction_Controller',
		'get_list',
		'ConcreteTypeMapToProductionList',
		'Справочники',
		'Соответствие марок в производстве и в бетоне',
		FALSE
		);
	

-- ******************* update 24/09/2019 13:34:55 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'30015',
		NULL,
		NULL,
		'MaterialFactConsumptionUpload',
		'Формы',
		'Загрузка данных с завода',
		FALSE
		);
	

-- ******************* update 25/09/2019 09:36:57 ******************
-- VIEW: material_fact_consumptions_list

--DROP VIEW material_fact_consumptions_list;

CREATE OR REPLACE VIEW material_fact_consumptions_list AS
	SELECT
		t.id,
		t.date_time,
		t.upload_date_time,
		users_ref(u) AS upload_users_ref,
		production_sites_ref(pr) AS production_sites_ref,
		materials_ref(mat) AS raw_materials_ref,
		vehicles_ref(vh) AS vehicles_ref,
		t.concrete_quant,
		t.material_quant,
		t.material_quant_req
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	ORDER BY pr.name,t.date_time,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO beton;


-- ******************* update 25/09/2019 09:37:23 ******************
-- VIEW: raw_material_map_to_production_list

--DROP VIEW raw_material_map_to_production_list;

CREATE OR REPLACE VIEW raw_material_map_to_production_list AS
	SELECT
		t.id,
		t.date_time,
		materials_ref(mat) AS raw_materials_ref,
		t.production_descr
	FROM raw_material_map_to_production AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	ORDER BY mat.name,t.date_time DESC
	;
	
ALTER VIEW raw_material_map_to_production_list OWNER TO beton;


-- ******************* update 25/09/2019 12:44:02 ******************
--DROP FUNCTION material_fact_consumptions_add_material(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_material(text)
RETURNS int as $$
DECLARE
	v_raw_material_id int;
BEGIN
	v_raw_material_id = NULL;
	SELECT raw_material_id INTO v_raw_material_id FROM raw_material_map_to_production WHERE production_descr = $1;
	IF v_raw_material_id IS NULL THEN
		INSERT INTO raw_material_map_to_production
		(date_time,production_descr)
		VALUES
		(now(),$1)
		;
	END IF;
	
	RETURN v_raw_material_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_material(text) OWNER TO beton;


-- ******************* update 25/09/2019 12:45:46 ******************
--DROP FUNCTION material_fact_consumptions_add_vehicle(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_vehicle(text)
RETURNS int as $$
DECLARE
	v_vehicle_id int;
BEGIN
	v_vehicle_id = NULL;
	SELECT vehicle_id INTO v_vehicle_id FROM vehicle_map_to_production WHERE production_descr = $1;
	IF v_vehicle_id IS NULL THEN
		INSERT INTO vehicle_map_to_production
		(production_descr)
		VALUES
		($1)
		;
	END IF;
	
	RETURN v_vehicle_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_vehicle(text) OWNER TO beton;


-- ******************* update 25/09/2019 12:46:37 ******************
--DROP FUNCTION material_fact_consumptions_add_concrete_type(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_concrete_type(text)
RETURNS int as $$
DECLARE
	v_concrete_type_id int;
BEGIN
	v_concrete_type_id = NULL;
	SELECT concrete_type_id INTO v_concrete_type_id FROM concrete_type_map_to_production WHERE production_descr = $1;
	IF v_concrete_type_id IS NULL THEN
		INSERT INTO concrete_type_map_to_production
		(production_descr)
		VALUES
		($1)
		;
	END IF;
	
	RETURN v_concrete_type_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_concrete_type(text) OWNER TO beton;


-- ******************* update 25/09/2019 13:05:37 ******************
--DROP FUNCTION material_fact_consumptions_add_material(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_material(text)
RETURNS int as $$
DECLARE
	v_raw_material_id int;
BEGIN
	v_raw_material_id = NULL;
	SELECT raw_material_id INTO v_raw_material_id FROM raw_material_map_to_production WHERE production_descr = $1;
	RAISE EXCEPTION 'Found=%',FOUND;
	IF v_raw_material_id IS NULL THEN
		INSERT INTO raw_material_map_to_production
		(date_time,production_descr)
		VALUES
		(now(),$1)
		;
	END IF;
	
	RETURN v_raw_material_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_material(text) OWNER TO beton;


-- ******************* update 25/09/2019 13:06:36 ******************
--DROP FUNCTION material_fact_consumptions_add_material(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_material(text)
RETURNS int as $$
DECLARE
	v_raw_material_id int;
BEGIN
	v_raw_material_id = NULL;
	SELECT raw_material_id INTO v_raw_material_id FROM raw_material_map_to_production WHERE production_descr = $1;
	IF NOT FOUND THEN
		INSERT INTO raw_material_map_to_production
		(date_time,production_descr)
		VALUES
		(now(),$1)
		;
	END IF;
	
	RETURN v_raw_material_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_material(text) OWNER TO beton;


-- ******************* update 25/09/2019 17:51:51 ******************
DROP FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)
/*
CREATE OR REPLACE FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)
RETURNS void as $$
BEGIN
    UPDATE material_fact_consumptions
    SET
    	upload_date_time = now(),
    	upload_user_id = $2,
    	concrete_quant = $1.concrete_quant,
    	material_quant = $1.material_quant,
    	material_quant_req = $1.material_quant_req
    	
    WHERE production_site_id = $1.production_site_id
    	AND date_time = $1.date_time
    	AND concrete_type_production_descr = $1.concrete_type_production_descr
    	AND raw_material_production_descr = $1.raw_material_production_descr
    	AND vehicle_production_descr = $1.vehicle_production_descr
    	;
    
    IF FOUND THEN
        RETURN;
    END IF;
    
    BEGIN
        INSERT INTO material_fact_consumptions (
        	production_site_id,
        	upload_date_time,
        	upload_user_id,
        	date_time,
        	concrete_type_production_descr,
        	raw_material_production_descr,
        	vehicle_production_descr,
        	concrete_quant,
        	material_quant,
        	material_quant_req
       	)
        VALUES (
        	$1.production_site_id,
        	now(),
        	$2,
        	$1.date_time,
        	$1.concrete_type_production_descr,
        	$1.raw_material_production_descr,
        	$1.vehicle_production_descr,
        	$1.concrete_quant,
        	$1.material_quant,
        	$1.material_quant_req
        );
    EXCEPTION WHEN OTHERS THEN
	    UPDATE material_fact_consumptions
	    SET
	    	upload_date_time = now(),
	    	upload_user_id = $2,
	    	concrete_quant = $1.concrete_quant,
	    	material_quant = $1.material_quant,
	    	material_quant_req = $1.material_quant_req
	    	
	    WHERE production_site_id = $1.production_site_id
	    	AND date_time = $1.date_time
	    	AND concrete_type_production_descr = $1.concrete_type_production_descr
	    	AND raw_material_production_descr = $1.raw_material_production_descr
	    	AND vehicle_production_descr = $1.vehicle_production_descr
	    	;
    END;
    RETURN;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add(material_fact_consumptions,int) OWNER TO beton;
*/


-- ******************* update 25/09/2019 17:54:56 ******************
--DROP FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)

CREATE OR REPLACE FUNCTION material_fact_consumptions_add(material_fact_consumptions)
RETURNS void as $$
BEGIN
    UPDATE material_fact_consumptions
    SET
    	upload_date_time = $1.upload_date_time,
    	upload_user_id = $1.upload_user_id,
    	concrete_quant = $1.concrete_quant,
    	material_quant = $1.material_quant,
    	material_quant_req = $1.material_quant_req
    	
    WHERE production_site_id = $1.production_site_id
    	AND date_time = $1.date_time
    	AND concrete_type_production_descr = $1.concrete_type_production_descr
    	AND raw_material_production_descr = $1.raw_material_production_descr
    	AND vehicle_production_descr = $1.vehicle_production_descr
    	;
    
    IF FOUND THEN
        RETURN;
    END IF;
    
    BEGIN
        INSERT INTO material_fact_consumptions 
        VALUES ($1.*);
    EXCEPTION WHEN OTHERS THEN
	    UPDATE material_fact_consumptions
	    SET
	    	upload_date_time = $1.upload_date_time,
	    	upload_user_id = $1.upload_user_id,
	    	concrete_quant = $1.concrete_quant,
	    	material_quant = $1.material_quant,
	    	material_quant_req = $1.material_quant_req
	    	
	    WHERE production_site_id = $1.production_site_id
	    	AND date_time = $1.date_time
	    	AND concrete_type_production_descr = $1.concrete_type_production_descr
	    	AND raw_material_production_descr = $1.raw_material_production_descr
	    	AND vehicle_production_descr = $1.vehicle_production_descr
	    	;
    END;
    RETURN;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add(material_fact_consumptions) OWNER TO beton;



-- ******************* update 25/09/2019 18:23:55 ******************
--DROP FUNCTION material_fact_consumptions_add_concrete_type(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_concrete_type(text)
RETURNS int as $$
DECLARE
	v_concrete_type_id int;
BEGIN
	v_concrete_type_id = NULL;
	SELECT concrete_type_id INTO v_concrete_type_id FROM concrete_type_map_to_production WHERE production_descr = $1;
	IF NOT FOUND THEN
		INSERT INTO concrete_type_map_to_production
		(production_descr)
		VALUES
		($1)
		;
	END IF;
	
	RETURN v_concrete_type_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_concrete_type(text) OWNER TO beton;


-- ******************* update 25/09/2019 18:24:10 ******************
--DROP FUNCTION material_fact_consumptions_add_vehicle(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_vehicle(text)
RETURNS int as $$
DECLARE
	v_vehicle_id int;
BEGIN
	v_vehicle_id = NULL;
	SELECT vehicle_id INTO v_vehicle_id FROM vehicle_map_to_production WHERE production_descr = $1;
	IF NOT FOUND THEN
		INSERT INTO vehicle_map_to_production
		(production_descr)
		VALUES
		($1)
		;
	END IF;
	
	RETURN v_vehicle_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_vehicle(text) OWNER TO beton;


-- ******************* update 25/09/2019 18:35:16 ******************
--DROP FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)

CREATE OR REPLACE FUNCTION material_fact_consumptions_add(material_fact_consumptions)
RETURNS void as $$
BEGIN
    UPDATE material_fact_consumptions
    SET
    	upload_date_time = $1.upload_date_time,
    	upload_user_id = $1.upload_user_id,
    	concrete_quant = $1.concrete_quant,
    	material_quant = $1.material_quant,
    	material_quant_req = $1.material_quant_req
    	
    WHERE production_site_id = $1.production_site_id
    	AND date_time = $1.date_time
    	AND concrete_type_production_descr = $1.concrete_type_production_descr
    	AND raw_material_production_descr = $1.raw_material_production_descr
    	AND vehicle_production_descr = $1.vehicle_production_descr
    	;
    
    IF FOUND THEN
        RETURN;
    END IF;
    
    --BEGIN
        INSERT INTO material_fact_consumptions 
        VALUES ($1.*);
    /*    
    EXCEPTION WHEN OTHERS THEN
	    UPDATE material_fact_consumptions
	    SET
	    	upload_date_time = $1.upload_date_time,
	    	upload_user_id = $1.upload_user_id,
	    	concrete_quant = $1.concrete_quant,
	    	material_quant = $1.material_quant,
	    	material_quant_req = $1.material_quant_req
	    	
	    WHERE production_site_id = $1.production_site_id
	    	AND date_time = $1.date_time
	    	AND concrete_type_production_descr = $1.concrete_type_production_descr
	    	AND raw_material_production_descr = $1.raw_material_production_descr
	    	AND vehicle_production_descr = $1.vehicle_production_descr
	    	;
    END;
    */
    RETURN;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add(material_fact_consumptions) OWNER TO beton;



-- ******************* update 26/09/2019 09:19:26 ******************
-- VIEW: material_fact_consumptions_list

DROP VIEW material_fact_consumptions_list;

CREATE OR REPLACE VIEW material_fact_consumptions_list AS
	SELECT
		t.id,
		t.date_time,
		t.upload_date_time,
		users_ref(u) AS upload_users_ref,
		production_sites_ref(pr) AS production_sites_ref,
		concrete_types_ref(ct) AS concrete_types_ref,
		materials_ref(mat) AS raw_materials_ref,
		vehicles_ref(vh) AS vehicles_ref,
		t.concrete_quant,
		t.material_quant,
		t.material_quant_req
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	ORDER BY pr.name,t.date_time,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO beton;


-- ******************* update 26/09/2019 09:38:19 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10035',
		'MaterialFactConsumption_Controller',
		'get_list',
		'MaterialFactConsumptionList',
		'Формы',
		'Фактический расход материалов',
		FALSE
		);
	

-- ******************* update 26/09/2019 09:58:20 ******************
--DROP FUNCTION material_fact_consumptions_add_vehicle(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_vehicle(text)
RETURNS int as $$
DECLARE
	v_vehicle_id int;
BEGIN
	v_vehicle_id = NULL;
	SELECT vehicle_id INTO v_vehicle_id FROM vehicle_map_to_production WHERE production_descr = $1;
	IF NOT FOUND THEN
		SELECT id FROM vehciles INTO v_vehicle_id WHERE plate=$1 OR (length($1)=3 AND length(plate)=6 AND '%'||plate||'%' LIKE $1);
		
		INSERT INTO vehicle_map_to_production
		(production_descr,vehicle_id)
		VALUES
		($1,v_vehicle_id)
		;
	END IF;
	
	RETURN v_vehicle_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_vehicle(text) OWNER TO beton;


-- ******************* update 26/09/2019 09:59:12 ******************
--DROP FUNCTION material_fact_consumptions_add_material(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_material(text)
RETURNS int as $$
DECLARE
	v_raw_material_id int;
BEGIN
	v_raw_material_id = NULL;
	SELECT raw_material_id INTO v_raw_material_id FROM raw_material_map_to_production WHERE production_descr = $1;
	IF NOT FOUND THEN
		SELECT id FROM raw_materials INTO v_raw_material_id WHERE name=$1;
	
		INSERT INTO raw_material_map_to_production
		(date_time,production_descr,raw_material_id)
		VALUES
		(now(),$1,v_raw_material_id)
		;
	END IF;
	
	RETURN v_raw_material_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_material(text) OWNER TO beton;


-- ******************* update 26/09/2019 09:59:51 ******************
--DROP FUNCTION material_fact_consumptions_add_concrete_type(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_concrete_type(text)
RETURNS int as $$
DECLARE
	v_concrete_type_id int;
BEGIN
	v_concrete_type_id = NULL;
	SELECT concrete_type_id INTO v_concrete_type_id FROM concrete_type_map_to_production WHERE production_descr = $1;
	IF NOT FOUND THEN
		SELECT id FROM concrete_types INTO v_concrete_type_id WHERE name=$1;
	
		INSERT INTO concrete_type_map_to_production
		(production_descr,concrete_type_id)
		VALUES
		($1,v_concrete_type_id)
		;
	END IF;
	
	RETURN v_concrete_type_id;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add_concrete_type(text) OWNER TO beton;


-- ******************* update 26/09/2019 10:47:37 ******************
﻿-- Function: raw_material_map_to_production_recalc(in_material_id int, in_date_time timestamp)

-- DROP FUNCTION raw_material_map_to_production_recalc(int in_material_id int, in_date_time timestamp);

CREATE OR REPLACE FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_date_time timestamp)
  RETURNS void AS
$$
	UPDATE material_fact_consumptions
	SET raw_material_id=in_material_id
	WHERE (in_date_time IS NOT NULL AND date_time>=in_date_time) OR in_date_time IS NULL
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_date_time timestamp) OWNER TO beton;


-- ******************* update 26/09/2019 10:48:26 ******************
-- Function: public.raw_material_map_to_production_process()

-- DROP FUNCTION public.raw_material_map_to_production_process();

CREATE OR REPLACE FUNCTION public.raw_material_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM raw_material_map_to_production_recalc(
			OLD.material_id,
			(SELECT date_time FROM raw_material_map_to_production WHERE date_time<OLD.date_time ORDER BY date_time DESC LIMIT 1)
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM raw_material_map_to_production_recalc(
			NEW.material_id,
			NEW.date_time
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (NEW.raw_material_id<>OLD.raw_material_id OR NEW.date_time<>OLD.date_time) THEN
		PERFORM raw_material_map_to_production_recalc(
			NEW.material_id,
			least(NEW.date_time,OLD.date_time)
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.raw_material_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 10:50:38 ******************
-- Trigger: raw_material_map_to_production_trigger_after on public.raw_material_map_to_production

-- DROP TRIGGER raw_material_map_to_production_trigger_after ON public.raw_material_map_to_production;

CREATE TRIGGER raw_material_map_to_production_trigger_after
  AFTER INSERT OR UPDATE OR DELETE
  ON public.raw_material_map_to_production
  FOR EACH ROW
  EXECUTE PROCEDURE public.raw_material_map_to_production_process();



-- ******************* update 26/09/2019 10:52:52 ******************
﻿-- Function: raw_material_map_to_production_recalc(in_material_id int, in_date_time timestamp)

 DROP FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_date_time timestamp);
/*
CREATE OR REPLACE FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_date_time timestamp)
  RETURNS void AS
$$
	UPDATE material_fact_consumptions
	SET raw_material_id=in_material_id
	WHERE (in_date_time IS NOT NULL AND date_time>=in_date_time) OR in_date_time IS NULL
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_date_time timestamp) OWNER TO beton;
*/


-- ******************* update 26/09/2019 10:54:44 ******************
﻿-- Function: raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp)

-- DROP FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp);

CREATE OR REPLACE FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp)
  RETURNS void AS
$$
	UPDATE material_fact_consumptions
	SET raw_material_id=in_material_id
	WHERE raw_material_production_descr = in_production_descr
	AND ( (in_date_time IS NOT NULL AND date_time>=in_date_time) OR in_date_time IS NULL )
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp) OWNER TO beton;



-- ******************* update 26/09/2019 10:58:30 ******************
-- Function: public.raw_material_map_to_production_process()

-- DROP FUNCTION public.raw_material_map_to_production_process();

CREATE OR REPLACE FUNCTION public.raw_material_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM raw_material_map_to_production_recalc(
			OLD.material_id,
			OLD.production_descr,
			(SELECT date_time FROM raw_material_map_to_production WHERE date_time<OLD.date_time ORDER BY date_time DESC LIMIT 1)
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM raw_material_map_to_production_recalc(
			NEW.material_id,
			NEW.production_descr,
			NEW.date_time
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (NEW.raw_material_id<>OLD.raw_material_id OR NEW.date_time<>OLD.date_time OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET raw_material_id = NULL
			WHERE raw_material_production_descr=OLD.production_descr AND date_time>=OLD.date_time;			
		END IF;
		
		PERFORM raw_material_map_to_production_recalc(
			NEW.material_id,
			NEW.production_descr,
			least(NEW.date_time,OLD.date_time)
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.raw_material_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 10:58:36 ******************
﻿-- Function: raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp)

-- DROP FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp);

CREATE OR REPLACE FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp)
  RETURNS void AS
$$
	UPDATE material_fact_consumptions
	SET raw_material_id=in_material_id
	WHERE raw_material_production_descr = in_production_descr
	AND ( (in_date_time IS NOT NULL AND date_time>=in_date_time) OR in_date_time IS NULL )
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp) OWNER TO beton;



-- ******************* update 26/09/2019 10:59:52 ******************
﻿-- Function: vehicle_map_to_production_recalc(in_vehicle_id int, in_production_descr text)

-- DROP FUNCTION vehicle_map_to_production_recalc(int in_vehicle_id int, in_production_descr text);

CREATE OR REPLACE FUNCTION vehicle_map_to_production_recalc(in_vehicle_id int, in_production_descr text)
  RETURNS void AS
$$
	UPDATE material_fact_consumptions
	SET vehicle_id=in_vehicle_id
	WHERE vehicle_production_descr=in_production_descr;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION vehicle_map_to_production_recalc(in_material_id int, in_production_descr text) OWNER TO beton;


-- ******************* update 26/09/2019 11:02:33 ******************
-- Function: public.vehicle_map_to_production_process()

-- DROP FUNCTION public.vehicle_map_to_production_process();

CREATE OR REPLACE FUNCTION public.vehicle_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM vehicle_map_to_production_recalc(
			OLD.vehicle_id,
			OLD.production_descr
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM vehicle_map_to_production_recalc(
			NEW.vehicle_id,
			NEW.production_descr
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (NEW.vehicle_id<>OLD.vehicle_id OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET vehicle_id = NULL
			WHERE vehicle_production_descr=OLD.production_descr;
		END IF;
		
		PERFORM vehicle_map_to_production_recalc(
			NEW.vehicle_id,
			NEW.production_descr
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicle_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 11:03:14 ******************
-- Trigger: vehicle_map_to_production_trigger_after on public.vehicle_map_to_production

-- DROP TRIGGER vehicle_map_to_production_trigger_after ON public.vehicle_map_to_production;

CREATE TRIGGER vehicle_map_to_production_trigger_after
  AFTER INSERT OR UPDATE OR DELETE
  ON public.vehicle_map_to_production
  FOR EACH ROW
  EXECUTE PROCEDURE public.vehicle_map_to_production_process();



-- ******************* update 26/09/2019 11:05:14 ******************
-- Function: public.concrete_type_map_to_production_process()

-- DROP FUNCTION public.concrete_type_map_to_production_process();

CREATE OR REPLACE FUNCTION public.concrete_type_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM concrete_type_map_to_production_recalc(
			OLD.concrete_type_id,
			OLD.production_descr
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (NEW.concrete_type_id<>OLD.concrete_type_id OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET concrete_type_id = NULL
			WHERE concrete_type_production_descr=OLD.production_descr;
		END IF;
		
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_type_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 11:05:53 ******************
﻿-- Function: concrete_type_map_to_production_recalc(in_concrete_type_id int, in_production_descr text)

-- DROP FUNCTION concrete_type_map_to_production_recalc(int in_concrete_type_id int, in_production_descr text);

CREATE OR REPLACE FUNCTION concrete_type_map_to_production_recalc(in_concrete_type_id int, in_production_descr text)
  RETURNS void AS
$$
	UPDATE material_fact_consumptions
	SET concrete_type_id=in_concrete_type_id
	WHERE concrete_type_production_descr=in_production_descr;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION concrete_type_map_to_production_recalc(in_material_id int, in_production_descr text) OWNER TO beton;


-- ******************* update 26/09/2019 11:05:57 ******************
-- Function: public.concrete_type_map_to_production_process()

-- DROP FUNCTION public.concrete_type_map_to_production_process();

CREATE OR REPLACE FUNCTION public.concrete_type_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM concrete_type_map_to_production_recalc(
			OLD.concrete_type_id,
			OLD.production_descr
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (NEW.concrete_type_id<>OLD.concrete_type_id OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET concrete_type_id = NULL
			WHERE concrete_type_production_descr=OLD.production_descr;
		END IF;
		
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_type_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 11:06:00 ******************
-- Trigger: concrete_type_map_to_production_trigger_after on public.concrete_type_map_to_production

-- DROP TRIGGER concrete_type_map_to_production_trigger_after ON public.concrete_type_map_to_production;

CREATE TRIGGER concrete_type_map_to_production_trigger_after
  AFTER INSERT OR UPDATE OR DELETE
  ON public.concrete_type_map_to_production
  FOR EACH ROW
  EXECUTE PROCEDURE public.concrete_type_map_to_production_process();



-- ******************* update 26/09/2019 11:11:57 ******************
--DROP FUNCTION material_fact_consumptions_add(material_fact_consumptions,int)

CREATE OR REPLACE FUNCTION material_fact_consumptions_add(material_fact_consumptions)
RETURNS void as $$
BEGIN
    UPDATE material_fact_consumptions
    SET
    	upload_date_time = $1.upload_date_time,
    	upload_user_id = $1.upload_user_id,
    	concrete_quant = $1.concrete_quant,
    	material_quant = $1.material_quant,
    	material_quant_req = $1.material_quant_req
    	
    WHERE production_site_id = $1.production_site_id
    	AND date_time = $1.date_time
    	AND concrete_type_production_descr = $1.concrete_type_production_descr
    	AND raw_material_production_descr = $1.raw_material_production_descr
    	AND vehicle_production_descr = $1.vehicle_production_descr
    	;
    
    IF FOUND THEN
        RETURN;
    END IF;
    
    BEGIN
        INSERT INTO material_fact_consumptions 
        VALUES ($1.*);
       
    EXCEPTION WHEN unique_violation THEN
	    UPDATE material_fact_consumptions
	    SET
	    	upload_date_time = $1.upload_date_time,
	    	upload_user_id = $1.upload_user_id,
	    	concrete_quant = $1.concrete_quant,
	    	material_quant = $1.material_quant,
	    	material_quant_req = $1.material_quant_req
	    	
	    WHERE production_site_id = $1.production_site_id
	    	AND date_time = $1.date_time
	    	AND concrete_type_production_descr = $1.concrete_type_production_descr
	    	AND raw_material_production_descr = $1.raw_material_production_descr
	    	AND vehicle_production_descr = $1.vehicle_production_descr
	    	;
    END;
    
    RETURN;
END;
$$ language plpgsql;

ALTER FUNCTION material_fact_consumptions_add(material_fact_consumptions) OWNER TO beton;



-- ******************* update 26/09/2019 11:27:36 ******************
-- Function: public.concrete_type_map_to_production_process()

-- DROP FUNCTION public.concrete_type_map_to_production_process();

CREATE OR REPLACE FUNCTION public.concrete_type_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	RAISE EXCEPTION 'РЕЗ=%',(NEW.concrete_type_id<>OLD.concrete_type_id);
	IF TG_OP='DELETE' THEN
		PERFORM concrete_type_map_to_production_recalc(
			OLD.concrete_type_id,
			OLD.production_descr
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (NEW.concrete_type_id<>OLD.concrete_type_id OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET concrete_type_id = NULL
			WHERE concrete_type_production_descr=OLD.production_descr;
		END IF;
		
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
	
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' THEN
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_type_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 11:28:50 ******************
-- Function: public.concrete_type_map_to_production_process()

-- DROP FUNCTION public.concrete_type_map_to_production_process();

CREATE OR REPLACE FUNCTION public.concrete_type_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM concrete_type_map_to_production_recalc(
			OLD.concrete_type_id,
			OLD.production_descr
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.concrete_type_id,0)<>coalesce(OLD.concrete_type_id,0) OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET concrete_type_id = NULL
			WHERE concrete_type_production_descr=OLD.production_descr;
		END IF;
		
		PERFORM concrete_type_map_to_production_recalc(
			NEW.concrete_type_id,
			NEW.production_descr
		);
	
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' THEN
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_type_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 11:29:51 ******************
-- Function: public.raw_material_map_to_production_process()

-- DROP FUNCTION public.raw_material_map_to_production_process();

CREATE OR REPLACE FUNCTION public.raw_material_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM raw_material_map_to_production_recalc(
			OLD.material_id,
			OLD.production_descr,
			(SELECT date_time FROM raw_material_map_to_production WHERE date_time<OLD.date_time ORDER BY date_time DESC LIMIT 1)
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM raw_material_map_to_production_recalc(
			NEW.material_id,
			NEW.production_descr,
			NEW.date_time
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.raw_material_id,0)<>coalesce(OLD.raw_material_id,0) OR NEW.date_time<>OLD.date_time OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET raw_material_id = NULL
			WHERE raw_material_production_descr=OLD.production_descr AND date_time>=OLD.date_time;			
		END IF;
		
		PERFORM raw_material_map_to_production_recalc(
			NEW.material_id,
			NEW.production_descr,
			least(NEW.date_time,OLD.date_time)
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.raw_material_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 11:30:21 ******************
-- Function: public.vehicle_map_to_production_process()

-- DROP FUNCTION public.vehicle_map_to_production_process();

CREATE OR REPLACE FUNCTION public.vehicle_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM vehicle_map_to_production_recalc(
			OLD.vehicle_id,
			OLD.production_descr
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM vehicle_map_to_production_recalc(
			NEW.vehicle_id,
			NEW.production_descr
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET vehicle_id = NULL
			WHERE vehicle_production_descr=OLD.production_descr;
		END IF;
		
		PERFORM vehicle_map_to_production_recalc(
			NEW.vehicle_id,
			NEW.production_descr
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicle_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 12:08:29 ******************
-- Function: public.raw_material_map_to_production_process()

-- DROP FUNCTION public.raw_material_map_to_production_process();

CREATE OR REPLACE FUNCTION public.raw_material_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM raw_material_map_to_production_recalc(
			OLD.raw_material_id,
			OLD.production_descr,
			(SELECT date_time FROM raw_material_map_to_production WHERE date_time<OLD.date_time ORDER BY date_time DESC LIMIT 1)
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM raw_material_map_to_production_recalc(
			NEW.raw_material_id,
			NEW.production_descr,
			NEW.date_time
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.raw_material_id,0)<>coalesce(OLD.raw_material_id,0) OR NEW.date_time<>OLD.date_time OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET raw_material_id = NULL
			WHERE raw_material_production_descr=OLD.production_descr AND date_time>=OLD.date_time;			
		END IF;
		
		PERFORM raw_material_map_to_production_recalc(
			NEW.raw_material_id,
			NEW.production_descr,
			least(NEW.date_time,OLD.date_time)
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.raw_material_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 12:09:44 ******************
-- Function: public.raw_material_map_to_production_process()

-- DROP FUNCTION public.raw_material_map_to_production_process();

CREATE OR REPLACE FUNCTION public.raw_material_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM raw_material_map_to_production_recalc(
			OLD.raw_material_id,
			OLD.production_descr::text,
			(SELECT date_time FROM raw_material_map_to_production WHERE date_time<OLD.date_time ORDER BY date_time DESC LIMIT 1)
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM raw_material_map_to_production_recalc(
			NEW.raw_material_id,
			NEW.production_descr::text,
			NEW.date_time
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.raw_material_id,0)<>coalesce(OLD.raw_material_id,0) OR NEW.date_time<>OLD.date_time OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET raw_material_id = NULL
			WHERE raw_material_production_descr=OLD.production_descr AND date_time>=OLD.date_time;			
		END IF;
		
		PERFORM raw_material_map_to_production_recalc(
			NEW.raw_material_id,
			NEW.production_descr::text,
			least(NEW.date_time,OLD.date_time)
		);
	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.raw_material_map_to_production_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 12:10:20 ******************
﻿-- Function: raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp with time zone)

-- DROP FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp with time zone);

CREATE OR REPLACE FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp with time zone)
  RETURNS void AS
$$
	UPDATE material_fact_consumptions
	SET raw_material_id=in_material_id
	WHERE raw_material_production_descr = in_production_descr
	AND ( (in_date_time IS NOT NULL AND date_time>=in_date_time) OR in_date_time IS NULL )
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION raw_material_map_to_production_recalc(in_material_id int, in_production_descr text, in_date_time timestamp with time zone) OWNER TO beton;



-- ******************* update 26/09/2019 12:31:35 ******************
﻿-- Function: material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int)

-- DROP FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int)
  RETURNS int AS
$$
	SELECT id FROM vehicle_schedule_states AS st
	WHERE st.schedule_id =
		(SELECT vsch.id FROM vehicle_schedules AS vsch WHERE vsch.vehicle_id=in_vehicle_id AND vsch.schedule_date = in_date_time::date)
	AND st.date_time BETWEEN in_date_time-'1 minute'::interval AND in_date_time+'1 minute'::interval
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int) OWNER TO beton;


-- ******************* update 26/09/2019 12:42:13 ******************
-- VIEW: material_fact_consumptions_list

--DROP VIEW material_fact_consumptions_list;

CREATE OR REPLACE VIEW material_fact_consumptions_list AS
	SELECT
		t.id,
		t.date_time,
		t.upload_date_time,
		users_ref(u) AS upload_users_ref,
		production_sites_ref(pr) AS production_sites_ref,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.concrete_type_production_descr,
		materials_ref(mat) AS raw_materials_ref,
		t.raw_material_production_descr,
		vehicles_ref(vh) AS vehicles_ref,
		t.vehicle_production_descr,
		orders_ref(o) AS orders_ref,
		CASE
			WHEN sh.id IS NOT NULL THEN
				'№'||sh.id||' от '||to_char(sh.date_time,'DD/MM/YY HH24:MI:SS')
			ELSE ''
		END AS shipments_inf,
		t.concrete_quant,
		t.material_quant,
		t.material_quant_req
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	LEFT JOIN vehicle_schedule_states AS vh_sch_st ON vh_sch_st.id=t.vehicle_schedule_state_id
	LEFT JOIN shipments AS sh ON sh.id=vh_sch_st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id
	ORDER BY pr.name,t.date_time,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO beton;


-- ******************* update 26/09/2019 12:49:37 ******************
﻿-- Function: material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int)

-- DROP FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int)
  RETURNS int AS
$$
	SELECT id FROM vehicle_schedule_states AS st
	WHERE st.schedule_id =
		(SELECT vsch.id FROM vehicle_schedules AS vsch WHERE vsch.vehicle_id=in_vehicle_id AND vsch.schedule_date = in_date_time::date)
	AND st.state = 'assigned'
	AND st.date_time BETWEEN in_date_time-'10 minute'::interval AND in_date_time+'10 minute'::interval
	LIMIT 1
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int) OWNER TO beton;


-- ******************* update 26/09/2019 12:52:33 ******************
﻿-- Function: material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int)

-- DROP FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int)
  RETURNS int AS
$$
	SELECT id FROM vehicle_schedule_states AS st
	WHERE st.schedule_id =
		(SELECT vsch.id FROM vehicle_schedules AS vsch WHERE vsch.vehicle_id=in_vehicle_id AND vsch.schedule_date = in_date_time::date)
	AND (st.state = 'assigned' OR st.state = 'busy')
	AND st.date_time BETWEEN in_date_time-'10 minute'::interval AND in_date_time+'10 minute'::interval
	LIMIT 1
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int) OWNER TO beton;


-- ******************* update 26/09/2019 12:53:11 ******************
﻿-- Function: material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int)

-- DROP FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int)
  RETURNS int AS
$$
	SELECT id FROM vehicle_schedule_states AS st
	WHERE st.schedule_id =
		(SELECT vsch.id FROM vehicle_schedules AS vsch WHERE vsch.vehicle_id=in_vehicle_id AND vsch.schedule_date = in_date_time::date)
	AND (st.state = 'assigned' OR st.state = 'busy')
	AND st.date_time BETWEEN in_date_time-'20 minute'::interval AND in_date_time+'20 minute'::interval
	LIMIT 1
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp without time zone,in_vehicle_id int) OWNER TO beton;


-- ******************* update 26/09/2019 12:58:57 ******************
﻿-- Function: material_fact_consumptions_find_schedule(in_date_time timestamp with time zone,in_vehicle_id int)

-- DROP FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp with time zone,in_vehicle_id int);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp with time zone,in_vehicle_id int)
  RETURNS int AS
$$
	SELECT id FROM vehicle_schedule_states AS st
	WHERE st.schedule_id =
		(SELECT vsch.id FROM vehicle_schedules AS vsch WHERE vsch.vehicle_id=in_vehicle_id AND vsch.schedule_date = in_date_time::date)
	AND (st.state = 'assigned' OR st.state = 'busy')
	AND st.date_time BETWEEN in_date_time-'20 minute'::interval AND in_date_time+'20 minute'::interval
	LIMIT 1
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_schedule(in_date_time timestamp with time zone,in_vehicle_id int) OWNER TO beton;


-- ******************* update 26/09/2019 13:00:11 ******************
-- VIEW: material_fact_consumptions_list

--DROP VIEW material_fact_consumptions_list;

CREATE OR REPLACE VIEW material_fact_consumptions_list AS
	SELECT
		t.id,
		t.date_time,
		t.upload_date_time,
		users_ref(u) AS upload_users_ref,
		production_sites_ref(pr) AS production_sites_ref,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.concrete_type_production_descr,
		materials_ref(mat) AS raw_materials_ref,
		t.raw_material_production_descr,
		vehicles_ref(vh) AS vehicles_ref,
		t.vehicle_production_descr,
		orders_ref(o) AS orders_ref,
		CASE
			WHEN sh.id IS NOT NULL THEN
				'№'||sh.id||' от '||to_char(sh.date_time,'DD/MM/YY HH24:MI:SS')
			ELSE ''
		END AS shipments_inf,
		t.concrete_quant,
		t.material_quant,
		t.material_quant_req
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	LEFT JOIN vehicle_schedule_states AS vh_sch_st ON vh_sch_st.id=t.vehicle_schedule_state_id
	LEFT JOIN shipments AS sh ON sh.id=vh_sch_st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id
	ORDER BY pr.name,t.date_time,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO beton;


-- ******************* update 26/09/2019 14:08:07 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='INSERT' THEN
		SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_id;
		RETURN NEW;
		
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time) THEN
		SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_id;
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 14:09:47 ******************
-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

-- DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;

CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE INSERT OR UPDATE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();



-- ******************* update 26/09/2019 14:11:21 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='INSERT' THEN
		SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		RETURN NEW;
		
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time) THEN
		SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 14:31:03 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='INSERT' THEN
		SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		RETURN NEW;
		
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time) THEN
		SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' THEN	
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 26/09/2019 14:42:54 ******************
-- Function: public.orders_ref(orders)

-- DROP FUNCTION public.orders_ref(orders);

CREATE OR REPLACE FUNCTION public.orders_ref(orders)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr','Заявка №'||order_num($1)::text||' от '||to_char($1.date_time,'DD/MM/YY HH24:MI'),
		'dataType','orders'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.orders_ref(orders) OWNER TO beton;



-- ******************* update 26/09/2019 14:51:24 ******************
-- VIEW: material_fact_consumptions_list

DROP VIEW material_fact_consumptions_list;

CREATE OR REPLACE VIEW material_fact_consumptions_list AS
	SELECT
		t.id,
		t.date_time,
		t.upload_date_time,
		users_ref(u) AS upload_users_ref,
		production_sites_ref(pr) AS production_sites_ref,
		t.production_site_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.concrete_type_production_descr,
		materials_ref(mat) AS raw_materials_ref,
		t.raw_material_production_descr,
		vehicles_ref(vh) AS vehicles_ref,
		t.vehicle_production_descr,
		orders_ref(o) AS orders_ref,
		CASE
			WHEN sh.id IS NOT NULL THEN
				'№'||sh.id||' от '||to_char(sh.date_time,'DD/MM/YY HH24:MI:SS')
			ELSE ''
		END AS shipments_inf,
		t.concrete_quant,
		t.material_quant,
		t.material_quant_req
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	LEFT JOIN vehicle_schedule_states AS vh_sch_st ON vh_sch_st.id=t.vehicle_schedule_state_id
	LEFT JOIN shipments AS sh ON sh.id=vh_sch_st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id
	ORDER BY pr.name,t.date_time,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO beton;


-- ******************* update 26/09/2019 17:13:15 ******************
-- VIEW: material_fact_consumptions_list

DROP VIEW material_fact_consumptions_list;

CREATE OR REPLACE VIEW material_fact_consumptions_list AS
	SELECT
		t.id,
		t.date_time,
		t.upload_date_time,
		users_ref(u) AS upload_users_ref,
		production_sites_ref(pr) AS production_sites_ref,
		t.production_site_id,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.concrete_type_production_descr,
		materials_ref(mat) AS raw_materials_ref,
		t.raw_material_production_descr,
		vehicles_ref(vh) AS vehicles_ref,
		t.vehicle_production_descr,
		orders_ref(o) AS orders_ref,
		CASE
			WHEN sh.id IS NOT NULL THEN
				'№'||sh.id||' от '||to_char(sh.date_time,'DD/MM/YY HH24:MI:SS')
			ELSE ''
		END AS shipments_inf,
		t.concrete_quant,
		t.material_quant,
		t.material_quant_req
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	LEFT JOIN vehicle_schedule_states AS vh_sch_st ON vh_sch_st.id=t.vehicle_schedule_state_id
	LEFT JOIN shipments AS sh ON sh.id=vh_sch_st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id
	ORDER BY pr.name,t.date_time,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO beton;


-- ******************* update 26/09/2019 17:17:46 ******************
-- VIEW: material_fact_consumptions_rolled_list

--DROP VIEW material_fact_consumptions_rolled_list;

CREATE OR REPLACE VIEW material_fact_consumptions_rolled_list AS
	SELECT
		t.date_time,
		t.upload_date_time,
		t.upload_users_ref::text,
		t.production_sites_ref::text,
		t.production_site_id,
		t.concrete_types_ref::text,
		t.concrete_type_production_descr,
		t.raw_materials_ref::text,
		t.raw_material_production_descr,
		t.vehicles_ref::text,
		t.vehicle_production_descr,
		t.orders_ref::text,
		t.shipments_inf,
		sum(t.concrete_quant) AS concrete_quant,
		sum(t.material_quant) AS material_quant,
		sum(t.material_quant_req) AS material_quant_req
	FROM material_fact_consumptions_list AS t
	GROUP BY 
		t.date_time,
		t.upload_date_time,
		t.upload_users_ref::text,
		t.production_sites_ref::text,
		t.production_site_id,
		t.concrete_types_ref::text,
		t.concrete_type_production_descr,
		t.raw_materials_ref::text,
		t.raw_material_production_descr,
		t.vehicles_ref::text,
		t.vehicle_production_descr,
		t.orders_ref::text,
		t.shipments_inf	
	;
	
ALTER VIEW material_fact_consumptions_rolled_list OWNER TO beton;


-- ******************* update 26/09/2019 17:23:11 ******************
-- VIEW: material_fact_consumptions_rolled_list

DROP VIEW material_fact_consumptions_rolled_list;

CREATE OR REPLACE VIEW material_fact_consumptions_rolled_list AS
	SELECT
		t.date_time,
		t.upload_date_time,
		t.upload_users_ref::text,
		t.production_sites_ref::text,
		t.production_site_id,
		t.concrete_types_ref::text,
		t.concrete_type_production_descr,
		t.raw_materials_ref::text,
		t.raw_material_production_descr,
		t.vehicles_ref::text,
		t.vehicle_production_descr,
		t.orders_ref::text,
		t.shipments_inf,
		t.concrete_quant,
		sum(t.material_quant) AS material_quant,
		sum(t.material_quant_req) AS material_quant_req
	FROM material_fact_consumptions_list AS t
	GROUP BY 
		t.date_time,
		t.upload_date_time,
		t.upload_users_ref::text,
		t.production_sites_ref::text,
		t.production_site_id,
		t.concrete_types_ref::text,
		t.concrete_type_production_descr,
		t.raw_materials_ref::text,
		t.raw_material_production_descr,
		t.vehicles_ref::text,
		t.vehicle_production_descr,
		t.orders_ref::text,
		t.shipments_inf,
		t.concrete_quant	
	;
	
ALTER VIEW material_fact_consumptions_rolled_list OWNER TO beton;


-- ******************* update 30/09/2019 09:52:13 ******************
-- VIEW: material_fact_consumptions_rolled_list

DROP VIEW material_fact_consumptions_rolled_list;

CREATE OR REPLACE VIEW material_fact_consumptions_rolled_list AS
	SELECT
		date_time,
		upload_date_time,
		(upload_users_ref::text)::jsonb AS upload_users_ref,
		(production_sites_ref::text)::jsonb AS production_sites_ref,
		production_site_id,
		(concrete_types_ref::text)::jsonb AS concrete_types_ref,
		concrete_type_production_descr,
		(vehicles_ref::text)::jsonb AS vehicles_ref,
		vehicle_production_descr,
		(orders_ref::text)::jsonb AS orders_ref,
		shipments_inf,
		concrete_quant,
		jsonb_agg(
			jsonb_build_object(
				'production_descr',raw_material_production_descr,
				'ref',raw_materials_ref,
				'quant',material_quant,
				'quant_req',material_quant_req
			)
		) AS materials
	FROM material_fact_consumptions_list
	GROUP BY date_time,
		concrete_quant,
		upload_date_time,
		upload_users_ref::text,
		production_sites_ref::text,
		production_site_id,
		concrete_types_ref::text,
		concrete_type_production_descr,
		vehicles_ref::text,
		vehicle_production_descr,
		orders_ref::text,
		shipments_inf
	ORDER BY date_time DESC

	;
	
ALTER VIEW material_fact_consumptions_rolled_list OWNER TO beton;


-- ******************* update 30/09/2019 10:09:09 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10036',
		'MaterialFactConsumption_Controller',
		'get_rolled_list',
		'MaterialFactConsumptionRolledList',
		'Формы',
		'Фактический расход материалов (свернуто)',
		FALSE
		);
	

-- ******************* update 30/09/2019 12:19:47 ******************

		ALTER TABLE raw_material_map_to_production ADD COLUMN order_id int;



-- ******************* update 30/09/2019 12:24:24 ******************
-- VIEW: raw_material_map_to_production_list

--DROP VIEW raw_material_map_to_production_list;

CREATE OR REPLACE VIEW raw_material_map_to_production_list AS
	SELECT
		t.id,
		t.date_time,
		materials_ref(mat) AS raw_materials_ref,
		t.production_descr,
		t.order_id
	FROM raw_material_map_to_production AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	ORDER BY t.order_id,t.date_time DESC
	;
	
ALTER VIEW raw_material_map_to_production_list OWNER TO beton;


-- ******************* update 30/09/2019 12:27:22 ******************
-- Function: public.raw_material_map_to_production_process()

-- DROP FUNCTION public.raw_material_map_to_production_process();

CREATE OR REPLACE FUNCTION public.raw_material_map_to_production_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_OP='DELETE' THEN
		PERFORM raw_material_map_to_production_recalc(
			OLD.raw_material_id,
			OLD.production_descr::text,
			(SELECT date_time FROM raw_material_map_to_production WHERE date_time<OLD.date_time ORDER BY date_time DESC LIMIT 1)
		);
		RETURN OLD;
		
	ELSEIF TG_OP='INSERT' THEN
		PERFORM raw_material_map_to_production_recalc(
			NEW.raw_material_id,
			NEW.production_descr::text,
			NEW.date_time
		);
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' AND (coalesce(NEW.raw_material_id,0)<>coalesce(OLD.raw_material_id,0) OR NEW.date_time<>OLD.date_time OR NEW.production_descr<>OLD.production_descr) THEN
		IF NEW.production_descr<>OLD.production_descr THEN
			UPDATE material_fact_consumptions
			SET raw_material_id = NULL
			WHERE raw_material_production_descr=OLD.production_descr AND date_time>=OLD.date_time;			
		END IF;
		
		PERFORM raw_material_map_to_production_recalc(
			NEW.raw_material_id,
			NEW.production_descr::text,
			least(NEW.date_time,OLD.date_time)
		);
	
		RETURN NEW;
	ELSEIF TG_OP='UPDATE' THEN
		RETURN NEW;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.raw_material_map_to_production_process()
  OWNER TO beton;


