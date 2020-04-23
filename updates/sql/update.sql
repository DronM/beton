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



-- ******************* update 01/10/2019 09:33:43 ******************
-- View: public.lab_entry_list

-- DROP VIEW public.lab_entry_list;

CREATE OR REPLACE VIEW public.lab_entry_list AS 
	SELECT
		lab.shipment_id AS id,
		sh.id AS shipment_id,
		sh.date_time,
		concr.id AS concrete_type_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		(
			SELECT round(avg(d.ok)) AS round
			FROM lab_entry_details d
			WHERE d.shipment_id = sh.id
		) AS ok,
		
		(
			SELECT round(avg(d.weight)) AS round
			FROM lab_entry_details d
			WHERE d.shipment_id = sh.id AND d.id >= 3
		) AS weight,
		
		round(
		CASE
			WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN (
			(
				SELECT avg(s_lab_det.kn::numeric / concr.mpa_ratio) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id < 3
			)
			) / concr.pres_norm * 100::numeric * 2::numeric / 2::numeric
			ELSE 0::numeric
		END) AS p7,
		
		round(
		CASE
			WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN (
			(
				SELECT avg(s_lab_det.kn::numeric / concr.mpa_ratio) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id >= 3
			)
			) / concr.pres_norm * 100::numeric * 2::numeric / 2::numeric
			ELSE 0::numeric
		END) AS p28,
		
		lab.samples,
		lab.materials,
		cl.id AS client_id,
		clients_ref(cl) AS clients_ref,
		cl.phone_cel AS client_phone,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		lab.ok2,
		lab."time"
	FROM shipments sh
	LEFT JOIN lab_entries lab ON lab.shipment_id = sh.id
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	ORDER BY sh.date_time, sh.id;

ALTER TABLE public.lab_entry_list OWNER TO beton;




-- ******************* update 01/10/2019 09:38:13 ******************
-- View: public.lab_entry_list

 DROP VIEW public.lab_entry_list;

CREATE OR REPLACE VIEW public.lab_entry_list AS 
	SELECT
		lab.shipment_id AS id,
		sh.id AS shipment_id,
		sh.date_time,
		
		production_sites_ref(pr_site) AS production_sites_ref,
		sh.production_site_id,
		
		concr.id AS concrete_type_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		(
			SELECT round(avg(d.ok)) AS round
			FROM lab_entry_details d
			WHERE d.shipment_id = sh.id
		) AS ok,
		
		(
			SELECT round(avg(d.weight)) AS round
			FROM lab_entry_details d
			WHERE d.shipment_id = sh.id AND d.id >= 3
		) AS weight,
		
		round(
		CASE
			WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN (
			(
				SELECT avg(s_lab_det.kn::numeric / concr.mpa_ratio) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id < 3
			)
			) / concr.pres_norm * 100::numeric * 2::numeric / 2::numeric
			ELSE 0::numeric
		END) AS p7,
		
		round(
		CASE
			WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN (
			(
				SELECT avg(s_lab_det.kn::numeric / concr.mpa_ratio) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id >= 3
			)
			) / concr.pres_norm * 100::numeric * 2::numeric / 2::numeric
			ELSE 0::numeric
		END) AS p28,
		
		lab.samples,
		lab.materials,
		cl.id AS client_id,
		clients_ref(cl) AS clients_ref,
		cl.phone_cel AS client_phone,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		lab.ok2,
		lab."time"
	FROM shipments sh
	LEFT JOIN lab_entries lab ON lab.shipment_id = sh.id
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN production_sites pr_site ON pr_site.id = sh.production_site_id
	ORDER BY sh.date_time, sh.id;

ALTER TABLE public.lab_entry_list OWNER TO beton;




-- ******************* update 01/10/2019 09:55:07 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'30016',
		'LabEntry_Controller',
		'get_list',
		'LabEntryList',
		'Формы',
		'Журнал испытания образцов',
		FALSE
		);
	

-- ******************* update 01/10/2019 09:57:56 ******************
-- View: public.lab_entry_list

-- DROP VIEW public.lab_entry_list;

CREATE OR REPLACE VIEW public.lab_entry_list AS 
	SELECT
		lab.shipment_id AS id,
		sh.id AS shipment_id,
		sh.date_time,
		
		production_sites_ref(pr_site) AS production_sites_ref,
		sh.production_site_id,
		
		concr.id AS concrete_type_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		(
			SELECT round(avg(d.ok)) AS round
			FROM lab_entry_details d
			WHERE d.shipment_id = sh.id
		) AS ok,
		
		(
			SELECT round(avg(d.weight)) AS round
			FROM lab_entry_details d
			WHERE d.shipment_id = sh.id AND d.id >= 3
		) AS weight,
		
		round(
		CASE
			WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN (
			(
				SELECT avg(s_lab_det.kn::numeric / concr.mpa_ratio) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id < 3
			)
			) / concr.pres_norm * 100::numeric * 2::numeric / 2::numeric
			ELSE 0::numeric
		END) AS p7,
		
		round(
		CASE
			WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN (
			(
				SELECT avg(s_lab_det.kn::numeric / concr.mpa_ratio) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id >= 3
			)
			) / concr.pres_norm * 100::numeric * 2::numeric / 2::numeric
			ELSE 0::numeric
		END) AS p28,
		
		lab.samples,
		lab.materials,
		cl.id AS client_id,
		clients_ref(cl) AS clients_ref,
		cl.phone_cel AS client_phone,
		o.destination_id,
		destinations_ref(dest) AS destinations_ref,
		lab.ok2,
		lab."time"
	FROM shipments sh
	LEFT JOIN lab_entries lab ON lab.shipment_id = sh.id
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN production_sites pr_site ON pr_site.id = sh.production_site_id
	ORDER BY sh.date_time DESC, sh.id;

ALTER TABLE public.lab_entry_list OWNER TO beton;




-- ******************* update 02/10/2019 13:04:45 ******************
-- View: public.lab_entry_detail_list

-- DROP VIEW public.lab_entry_detail_list;

CREATE OR REPLACE VIEW public.lab_entry_detail_list AS 
	SELECT
		sh.id AS shipment_id,
		lab.id,
		(sh.id::text || '/'::text) || lab.id::text AS code,
		sh.date_time AS ship_date_time,
		lab.ok,
		lab.weight,
		round(
			CASE
			WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN
			(
				SELECT avg(round(s_lab_det.kn::numeric / concr.mpa_ratio, 2)) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id < 3
			) / concr.pres_norm * 100::numeric
			ELSE 0::numeric
		END) AS p7,
		
		round(
			CASE
			WHEN concr.pres_norm IS NOT NULL AND concr.pres_norm > 0::numeric THEN
			(
				SELECT avg(round(s_lab_det.kn::numeric / concr.mpa_ratio, 2)) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id >= 3
			) / concr.pres_norm * 100::numeric
			ELSE 0::numeric
		END) AS p28,
		
		CASE
			WHEN lab.id < 3 THEN (sh.date_time::date + '7 days'::interval)::date
			ELSE (sh.date_time::date + '28 days'::interval)::date
		END AS p_date,
		
		lab.kn,
		round(lab.kn::numeric / concr.mpa_ratio, 2) AS mpa,
		
		round(
		CASE
			WHEN lab.id < 3 THEN
			(
				SELECT avg(round(s_lab_det.kn::numeric / concr.mpa_ratio, 2)) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id < 3
			)
			ELSE (
				SELECT avg(round(s_lab_det.kn::numeric / concr.mpa_ratio, 2)) AS avg
				FROM lab_entry_details s_lab_det
				WHERE s_lab_det.shipment_id = sh.id AND s_lab_det.id >= 3
			)
		END, 2) AS mpa_avg,
		
		concr.pres_norm
		
	FROM lab_entry_details lab
	LEFT JOIN shipments sh ON sh.id = lab.shipment_id
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	ORDER BY lab.shipment_id, lab.id;

ALTER TABLE public.lab_entry_detail_list OWNER TO beton;



-- ******************* update 02/10/2019 15:13:12 ******************
-- VIEW: raw_material_cons_rates_list

--DROP VIEW raw_material_cons_rates_list;

CREATE OR REPLACE VIEW raw_material_cons_rates_list AS
	SELECT
		t.rate_date_id,
		t.concrete_type_id,
		concrete_types_ref(ctp) AS concrete_types_ref,
		t.raw_material_id,
		materials_ref(m) AS raw_materials_ref,
		t.rate
		
	FROM raw_material_cons_rates t
	LEFT JOIN concrete_types AS ctp ON ctp.id=t.concrete_type_id
	LEFT JOIN raw_materials AS m ON m.id=t.raw_material_id
	;
	
ALTER VIEW raw_material_cons_rates_list OWNER TO beton;


-- ******************* update 07/10/2019 16:54:31 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_material_closed_balance_date
		(name text, descr text, val date,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_material_closed_balance_date OWNER TO beton;
		INSERT INTO const_material_closed_balance_date (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Дата закрытого периода остатков'
			,'Дата, раньше который период закрыт для редактирования'
			,NULL
			,'Date'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_material_closed_balance_date_val()
		RETURNS date AS
		$BODY$
			SELECT val::date AS val FROM const_material_closed_balance_date LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_material_closed_balance_date_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_material_closed_balance_date_set_val(Date)
		RETURNS void AS
		$BODY$
			UPDATE const_material_closed_balance_date SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_material_closed_balance_date_set_val(Date) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_material_closed_balance_date_view AS
		SELECT
			'material_closed_balance_date'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_material_closed_balance_date AS t
		;
		ALTER VIEW const_material_closed_balance_date_view OWNER TO beton;
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
		FROM const_low_efficiency_tel_list_view
		UNION ALL
		SELECT *
		FROM const_material_closed_balance_date_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	

-- ******************* update 08/10/2019 13:29:07 ******************
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
		
		CASE
		WHEN sh.destination_id = const_self_ship_dest_id_val() THEN 0
		ELSE
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
			) * shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)
		END AS cost_for_driver
		
	FROM shipments_list sh
	LEFT JOIN destinations AS dest ON dest.id=destination_id
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 08/10/2019 13:34:59 ******************

		ALTER TABLE destinations ADD COLUMN special_price_for_driver numeric(15,2) DEFAULT 0;


-- ******************* update 08/10/2019 13:38:16 ******************
-- View: public.destinations_dialog

-- DROP VIEW public.destinations_dialog;

CREATE OR REPLACE VIEW public.destinations_dialog AS 
	WITH
	last_price AS
		(SELECT
			max(t.date) AS date,
			t.distance_to
		FROM shipment_for_owner_costs AS t
		GROUP BY t.distance_to
		ORDER BY t.distance_to
		)
	,act_price AS
		(SELECT
			t.distance_to,
			t.price
		FROM last_price
		LEFT JOIN shipment_for_owner_costs AS t ON last_price.date=t.date AND last_price.distance_to=t.distance_to
		ORDER BY t.distance_to
		)

	SELECT
		destinations.id,
		destinations.name,
		destinations.distance,
		destinations.time_route,
		
		CASE
			WHEN coalesce(destinations.special_price,FALSE) = TRUE THEN coalesce(destinations.price,0)
			ELSE
				coalesce(
					coalesce(
						(SELECT act_price.price
						FROM act_price
						WHERE destinations.distance <= act_price.distance_to
						LIMIT 1
						)
					,destinations.price)
				,0)
		END AS price,
		
		destinations.special_price,
		
		replace(replace(st_astext(destinations.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text) AS zone_str,
		replace(replace(st_astext(st_centroid(destinations.zone)), 'POINT('::text, ''::text), ')'::text, ''::text) AS zone_center_str,
		
		price_for_driver
		
	FROM destinations;

ALTER TABLE public.destinations_dialog OWNER TO beton;



-- ******************* update 08/10/2019 13:38:46 ******************
-- View: destination_list_view

-- DROP VIEW destination_list_view;

CREATE OR REPLACE VIEW destination_list_view AS 
	WITH
	last_price AS
		(SELECT
			max(t.date) AS date,
			t.distance_to
		FROM shipment_for_owner_costs AS t
		GROUP BY t.distance_to
		ORDER BY t.distance_to
		)
	,act_price AS
		(SELECT
			t.distance_to,
			t.price
		FROM last_price
		LEFT JOIN shipment_for_owner_costs AS t ON last_price.date=t.date AND last_price.distance_to=t.distance_to
		ORDER BY t.distance_to
		)
	SELECT
		destinations.id,
		destinations.name,
		destinations.distance,
		time5_descr(destinations.time_route) AS time_route,
		CASE
			WHEN coalesce(destinations.special_price,FALSE) = TRUE THEN coalesce(destinations.price,0)
			ELSE
				coalesce(
					coalesce(
						(SELECT act_price.price
						FROM act_price
						WHERE destinations.distance <= act_price.distance_to
						LIMIT 1
						)
					,destinations.price)
				,0)
		END AS price,
		
		destinations.special_price,
		
		destinations.price_for_driver
		
	FROM destinations
	
	ORDER BY destinations.name;

ALTER TABLE destination_list_view
  OWNER TO beton;



-- ******************* update 08/10/2019 13:58:34 ******************
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
		
		CASE
		WHEN sh.destination_id = const_self_ship_dest_id_val() THEN 0
		WHEN dest.price_for_driver IS NOT NULL THEN dest.price_for_driver*shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)
		ELSE
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
			) * shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)
		END AS cost_for_driver
		
	FROM shipments_list sh
	LEFT JOIN destinations AS dest ON dest.id=destination_id
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 08/10/2019 14:14:03 ******************
--DROP VIEW public.vehicle_states_all;
CREATE OR REPLACE VIEW public.vehicle_states_all AS 
	SELECT 
		st.date_time,
		vs.id,
		CASE
		    WHEN st.state <> 'out'::vehicle_states AND st.state <> 'out_from_shift'::vehicle_states AND st.state <> 'shift'::vehicle_states AND st.state <> 'shift_added'::vehicle_states 

			THEN 1
			ELSE 0
		END AS vehicles_count,
		
		vehicles_ref(v) AS vehicles_ref,
		
		/*
		CASE
			WHEN v.vehicle_owner_id IS NULL THEN v.owner
			ELSE v_own.name
		END
		*/
		v_own.name::text AS owner,
		
		drivers_ref(d) AS drivers_ref,
		d.phone_cel::text AS driver_phone_cel,
		
		st.state, 

		CASE 
			--WHEN st.state = 'busy'::vehicle_states AND (st.date_time + (coalesce(dest.time_route,'00:00'::time)*2+constant_vehicle_unload_time())::interval)::timestamp with time zone < CURRENT_TIMESTAMP
				--THEN true
			WHEN st.state = 'busy'::vehicle_states AND (st.date_time + coalesce(dest.time_route::interval,'00:00'::interval))::timestamp with time zone < CURRENT_TIMESTAMP
				THEN true
			
			WHEN st.state = 'left_for_base'::vehicle_states AND (st.date_time +  coalesce(dest.time_route,'00:00'::time)::interval)::timestamp with time zone < CURRENT_TIMESTAMP
				THEN true
			ELSE false
		END AS is_late,

		CASE
			WHEN st.state = 'at_dest'::vehicle_states AND (st.date_time + (coalesce(dest.time_route,'00:00'::time)*1 + constant_vehicle_unload_time())::interval)::timestamp with time zone < CURRENT_TIMESTAMP
				THEN true
			ELSE false
		END AS is_late_at_dest,
		
		CASE
			--shift - no inf
			WHEN st.state = 'shift'::vehicle_states OR st.state = 'shift_added'::vehicle_states
				THEN ''

			-- out_from_shift && out inf=out time
			WHEN st.state = 'out_from_shift'::vehicle_states OR st.state = 'out'::vehicle_states
				THEN time5_descr(st.date_time::time)::text

			--free && assigned inf= time elapsed
			WHEN st.state = 'free'::vehicle_states OR st.state = 'assigned'::vehicle_states
				THEN to_char(CURRENT_TIMESTAMP-st.date_time,'HH24:MI')

			--busy && late inf = -
			--WHEN st.state = 'busy'::vehicle_states AND (st.date_time + (coalesce(dest.time_route,'00:00'::time)*2+constant_vehicle_unload_time())::interval )::timestamp with time zone < CURRENT_TIMESTAMP
				--THEN '-'::text || time5_descr((CURRENT_TIMESTAMP - (st.date_time + (coalesce(dest.time_route,'00:00'::time)*2+constant_vehicle_unload_time())::interval)::timestamp with time zone)::time without time zone)::text
			WHEN st.state = 'busy'::vehicle_states AND (st.date_time + coalesce(dest.time_route,'00:00'::time)+constant_vehicle_unload_time()::interval )::timestamp with time zone < CURRENT_TIMESTAMP
				THEN time5_descr((coalesce(dest.time_route,'00:00'::time)+constant_vehicle_unload_time()::interval )::time without time zone)::text
				
			-- busy not late
			WHEN st.state = 'busy'::vehicle_states
				--THEN time5_descr(((st.date_time + (coalesce(dest.time_route,'00:00'::time)*2+constant_vehicle_unload_time())::interval)::timestamp with time zone - CURRENT_TIMESTAMP)::time without time zone)::text
				THEN time5_descr((coalesce(dest.time_route,'00:00'::time)+constant_vehicle_unload_time()::interval )::time without time zone)::text

			--at dest && late inf=route_time
			WHEN st.state = 'at_dest'::vehicle_states AND (st.date_time + (coalesce(dest.time_route,'00:00'::time)*1+constant_vehicle_unload_time())::interval )::timestamp with time zone < CURRENT_TIMESTAMP
				THEN time5_descr(coalesce(dest.time_route,'00:00'::time))::text

			--at dest NOT late
			WHEN st.state = 'at_dest'::vehicle_states
				THEN time5_descr( ((st.date_time + (coalesce(dest.time_route::interval,'00:00'::interval)+constant_vehicle_unload_time()::interval))::timestamp with time zone - CURRENT_TIMESTAMP)::time without time zone)::text

			--left_for_base && LATE
			WHEN st.state = 'left_for_base'::vehicle_states AND (st.date_time + coalesce(dest.time_route,'00:00'::time)::interval )::timestamp with time zone < CURRENT_TIMESTAMP
				THEN '-'::text || time5_descr((CURRENT_TIMESTAMP - (st.date_time + coalesce(dest.time_route,'00:00'::time)::interval)::timestamp with time zone)::time without time zone)::text

			--left_for_base NOT late
			WHEN st.state = 'left_for_base'::vehicle_states
				THEN time5_descr( ((st.date_time + coalesce(dest.time_route,'00:00'::time)::interval)::timestamp with time zone - CURRENT_TIMESTAMP)::time without time zone)::text
		    
			ELSE ''
		    
		END AS inf_on_return, 
		
		v.load_capacity,
		(SELECT COUNT(*)
		FROM shipments
		WHERE (shipments.vehicle_schedule_id = vs.id AND shipments.shipped)
		) AS runs,

		(SELECT 
			(now()-(tr.period+AGE(now(),now() AT TIME ZONE 'UTC')) )>constant_no_tracker_signal_warn_interval()
			FROM car_tracking AS tr
			WHERE tr.car_id=v.tracker_id
			ORDER BY tr.period DESC LIMIT 1
		) AS tracker_no_data,
		
		(v.tracker_id IS NULL OR v.tracker_id='') AS no_tracker,
		
		vs.schedule_date,
		
		vehicle_schedules_ref(vs,v,d) AS vehicle_schedules_ref,
		
		d.phone_cel AS driver_tel
		
	FROM vehicle_schedules vs
	
	LEFT JOIN drivers d ON d.id = vs.driver_id
	LEFT JOIN vehicles v ON v.id = vs.vehicle_id
	
	
	LEFT JOIN vehicle_schedule_states st ON
		st.id = (SELECT vehicle_schedule_states.id 
			FROM vehicle_schedule_states
			WHERE vehicle_schedule_states.schedule_id = vs.id
			ORDER BY vehicle_schedule_states.date_time DESC NULLS LAST
			LIMIT 1
		)
	
	LEFT JOIN shipments AS sh ON sh.id=st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id		
	LEFT JOIN destinations AS dest ON dest.id=o.destination_id
	LEFT JOIN vehicle_owners AS v_own ON v_own.id=v.vehicle_owner_id
	;		
	--WHERE vs.schedule_date=in_date


ALTER TABLE public.vehicle_states_all OWNER TO beton;



-- ******************* update 08/10/2019 14:15:00 ******************
-- Function: public.vehicle_last_states(date)

 DROP FUNCTION public.vehicle_last_states(date);

CREATE OR REPLACE FUNCTION public.vehicle_last_states(IN in_date date)
  RETURNS TABLE(
	date_time timestamp,
	id int,
	vehicles_count int,	
	vehicles_ref JSON,	
	owner text,	
	drivers_ref JSON,
	driver_phone_cel text,	
	state vehicle_states, 
	is_late boolean,
	is_late_at_dest boolean,
	inf_on_return text, 	
	load_capacity double precision,
	runs bigint,
	tracker_no_data boolean,	
	no_tracker boolean,	
	schedule_date date,
	vehicle_schedules_ref json,
	driver_tel text
  ) AS
$BODY$
	--*****************************
	WITH states_q AS (SELECT * FROM vehicle_states_all WHERE schedule_date=$1)
	--assigned
	(SELECT *
	FROM states_q
	WHERE  state='assigned'::vehicle_states
	ORDER BY CURRENT_TIMESTAMP-date_time DESC)

	UNION ALL

	--free
	(SELECT *	
	FROM states_q
	WHERE state='free'::vehicle_states
	ORDER BY CURRENT_TIMESTAMP-date_time DESC)

	UNION ALL

	--late
	(SELECT *
	FROM states_q
	WHERE is_late
	ORDER BY CURRENT_TIMESTAMP-date_time DESC)


	UNION ALL

	--busy && at_dest(late/not late) && left_for_base
	(SELECT *
	FROM states_q
	WHERE (state='busy'::vehicle_states OR state='at_dest'::vehicle_states OR state='left_for_base'::vehicle_states)
		AND (NOT is_late)
	ORDER BY inf_on_return ASC)


	UNION ALL

	--shift && shift_added
	(SELECT *		
	FROM states_q
	WHERE  schedule_date=$1 AND (state='shift'::vehicle_states OR state='shift_added'::vehicle_states)
	ORDER BY vehicles_ref->>'descr')

	UNION ALL

	--out
	(SELECT *
	FROM states_q
	WHERE (state='out_from_shift'::vehicle_states OR state='out'::vehicle_states)
	ORDER BY inf_on_return
	);
	
	--*****************************
$BODY$
  LANGUAGE sql VOLATILE COST 100 ROWS 50;
ALTER FUNCTION public.vehicle_last_states(date) OWNER TO beton;



-- ******************* update 08/10/2019 15:57:05 ******************
-- View: public.make_orders_for_lab_list

-- DROP VIEW public.make_orders_for_lab_list;

CREATE OR REPLACE VIEW public.make_orders_for_lab_list AS 
	SELECT
		o.*,
		(need_t.need_cnt > 0) AS is_needed
	FROM orders_make_list o
	LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (o.concrete_types_ref->'keys'->>'id')::int
	WHERE o.date_time >= get_shift_start(now()::timestamp without time zone) AND o.date_time <= get_shift_end(get_shift_start(now()::timestamp without time zone));

ALTER TABLE public.make_orders_for_lab_list OWNER TO beton;



-- ******************* update 08/10/2019 16:00:04 ******************
-- View: public.make_orders_for_lab_list

 DROP VIEW public.make_orders_for_lab_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_list AS 
	SELECT
		o.*,
		(need_t.need_cnt > 0) AS is_needed
	FROM orders_make_list o
	LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (o.concrete_types_ref->'keys'->>'id')::int
	WHERE o.date_time >= get_shift_start(now()::timestamp without time zone) AND o.date_time <= get_shift_end(get_shift_start(now()::timestamp without time zone));

ALTER TABLE public.orders_make_for_lab_list OWNER TO beton;



-- ******************* update 08/10/2019 16:15:17 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'30017',
		'Order_Controller',
		'get_make_orders_for_lab_form',
		'OrderMakeForLabList',
		'Формы',
		'Заявки онлайн (лаборант)',
		FALSE
		);
	

-- ******************* update 08/10/2019 16:50:17 ******************
-- View: public.orders_make_for_lab_list

-- DROP VIEW public.orders_make_for_lab_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_list AS 
	SELECT
		o.*,
		(need_t.need_cnt > 0) AS is_needed
	FROM orders_make_list o
	LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (o.concrete_types_ref->'keys'->>'id')::int
	WHERE o.date_time >= get_shift_start(now()::timestamp without time zone)
		AND o.date_time <= get_shift_end(get_shift_start(now()::timestamp without time zone))
	ORDER BY o.date_time;
ALTER TABLE public.orders_make_for_lab_list OWNER TO beton;



-- ******************* update 08/10/2019 16:51:14 ******************
-- View: public.orders_make_for_lab_list

-- DROP VIEW public.orders_make_for_lab_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_list AS 
	SELECT
		o.*,
		(need_t.need_cnt > 0) AS is_needed
	FROM orders_make_list o
	LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (o.concrete_types_ref->'keys'->>'id')::int
	WHERE o.date_time BETWEEN
		get_shift_start(now()::timestamp without time zone)
		AND get_shift_end(get_shift_start(now()::timestamp without time zone))
	ORDER BY o.date_time;
ALTER TABLE public.orders_make_for_lab_list OWNER TO beton;



-- ******************* update 22/10/2019 10:29:44 ******************
-- View: ast_calls_current

 DROP VIEW ast_calls_current;

CREATE OR REPLACE VIEW ast_calls_current AS 
	SELECT DISTINCT ON (ast.ext)
		ast.unique_id,
		ast.ext,
				
		CASE
			WHEN clt.tel IS NOT NULL THEN clt.tel
			WHEN substr(ast.caller_id_num,1,1)='+' THEN '8'||substr(ast.caller_id_num,2)			
			ELSE ast.caller_id_num::text
		END AS contact_tel,
		
		--backward compatibility
		CASE
			WHEN clt.tel IS NOT NULL THEN clt.tel
			WHEN substr(ast.caller_id_num,1,1)='+' THEN '8'||substr(ast.caller_id_num,2)			
			ELSE ast.caller_id_num::text
		END AS num,
		
		ast.dt AS ring_time,
		ast.start_time AS answer_time,
		ast.end_time AS hangup_time,
		ast.client_id,
		clients_ref(cl) AS clients_ref,
		cl.name AS client_descr,
		cl.client_kind,
		get_client_kinds_descr(cl.client_kind) AS client_kind_descr,
		ast.manager_comment,
		ast.informed,
		clt.name AS contact_name,
		cld.debt,
		man.name AS client_manager_descr,
		client_types_ref(ctp) AS client_types_ref,
		client_come_from_ref(ccf) AS client_come_from_ref
		
		
   FROM ast_calls ast
     LEFT JOIN clients cl ON cl.id = ast.client_id
     LEFT JOIN users man ON cl.manager_id = man.id
     LEFT JOIN client_tels clt ON clt.client_id = ast.client_id AND (clt.tel=ast.caller_id_num OR clt.tel::text = format_cel_phone("right"(ast.caller_id_num::text, 10)))
     LEFT JOIN client_debts cld ON cld.client_id = ast.client_id
     LEFT JOIN client_types ctp ON ctp.id = cl.client_type_id
     LEFT JOIN client_come_from ccf ON ccf.id = cl.client_come_from_id
  WHERE
  	ast.end_time IS NULL
  	AND char_length(ast.ext::text) <> char_length(ast.caller_id_num::text)
  	AND ast.caller_id_num::text <> ''::text
  	AND ( (ast.start_time IS NULL AND ast.dt::date=now()::date) OR (ast.start_time IS NOT NULL AND ast.start_time::date=now()::date) )
  ORDER BY ast.ext, ast.dt DESC;

ALTER TABLE ast_calls_current
  OWNER TO beton;



-- ******************* update 22/10/2019 12:34:03 ******************
--DROP FUNCTION material_fact_consumptions_add_vehicle(text)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_vehicle(text)
RETURNS int as $$
DECLARE
	v_vehicle_id int;
BEGIN
	v_vehicle_id = NULL;
	SELECT vehicle_id INTO v_vehicle_id FROM vehicle_map_to_production WHERE production_descr = $1;
	IF NOT FOUND THEN
		SELECT id FROM vehicles INTO v_vehicle_id WHERE plate=$1 OR (length($1)=3 AND length(plate)=6 AND '%'||plate||'%' LIKE $1);
		
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


-- ******************* update 24/10/2019 13:16:38 ******************
-- View: public.orders_make_for_lab_period_list

-- DROP VIEW public.orders_make_for_lab_period_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_period_list AS 
	SELECT
		o.*,
		(need_t.need_cnt > 0) AS is_needed
	FROM orders_make_list o
	LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (o.concrete_types_ref->'keys'->>'id')::int
	ORDER BY o.date_time;
ALTER TABLE public.orders_make_for_lab_period_list OWNER TO beton;



-- ******************* update 30/10/2019 09:52:34 ******************

					ALTER TYPE reg_types ADD VALUE 'material_fact';
					ALTER TYPE reg_types ADD VALUE 'cement';
	/* function */
	CREATE OR REPLACE FUNCTION enum_reg_types_val(reg_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='material'::reg_types AND $2='ru'::locales THEN 'Учет материалов'
		WHEN $1='material_fact'::reg_types AND $2='ru'::locales THEN 'Учет материалов по факту'
		WHEN $1='cement'::reg_types AND $2='ru'::locales THEN 'Учет цемента'
		WHEN $1='material_consumption'::reg_types AND $2='ru'::locales THEN 'Расход материалов'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_reg_types_val(reg_types,locales) OWNER TO beton;		
		

-- ******************* update 30/10/2019 09:57:49 ******************

		CREATE TABLE cement_silos
		(id serial NOT NULL,production_site_id int REFERENCES production_sites(id),production_descr  varchar(100) NOT NULL,name  varchar(100) NOT NULL,weigh_app_name  varchar(100) NOT NULL,CONSTRAINT cement_silos_pkey PRIMARY KEY (id)
		);
		ALTER TABLE cement_silos OWNER TO beton;



-- ******************* update 30/10/2019 10:00:05 ******************

		ALTER TABLE doc_material_procurements ADD COLUMN cement_silos_id int REFERENCES cement_silos(id);



-- ******************* update 30/10/2019 10:03:39 ******************
-- Function: public.cement_silos_ref(cement_silos)

-- DROP FUNCTION public.cement_silos_ref(cement_silos);

CREATE OR REPLACE FUNCTION public.cement_silos_ref(cement_silos)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','cement_silos'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silos_ref(cement_silos)
  OWNER TO beton;



-- ******************* update 30/10/2019 10:03:53 ******************
-- View: doc_material_procurements_list

 DROP VIEW doc_material_procurements_list;

CREATE OR REPLACE VIEW doc_material_procurements_list AS 
 SELECT
 	doc.id,
	doc.number,
	doc.date_time,
	doc.processed,
	doc.supplier_id,
	suppliers_ref(sup) AS suppliers_ref,
	doc.carrier_id,
	suppliers_ref(car) AS carriers_ref,
	doc.material_id,
	materials_ref(mat) AS materials_ref,
	doc.cement_silos_id,
	cement_silos_ref(silo) AS cement_silos_ref,
	doc.driver,
	doc.vehicle_plate,
	doc.quant_gross,
	doc.quant_net
   FROM doc_material_procurements doc
     LEFT JOIN suppliers sup ON sup.id = doc.supplier_id
     LEFT JOIN suppliers car ON car.id = doc.carrier_id
     LEFT JOIN raw_materials mat ON mat.id = doc.material_id
     LEFT JOIN cement_silos silo ON silo.id = doc.cement_silos_id
  ORDER BY doc.date_time DESC;

ALTER TABLE doc_material_procurements_list
  OWNER TO beton;



-- ******************* update 30/10/2019 14:39:15 ******************
-- VIEW: cement_silos_list

--DROP VIEW cement_silos_list;

CREATE OR REPLACE VIEW cement_silos_list AS
	SELECT
		t.*,
		production_sites_ref(pst) AS production_sites_ref
	FROM cement_silos AS t
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_list OWNER TO beton;


-- ******************* update 30/10/2019 14:40:22 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10037',
		'CementSilo_Controller',
		'get_list',
		'CementSiloList',
		'Справочники',
		'Соответствие силосов',
		FALSE
		);
	

-- ******************* update 31/10/2019 10:57:18 ******************
		--constant get value
		CREATE OR REPLACE FUNCTION const_cement_material_val()
		RETURNS json AS
		$BODY$
			SELECT materials_ref(
				(SELECT
					ROW(raw_materials.*)::raw_materials
				FROM raw_materials
				WHERE id = (SELECT val FROM const_cement_material LIMIT 1) LIMIT 1)
				) AS val ;			
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_cement_material_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_cement_material_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_cement_material SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_cement_material_set_val(Int) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_cement_material_view AS
		SELECT
			'cement_material'::text AS id
			,t.name
			,t.descr
		,const_cement_material_val()::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_cement_material AS t
		;
		ALTER VIEW const_cement_material_view OWNER TO beton;
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
		FROM const_low_efficiency_tel_list_view
		UNION ALL
		SELECT *
		FROM const_material_closed_balance_date_view
		UNION ALL
		SELECT *
		FROM const_cement_material_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	


-- ******************* update 31/10/2019 11:01:56 ******************
-- Function: public.doc_material_procurements_process()

-- DROP FUNCTION public.doc_material_procurements_process();

CREATE OR REPLACE FUNCTION public.doc_material_procurements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_act ra_materials%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER') AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN					
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;

		--register actions ra_materials
		reg_act.date_time		= NEW.date_time;
		reg_act.deb			= true;
		reg_act.doc_type  		= 'material_procurement'::doc_types;
		reg_act.doc_id  		= NEW.id;
		reg_act.material_id		= NEW.material_id;
		reg_act.quant			= NEW.quant_net;
		PERFORM ra_materials_add_act(reg_act);	
		
		IF NEW.material_id <> (const_cement_material_val()->'keys'->>'id')::int THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= true;
			reg_material_facts.doc_type  		= 'material_procurement'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= NEW.quant_net;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.cement_silos_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= true;
			reg_cement.doc_type  		= 'material_procurement'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.quant_net;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
				
		RETURN NEW;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);

		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;
						
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		RETURN OLD;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--detail tables
		
		--register actions										
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);
		
		--log
		PERFORM doc_log_delete('material_procurement'::doc_types,OLD.id);
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_material_procurements_process()
  OWNER TO beton;



-- ******************* update 31/10/2019 11:02:50 ******************
-- Function: public.doc_material_procurements_process()

-- DROP FUNCTION public.doc_material_procurements_process();

CREATE OR REPLACE FUNCTION public.doc_material_procurements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_act ra_materials%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER') AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN					
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;

		--register actions ra_materials
		reg_act.date_time		= NEW.date_time;
		reg_act.deb			= true;
		reg_act.doc_type  		= 'material_procurement'::doc_types;
		reg_act.doc_id  		= NEW.id;
		reg_act.material_id		= NEW.material_id;
		reg_act.quant			= NEW.quant_net;
		PERFORM ra_materials_add_act(reg_act);	
		
		IF NEW.material_id <> (const_cement_material_val()->'keys'->>'id')::int THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= true;
			reg_material_facts.doc_type  		= 'material_procurement'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= NEW.quant_net;
			--PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.cement_silos_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= true;
			reg_cement.doc_type  		= 'material_procurement'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.quant_net;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
				
		RETURN NEW;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);

		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;
						
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		RETURN OLD;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--detail tables
		
		--register actions										
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);
		
		--log
		PERFORM doc_log_delete('material_procurement'::doc_types,OLD.id);
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_material_procurements_process()
  OWNER TO beton;



-- ******************* update 31/10/2019 11:43:45 ******************
-- Function: public.doc_material_procurements_process()

-- DROP FUNCTION public.doc_material_procurements_process();

CREATE OR REPLACE FUNCTION public.doc_material_procurements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_act ra_materials%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER') AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN					
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;

		--register actions ra_materials
		reg_act.date_time		= NEW.date_time;
		reg_act.deb			= true;
		reg_act.doc_type  		= 'material_procurement'::doc_types;
		reg_act.doc_id  		= NEW.id;
		reg_act.material_id		= NEW.material_id;
		reg_act.quant			= NEW.quant_net;
		PERFORM ra_materials_add_act(reg_act);	
		
		IF NEW.material_id <> (const_cement_material_val()->'keys'->>'id')::int THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= true;
			reg_material_facts.doc_type  		= 'material_procurement'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= NEW.quant_net;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.cement_silos_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= true;
			reg_cement.doc_type  		= 'material_procurement'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.quant_net;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
				
		RETURN NEW;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);

		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;
						
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		RETURN OLD;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--detail tables
		
		--register actions										
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);
		
		--log
		PERFORM doc_log_delete('material_procurement'::doc_types,OLD.id);
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_material_procurements_process()
  OWNER TO beton;



-- ******************* update 31/10/2019 11:50:57 ******************
-- Function: public.doc_material_procurements_process()

-- DROP FUNCTION public.doc_material_procurements_process();

CREATE OR REPLACE FUNCTION public.doc_material_procurements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_act ra_materials%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER') AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN					
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;

		--register actions ra_materials
		reg_act.date_time		= NEW.date_time;
		reg_act.deb			= true;
		reg_act.doc_type  		= 'material_procurement'::doc_types;
		reg_act.doc_id  		= NEW.id;
		reg_act.material_id		= NEW.material_id;
		reg_act.quant			= NEW.quant_net;
		PERFORM ra_materials_add_act(reg_act);	
		
		IF NEW.material_id <> (const_cement_material_val()->'keys'->>'id')::int THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= true;
			reg_material_facts.doc_type  		= 'material_procurement'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= NEW.quant_net;
			--PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.cement_silos_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= true;
			reg_cement.doc_type  		= 'material_procurement'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.quant_net;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
				
		RETURN NEW;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);

		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;
						
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		RETURN OLD;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--detail tables
		
		--register actions										
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);
		
		--log
		PERFORM doc_log_delete('material_procurement'::doc_types,OLD.id);
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_material_procurements_process()
  OWNER TO beton;



-- ******************* update 31/10/2019 12:25:18 ******************
﻿-- Function: rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3))

-- DROP FUNCTION rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3));

CREATE OR REPLACE FUNCTION rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3))
  RETURNS void AS
$BODY$
DECLARE
	v_loop_rg_period timestamp;
	v_calc_interval interval;			  			
	CURRENT_BALANCE_DATE_TIME timestamp;
BEGIN
	v_loop_rg_period = rg_period('material_fact'::reg_types,in_date_time);
	v_calc_interval = rg_calc_interval('material_fact'::reg_types);
	LOOP
		UPDATE rg_material_facts
		SET
			quant = quant + in_delta_quant
		WHERE 
			date_time=v_loop_rg_period
			AND material_id = in_material_id;
			
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO rg_material_facts (date_time
				,material_id
				,quant)				
				VALUES (v_loop_rg_period
				,in_material_id
				,in_delta_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE rg_material_facts
				SET
					quant = quant + in_delta_quant
				WHERE date_time = v_loop_rg_period
				AND material_id = in_material_id;
			END;
		END IF;
		v_loop_rg_period = v_loop_rg_period + v_calc_interval;
		IF v_loop_rg_period > in_date_time THEN
			EXIT;  -- exit loop
		END IF;
	END LOOP;
	
	--Current balance
	CURRENT_BALANCE_DATE_TIME = reg_current_balance_time();
	UPDATE rg_material_facts
	SET
		quant = quant + in_delta_quant
	WHERE 
		date_time=CURRENT_BALANCE_DATE_TIME
		AND material_id = in_material_id;
		
	IF NOT FOUND THEN
		BEGIN
			INSERT INTO rg_material_facts (date_time
			,material_id
			,quant)				
			VALUES (CURRENT_BALANCE_DATE_TIME
			,in_material_id
			,in_delta_quant);
		EXCEPTION WHEN OTHERS THEN
			UPDATE rg_material_facts
			SET
				quant = quant + in_delta_quant
			WHERE 
				date_time=CURRENT_BALANCE_DATE_TIME
				AND material_id = in_material_id;
		END;
	END IF;					
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3)) OWNER TO beton;


-- ******************* update 31/10/2019 12:27:52 ******************
﻿-- Function: rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3))

-- DROP FUNCTION rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3));

CREATE OR REPLACE FUNCTION rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3))
  RETURNS void AS
$BODY$
DECLARE
	v_loop_rg_period timestamp;
	v_calc_interval interval;			  			
	CURRENT_BALANCE_DATE_TIME timestamp;
	CALC_DATE_TIME timestamp;
BEGIN
	CALC_DATE_TIME = rg_calc_period('material_fact'::reg_types);
	v_loop_rg_period = rg_period('material_fact'::reg_types,in_date_time);
	v_calc_interval = rg_calc_interval('material_fact'::reg_types);
	LOOP
		UPDATE rg_material_facts
		SET
			quant = quant + in_delta_quant
		WHERE 
			date_time=v_loop_rg_period
			AND material_id = in_material_id;
			
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO rg_material_facts (date_time
				,material_id
				,quant)				
				VALUES (v_loop_rg_period
				,in_material_id
				,in_delta_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE rg_material_facts
				SET
					quant = quant + in_delta_quant
				WHERE date_time = v_loop_rg_period
				AND material_id = in_material_id;
			END;
		END IF;
		v_loop_rg_period = v_loop_rg_period + v_calc_interval;
		IF v_loop_rg_period > CALC_DATE_TIME THEN
			EXIT;  -- exit loop
		END IF;
	END LOOP;
	
	--Current balance
	CURRENT_BALANCE_DATE_TIME = reg_current_balance_time();
	UPDATE rg_material_facts
	SET
		quant = quant + in_delta_quant
	WHERE 
		date_time=CURRENT_BALANCE_DATE_TIME
		AND material_id = in_material_id;
		
	IF NOT FOUND THEN
		BEGIN
			INSERT INTO rg_material_facts (date_time
			,material_id
			,quant)				
			VALUES (CURRENT_BALANCE_DATE_TIME
			,in_material_id
			,in_delta_quant);
		EXCEPTION WHEN OTHERS THEN
			UPDATE rg_material_facts
			SET
				quant = quant + in_delta_quant
			WHERE 
				date_time=CURRENT_BALANCE_DATE_TIME
				AND material_id = in_material_id;
		END;
	END IF;					
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION rg_material_facts_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3)) OWNER TO beton;


-- ******************* update 31/10/2019 12:56:47 ******************
-- Function: public.doc_material_procurements_process()

-- DROP FUNCTION public.doc_material_procurements_process();

CREATE OR REPLACE FUNCTION public.doc_material_procurements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_act ra_materials%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER') AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN					
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;

		--register actions ra_materials
		reg_act.date_time		= NEW.date_time;
		reg_act.deb			= true;
		reg_act.doc_type  		= 'material_procurement'::doc_types;
		reg_act.doc_id  		= NEW.id;
		reg_act.material_id		= NEW.material_id;
		reg_act.quant			= NEW.quant_net;
		PERFORM ra_materials_add_act(reg_act);	
		
		IF NEW.material_id <> (const_cement_material_val()->'keys'->>'id')::int THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= true;
			reg_material_facts.doc_type  		= 'material_procurement'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= NEW.quant_net;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.cement_silos_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= true;
			reg_cement.doc_type  		= 'material_procurement'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.quant_net;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
				
		RETURN NEW;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);

		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;
						
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		RETURN OLD;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--detail tables
		
		--register actions										
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);
		
		--log
		PERFORM doc_log_delete('material_procurement'::doc_types,OLD.id);
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_material_procurements_process()
  OWNER TO beton;



-- ******************* update 31/10/2019 14:58:24 ******************
﻿-- Function: rg_cements_update_periods(in_date_time timestamp, in_delta_quant numeric(19,3))

-- DROP FUNCTION rg_cements_update_periods(in_date_time timestamp, in_delta_quant numeric(19,3));

CREATE OR REPLACE FUNCTION rg_cements_update_periods(in_date_time timestamp, in_delta_quant numeric(19,3))
  RETURNS void AS
$BODY$
DECLARE
	v_loop_rg_period timestamp;
	v_calc_interval interval;			  			
	CURRENT_BALANCE_DATE_TIME timestamp;
	CALC_DATE_TIME timestamp;
BEGIN
	CALC_DATE_TIME = rg_calc_period('cement'::reg_types);
	v_loop_rg_period = rg_period('cement'::reg_types,in_date_time);
	v_calc_interval = rg_calc_interval('cement'::reg_types);
	LOOP
		UPDATE rg_cements
		SET
			quant = quant + in_delta_quant
		WHERE 
			date_time=v_loop_rg_period;
			
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO rg_cements (date_time
				,quant)				
				VALUES (v_loop_rg_period
				,in_delta_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE rg_cements
				SET
					quant = quant + in_delta_quant
				WHERE date_time = v_loop_rg_period;
			END;
		END IF;
		v_loop_rg_period = v_loop_rg_period + v_calc_interval;
		IF v_loop_rg_period > CALC_DATE_TIME THEN
			EXIT;  -- exit loop
		END IF;
	END LOOP;
	
	--Current balance
	CURRENT_BALANCE_DATE_TIME = reg_current_balance_time();
	UPDATE rg_cements
	SET
		quant = quant + in_delta_quant
	WHERE 
		date_time=CURRENT_BALANCE_DATE_TIME;
		
	IF NOT FOUND THEN
		BEGIN
			INSERT INTO rg_cements (date_time
			,quant)				
			VALUES (CURRENT_BALANCE_DATE_TIME
			,in_delta_quant);
		EXCEPTION WHEN OTHERS THEN
			UPDATE rg_cements
			SET
				quant = quant + in_delta_quant
			WHERE 
				date_time=CURRENT_BALANCE_DATE_TIME;
		END;
	END IF;					
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION rg_cements_update_periods(in_date_time timestamp, in_delta_quant numeric(19,3)) OWNER TO beton;


-- ******************* update 31/10/2019 15:05:59 ******************
﻿-- Function: rg_materials_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3))

-- DROP FUNCTION rg_materials_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3));

CREATE OR REPLACE FUNCTION rg_materials_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3))
  RETURNS void AS
$BODY$
DECLARE
	v_loop_rg_period timestamp;
	v_calc_interval interval;			  			
	CURRENT_BALANCE_DATE_TIME timestamp;
	CALC_DATE_TIME timestamp;
BEGIN
	CALC_DATE_TIME = rg_calc_period('material'::reg_types);
	v_loop_rg_period = rg_period('material'::reg_types,in_date_time);
	v_calc_interval = rg_calc_interval('material'::reg_types);
	LOOP
		UPDATE rg_materials
		SET
			quant = quant + in_delta_quant
		WHERE 
			date_time=v_loop_rg_period
			AND material_id = in_material_id;
			
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO rg_materials (date_time
				,material_id
				,quant)				
				VALUES (v_loop_rg_period
				,in_material_id
				,in_delta_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE rg_materials
				SET
					quant = quant + in_delta_quant
				WHERE date_time = v_loop_rg_period
				AND material_id = in_material_id;
			END;
		END IF;
		v_loop_rg_period = v_loop_rg_period + v_calc_interval;
		IF v_loop_rg_period > CALC_DATE_TIME THEN
			EXIT;  -- exit loop
		END IF;
	END LOOP;
	
	--Current balance
	CURRENT_BALANCE_DATE_TIME = reg_current_balance_time();
	UPDATE rg_materials
	SET
		quant = quant + in_delta_quant
	WHERE 
		date_time=CURRENT_BALANCE_DATE_TIME
		AND material_id = in_material_id;
		
	IF NOT FOUND THEN
		BEGIN
			INSERT INTO rg_materials (date_time
			,material_id
			,quant)				
			VALUES (CURRENT_BALANCE_DATE_TIME
			,in_material_id
			,in_delta_quant);
		EXCEPTION WHEN OTHERS THEN
			UPDATE rg_materials
			SET
				quant = quant + in_delta_quant
			WHERE 
				date_time=CURRENT_BALANCE_DATE_TIME
				AND material_id = in_material_id;
		END;
	END IF;					
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION rg_materials_update_periods(in_date_time timestamp, in_material_id int, in_delta_quant numeric(19,3)) OWNER TO beton;


-- ******************* update 01/11/2019 13:34:39 ******************

		ALTER TABLE vehicles ADD COLUMN vehicle_owners jsonb;



-- ******************* update 01/11/2019 13:36:06 ******************
-- View: public.vehicles_dialog

 DROP VIEW public.vehicles_dialog;

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
			ELSE ( SELECT tr.recieved_dt + (now() - timezone('utc'::text, now())::timestamp with time zone)
			FROM car_tracking tr
			WHERE tr.car_id::text = v.tracker_id::text
			ORDER BY tr.period DESC
			LIMIT 1)
		END AS tracker_last_dt,
		drivers_ref(dr.*) AS drivers_ref,
		
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		v.vehicle_owners,
		v.vehicle_owner_id
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate
	;

ALTER TABLE public.vehicles_dialog
  OWNER TO beton;



-- ******************* update 01/11/2019 13:36:16 ******************
-- View: public.vehicles_dialog

 DROP VIEW public.vehicles_dialog;

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
			ELSE ( SELECT tr.recieved_dt + (now() - timezone('utc'::text, now())::timestamp with time zone)
			FROM car_tracking tr
			WHERE tr.car_id::text = v.tracker_id::text
			ORDER BY tr.period DESC
			LIMIT 1)
		END AS tracker_last_dt,
		drivers_ref(dr.*) AS drivers_ref,
		v.vehicle_owners,
		vehicle_owners_ref(v_own) AS vehicle_owners_ref,		
		v.vehicle_owner_id
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate
	;

ALTER TABLE public.vehicles_dialog
  OWNER TO beton;



-- ******************* update 01/11/2019 14:58:10 ******************
﻿-- Function: vehicle_owner_on_date(in_val JSONB,in_dt timestamp)

-- DROP FUNCTION vehicle_owner_on_date(in_val JSONB,in_dt timestamp);

CREATE OR REPLACE FUNCTION vehicle_owner_on_date(in_val JSONB,in_dt timestamp)
  RETURNS jsonb AS
$$
	SELECT 
		s.r->'fields'->'owner'
	FROM
	(SELECT jsonb_array_elements(in_val->'rows') As r) AS s
	WHERE (s.r->'fields'->>'dt_from')::timestamp with time zone<=in_dt
	ORDER BY (s.r->'fields'->>'dt_from')::timestamp with time zone DESC
	LIMIT 1;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION vehicle_owner_on_date(in_val JSONB,in_dt timestamp) OWNER TO beton;


-- ******************* update 01/11/2019 15:35:29 ******************
﻿-- Function: sms_pump_order_del(in_order_id int)

-- DROP FUNCTION sms_pump_order_del(in_order_id int);

CREATE OR REPLACE FUNCTION sms_pump_order_del(in_order_id int)
  RETURNS TABLE(
  	phone_cel text,
  	message text  	
  ) AS
$$
	SELECT
		sub.r->'fields'->>'tel' AS tel,
		sub.message AS message
	FROM
	(
	SELECT
		jsonb_array_elements(pvh.phone_cels->'rows') AS r,
		sms_templates_text(
			ARRAY[
				format('("quant","%s")'::text, o.quant::text)::template_value,
				format('("date","%s")'::text, date5_descr(o.date_time::date)::text)::template_value,
				format('("time","%s")'::text, time5_descr(o.date_time::time without time zone)::text)::template_value,
				format('("date","%s")'::text, date8_descr(o.date_time::date)::text)::template_value,
				format('("dest","%s")'::text, dest.name::text)::template_value,
				format('("concrete","%s")'::text, ct.name::text)::template_value,
				format('("client","%s")'::text, cl.name::text)::template_value,
				format('("name","%s")'::text, o.descr)::template_value,
				format('("tel","%s")'::text,format_cel_phone(o.phone_cel::text))::template_value, format('("car","%s")'::text,
				vh.plate::text)::template_value
			],
			( SELECT t.pattern
			FROM sms_patterns t
			WHERE t.sms_type = 'order_for_pump_del'::sms_types AND t.lang_id = 1
			)
		) AS message
	
	FROM orders o
		LEFT JOIN concrete_types ct ON ct.id = o.concrete_type_id
		LEFT JOIN destinations dest ON dest.id = o.destination_id
		LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
		LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
		LEFT JOIN clients cl ON cl.id = o.client_id
	WHERE o.id=in_order_id
	) AS sub;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION sms_pump_order_del(in_order_id int) OWNER TO beton;


-- ******************* update 01/11/2019 15:38:00 ******************
﻿-- Function: sms_pump_order_ins(in_order_id int)

-- DROP FUNCTION sms_pump_order_ins(in_order_id int);

CREATE OR REPLACE FUNCTION sms_pump_order_ins(in_order_id int)
  RETURNS TABLE(
  	phone_cel text,
  	message text  	
  ) AS
$$
	SELECT
		sub.r->'fields'->>'tel' AS tel,
		sub.message AS message
	FROM
	(
	SELECT
		jsonb_array_elements(pvh.phone_cels->'rows') AS r,
		sms_templates_text(
			ARRAY[
		    		format('("quant","%s")'::text, o.quant::text)::template_value,
		    		format('("date","%s")'::text, date5_descr(o.date_time::date)::text)::template_value,
		    		format('("time","%s")'::text, time5_descr(o.date_time::time without time zone)::text)::template_value,
		    		format('("date","%s")'::text, date8_descr(o.date_time::date)::text)::template_value,
		    		format('("dest","%s")'::text, dest.name::text)::template_value,
		    		format('("concrete","%s")'::text, ct.name::text)::template_value,
		    		format('("client","%s")'::text, cl.name::text)::template_value,
		    		format('("name","%s")'::text, o.descr)::template_value,
		    		format('("tel","%s")'::text,format_cel_phone(o.phone_cel::text))::template_value,
		    		format('("car","%s")'::text, vh.plate::text)::template_value
			],
			( SELECT t.pattern
			FROM sms_patterns t
			WHERE t.sms_type = 'order_for_pump_ins'::sms_types AND t.lang_id = 1
			)
		) AS message
	
	FROM orders o
		LEFT JOIN concrete_types ct ON ct.id = o.concrete_type_id
		LEFT JOIN destinations dest ON dest.id = o.destination_id
		LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
		LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
		LEFT JOIN clients cl ON cl.id = o.client_id
	WHERE o.id=in_order_id
	) AS sub;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION sms_pump_order_ins(in_order_id int) OWNER TO beton;


-- ******************* update 01/11/2019 15:38:26 ******************
﻿-- Function: sms_pump_order_ins(in_order_id int)

-- DROP FUNCTION sms_pump_order_ins(in_order_id int);

CREATE OR REPLACE FUNCTION sms_pump_order_ins(in_order_id int)
  RETURNS TABLE(
  	phone_cel text,
  	message text  	
  ) AS
$$
	SELECT
		sub.r->'fields'->>'tel' AS tel,
		sub.message AS message
	FROM
	(
	SELECT
		jsonb_array_elements(pvh.phone_cels->'rows') AS r,
		sms_templates_text(
			ARRAY[
		    		format('("quant","%s")'::text, o.quant::text)::template_value,
		    		format('("date","%s")'::text, date5_descr(o.date_time::date)::text)::template_value,
		    		format('("time","%s")'::text, time5_descr(o.date_time::time without time zone)::text)::template_value,
		    		format('("date","%s")'::text, date8_descr(o.date_time::date)::text)::template_value,
		    		format('("dest","%s")'::text, dest.name::text)::template_value,
		    		format('("concrete","%s")'::text, ct.name::text)::template_value,
		    		format('("client","%s")'::text, cl.name::text)::template_value,
		    		format('("name","%s")'::text, o.descr)::template_value,
		    		format('("tel","%s")'::text,format_cel_phone(o.phone_cel::text))::template_value,
		    		format('("car","%s")'::text, vh.plate::text)::template_value
			],
			( SELECT t.pattern
			FROM sms_patterns t
			WHERE t.sms_type = 'order_for_pump_ins'::sms_types AND t.lang_id = 1
			)
		) AS message
	
	FROM orders o
		LEFT JOIN concrete_types ct ON ct.id = o.concrete_type_id
		LEFT JOIN destinations dest ON dest.id = o.destination_id
		LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
		LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
		LEFT JOIN clients cl ON cl.id = o.client_id
	WHERE o.id=in_order_id
	) AS sub;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION sms_pump_order_ins(in_order_id int) OWNER TO beton;


-- ******************* update 01/11/2019 15:40:02 ******************
﻿-- Function: sms_pump_order_upd(in_order_id int)

-- DROP FUNCTION sms_pump_order_upd(in_order_id int);

CREATE OR REPLACE FUNCTION sms_pump_order_upd(in_order_id int)
  RETURNS TABLE(
  	phone_cel text,
  	message text  	
  ) AS
$$
	SELECT
		sub.r->'fields'->>'tel' AS tel,
		sub.message AS message
	FROM
	(
	SELECT
		jsonb_array_elements(pvh.phone_cels->'rows') AS r,
		sms_templates_text(
			ARRAY[
		    		format('("quant","%s")'::text, o.quant::text)::template_value,
		    		format('("date","%s")'::text, date5_descr(o.date_time::date)::text)::template_value,
		    		format('("time","%s")'::text, time5_descr(o.date_time::time without time zone)::text)::template_value,
		    		format('("date","%s")'::text, date8_descr(o.date_time::date)::text)::template_value,
		    		format('("dest","%s")'::text, dest.name::text)::template_value,
		    		format('("concrete","%s")'::text, ct.name::text)::template_value,
		    		format('("client","%s")'::text, cl.name::text)::template_value,
		    		format('("name","%s")'::text, o.descr)::template_value,
		    		format('("tel","%s")'::text, format_cel_phone(o.phone_cel::text))::template_value,
		    		format('("car","%s")'::text, vh.plate::text)::template_value
			],
			( SELECT t.pattern
			FROM sms_patterns t
			WHERE t.sms_type = 'order_for_pump_upd'::sms_types AND t.lang_id = 1
			)
		) AS message
	
	FROM orders o
		LEFT JOIN concrete_types ct ON ct.id = o.concrete_type_id
		LEFT JOIN destinations dest ON dest.id = o.destination_id
		LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
		LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
		LEFT JOIN clients cl ON cl.id = o.client_id
	WHERE o.id=in_order_id
	) AS sub;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION sms_pump_order_upd(in_order_id int) OWNER TO beton;


-- ******************* update 05/11/2019 11:34:30 ******************

		ALTER TABLE cement_silos ADD COLUMN load_capacity  numeric(19,4);



-- ******************* update 06/11/2019 07:02:00 ******************
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
		
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		vehicle_owner_on_date(v.vehicle_owners,sh.date_time) AS vehicle_owners_ref,
		
		sh.acc_comment,
		sh.acc_comment_shipment,
		--v_own.id AS vehicle_owner_id,
		((vehicle_owner_on_date(v.vehicle_owners,sh.date_time))->'keys'->>'id')::int AS vehicle_owner_id,
		
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



-- ******************* update 06/11/2019 07:02:04 ******************
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
		
		CASE
		WHEN sh.destination_id = const_self_ship_dest_id_val() THEN 0
		WHEN dest.price_for_driver IS NOT NULL THEN dest.price_for_driver*shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)
		ELSE
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
			) * shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)
		END AS cost_for_driver
		
	FROM shipments_list sh
	LEFT JOIN destinations AS dest ON dest.id=destination_id
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 06/11/2019 07:02:06 ******************
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



-- ******************* update 06/11/2019 15:06:14 ******************

		ALTER TABLE pump_vehicles ADD COLUMN pump_prices jsonb;



-- ******************* update 06/11/2019 15:13:51 ******************
-- VIEW: cement_silos_list

DROP VIEW cement_silos_list;

CREATE OR REPLACE VIEW cement_silos_list AS
	SELECT
		t.*,
		production_sites_ref(pst) AS production_sites_ref
	FROM cement_silos AS t
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_list OWNER TO beton;


-- ******************* update 06/11/2019 15:15:58 ******************
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
		
		pv.phone_cels,
		pv.pump_prices
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_list
  OWNER TO beton;



-- ******************* update 06/11/2019 15:16:44 ******************
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
		
		pv.phone_cels,
		pv.pump_prices
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	WHERE coalesce(pv.deleted,FALSE)=FALSE	
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_work_list
  OWNER TO beton;



-- ******************* update 07/11/2019 10:02:51 ******************
﻿-- Function: pump_vehicle_price_on_date(in_val JSONB,in_dt timestamp)

-- DROP FUNCTION pump_vehicle_price_on_date(in_val JSONB,in_dt timestamp);

CREATE OR REPLACE FUNCTION pump_vehicle_price_on_date(in_val JSONB,in_dt timestamp)
  RETURNS jsonb AS
$$
	SELECT 
		s.r->'fields'->'pump_price'
	FROM
	(SELECT jsonb_array_elements(in_val->'rows') As r) AS s
	WHERE (s.r->'fields'->>'dt_from')::timestamp with time zone<=in_dt
	ORDER BY (s.r->'fields'->>'dt_from')::timestamp with time zone DESC
	LIMIT 1;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION pump_vehicle_price_on_date(in_val JSONB,in_dt timestamp) OWNER TO beton;


-- ******************* update 07/11/2019 12:39:18 ******************
-- VIEW: cement_silos_for_order_list

--DROP VIEW cement_silos_for_order_list;

CREATE OR REPLACE VIEW cement_silos_for_order_list AS
	SELECT
		t.name,
		production_sites_ref(pst) AS production_sites_ref,
		t.load_capacity,
		bal.quant AS balance
		
	FROM cement_silos AS t
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	LEFT JOIN rg_cement_balance(NULL) AS bal ON bal.cement_silos_id=t.id
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_for_order_list OWNER TO beton;


-- ******************* update 07/11/2019 12:55:05 ******************

		ALTER TABLE cement_silos ADD COLUMN invisible bool
			DEFAULT FALSE;



-- ******************* update 07/11/2019 12:55:38 ******************
-- VIEW: cement_silos_list

DROP VIEW cement_silos_list;

CREATE OR REPLACE VIEW cement_silos_list AS
	SELECT
		t.*,
		production_sites_ref(pst) AS production_sites_ref
	FROM cement_silos AS t
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_list OWNER TO beton;


-- ******************* update 07/11/2019 12:56:19 ******************
-- VIEW: cement_silos_for_order_list

--DROP VIEW cement_silos_for_order_list;

CREATE OR REPLACE VIEW cement_silos_for_order_list AS
	SELECT
		t.name,
		production_sites_ref(pst) AS production_sites_ref,
		t.load_capacity,
		bal.quant AS balance
		
	FROM cement_silos AS t	
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	LEFT JOIN rg_cement_balance(NULL) AS bal ON bal.cement_silos_id=t.id
	WHERE coalesce(t.invisible,FALSE)=FALSE
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_for_order_list OWNER TO beton;


-- ******************* update 07/11/2019 14:16:58 ******************
-- VIEW: cement_silos_for_order_list

--DROP VIEW cement_silos_for_order_list;

CREATE OR REPLACE VIEW cement_silos_for_order_list AS
	SELECT
		t.id,
		t.name,
		production_sites_ref(pst) AS production_sites_ref,
		t.load_capacity,
		bal.quant AS balance
		
	FROM cement_silos AS t	
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	LEFT JOIN rg_cement_balance(NULL) AS bal ON bal.cement_silos_id=t.id
	WHERE coalesce(t.invisible,FALSE)=FALSE
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_for_order_list OWNER TO beton;


-- ******************* update 07/11/2019 17:03:10 ******************
-- VIEW: cement_silos_list

DROP VIEW cement_silos_list;

CREATE OR REPLACE VIEW cement_silos_list AS
	SELECT
		t.*,
		production_sites_ref(pst) AS production_sites_ref
	FROM cement_silos AS t
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_list OWNER TO beton;


-- ******************* update 07/11/2019 17:03:43 ******************
-- VIEW: cement_silos_for_order_list

--DROP VIEW cement_silos_for_order_list;

CREATE OR REPLACE VIEW cement_silos_for_order_list AS
	SELECT
		t.id,
		t.name,
		production_sites_ref(pst) AS production_sites_ref,
		t.load_capacity,
		bal.quant AS balance
		
	FROM cement_silos AS t	
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	LEFT JOIN rg_cement_balance(NULL) AS bal ON bal.cement_silos_id=t.id
	WHERE coalesce(t.visible,FALSE)=TRUE
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_for_order_list OWNER TO beton;


-- ******************* update 11/11/2019 08:44:41 ******************
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
		
		CASE
		WHEN sh.destination_id = const_self_ship_dest_id_val() THEN 0
		WHEN dest.price_for_driver IS NOT NULL THEN dest.price_for_driver*shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)
		ELSE
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
			) * shipments_quant_for_cost(sh.quant::numeric,dest.distance::numeric)
		END AS cost_for_driver
		
	FROM shipments_list sh
	LEFT JOIN destinations AS dest ON dest.id=destination_id
	;
	
ALTER VIEW shipments_for_veh_owner_list OWNER TO beton;


-- ******************* update 11/11/2019 08:44:43 ******************
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



-- ******************* update 11/11/2019 09:48:54 ******************
-- VIEW: cement_silo_productions_list

--DROP VIEW cement_silo_productions_list;

CREATE OR REPLACE VIEW cement_silo_productions_list AS
	SELECT
		t.id,
		cement_silos_ref(cs) AS cement_silos_ref,
		t.date_time,
		t.production_vehicle_descr,
		vehicles_ref(vh) AS vehicles_ref,
		t.vehicle_state
		
	FROM cement_silo_productions AS t
	LEFT JOIN cement_silos AS cs ON cs.id=t.cement_silo_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	;
	
ALTER VIEW cement_silo_productions_list OWNER TO beton;


-- ******************* update 11/11/2019 09:58:20 ******************
-- VIEW: cement_silo_productions_list

--DROP VIEW cement_silo_productions_list;

CREATE OR REPLACE VIEW cement_silo_productions_list AS
	SELECT
		t.id,
		cement_silos_ref(cs) AS cement_silos_ref,
		t.date_time,
		t.production_vehicle_descr,
		vehicles_ref(vh) AS vehicles_ref,
		t.vehicle_state
		
	FROM cement_silo_productions AS t
	LEFT JOIN cement_silos AS cs ON cs.id=t.cement_silo_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	ORDER BY cs.name,t.date_time DESC
	;
	
ALTER VIEW cement_silo_productions_list OWNER TO beton;


-- ******************* update 11/11/2019 10:01:02 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10038',
		'CementSiloProduction_Controller',
		'get_list',
		'CementSiloProductionList',
		'Справочники',
		'Производство',
		FALSE
		);
	

-- ******************* update 11/11/2019 12:09:45 ******************
-- Function: public.cement_silo_productions_process()

-- DROP FUNCTION public.shipment_process();

CREATE OR REPLACE FUNCTION public.cement_silo_productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_OP='INSERT' THEN
		--пытаемся определить авто по описанию элкон
		NEW.vehicle_id = vehicles_define_on_production_descr(NEW.vehicle_production_descr);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_productions_process() OWNER TO beton;



-- ******************* update 11/11/2019 12:42:43 ******************
﻿-- Function: vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp)

-- DROP FUNCTION vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp);

CREATE OR REPLACE FUNCTION vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp)
  RETURNS int AS
$$
	-- выбираем из in_production_descr только числа
	-- находим авто с маской %in_production_descr% и назначенное в диапазоне получаса
	SELECT vh.id
	FROM shipments AS sh
	LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
	WHERE
		sh.date_time BETWEEN in_date_time-'40 minutes'::interval AND in_date_time
		AND vh.plate LIKE '%'||regexp_replace(in_production_descr, '\D','','g')||'%'
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp) OWNER TO beton;


-- ******************* update 11/11/2019 12:46:53 ******************

		ALTER TABLE cement_silo_productions ADD COLUMN production_date_time timestampTZ NOT NULL;



-- ******************* update 11/11/2019 12:47:15 ******************
-- VIEW: cement_silo_productions_list

DROP VIEW cement_silo_productions_list;

CREATE OR REPLACE VIEW cement_silo_productions_list AS
	SELECT
		t.id,
		cement_silos_ref(cs) AS cement_silos_ref,
		t.date_time,
		t.production_date_time,
		t.production_vehicle_descr,
		vehicles_ref(vh) AS vehicles_ref,
		t.vehicle_state
		
	FROM cement_silo_productions AS t
	LEFT JOIN cement_silos AS cs ON cs.id=t.cement_silo_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	ORDER BY cs.name,t.date_time DESC
	;
	
ALTER VIEW cement_silo_productions_list OWNER TO beton;


-- ******************* update 11/11/2019 12:49:43 ******************
-- Function: public.cement_silo_productions_process()

-- DROP FUNCTION public.shipment_process();

CREATE OR REPLACE FUNCTION public.cement_silo_productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_OP='INSERT' THEN
		--пытаемся определить авто по описанию элкон
		NEW.vehicle_id = vehicles_define_on_production_descr(NEW.vehicle_production_descr,NEW.production_date_time);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_productions_process() OWNER TO beton;



-- ******************* update 11/11/2019 12:51:23 ******************
-- Function: public.cement_silo_productions_process()

-- DROP FUNCTION public.shipment_process();

CREATE OR REPLACE FUNCTION public.cement_silo_productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_OP='INSERT' THEN
		--пытаемся определить авто по описанию элкон
		NEW.vehicle_id = vehicles_define_on_production_descr(NEW.vehicle_production_descr,NEW.production_date_time);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_productions_process() OWNER TO beton;



-- ******************* update 11/11/2019 12:56:10 ******************
﻿-- Function: vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp)

-- DROP FUNCTION vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp);

CREATE OR REPLACE FUNCTION vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp)
  RETURNS int AS
$$
	-- выбираем из in_production_descr только числа
	-- находим авто с маской %in_production_descr% и назначенное в диапазоне получаса
	SELECT vh.id
	FROM shipments AS sh
	LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
	WHERE
		sh.date_time BETWEEN in_date_time-'60 minutes'::interval AND in_date_time
		AND vh.plate LIKE '%'||regexp_replace(in_production_descr, '\D','','g')||'%'
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE CALLED ON NULL INPUT
  COST 100;
ALTER FUNCTION vehicles_define_on_production_descr(in_production_descr text,in_date_time timestamp) OWNER TO beton;


-- ******************* update 11/11/2019 13:10:37 ******************
-- Function: public.cement_silo_productions_process()

-- DROP FUNCTION public.shipment_process();

CREATE OR REPLACE FUNCTION public.cement_silo_productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_OP='INSERT' THEN
		--пытаемся определить авто по описанию элкон
		NEW.vehicle_id = vehicles_define_on_production_descr(NEW.production_vehicle_descr,NEW.production_date_time);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_productions_process() OWNER TO beton;



-- ******************* update 11/11/2019 13:11:32 ******************
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
ALTER FUNCTION public.cement_silo_productions_process() OWNER TO beton;



-- ******************* update 11/11/2019 13:32:13 ******************
-- VIEW: cement_silos_for_order_list

--DROP VIEW cement_silos_for_order_list;

CREATE OR REPLACE VIEW cement_silos_for_order_list AS
	SELECT
		t.id,
		t.name,
		production_sites_ref(pst) AS production_sites_ref,
		t.load_capacity,
		bal.quant AS balance,
		jsonb_build_object(
			'vehicles_ref',cs_state.vehicles_ref,
			'vehicle_state',cs_state.vehicle_state
		) AS vehicle
		
	FROM cement_silos AS t	
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	LEFT JOIN rg_cement_balance(NULL) AS bal ON bal.cement_silos_id=t.id
	LEFT JOIN
		(SELECT
			cs.cement_silo_id,
			cs.date_time,
			vehicles_ref(vh) AS vehicles_ref,
			cs.vehicle_state
		FROM
			(SELECT cement_silo_id,
				max(date_time) AS date_time
			FROM cement_silo_productions
			GROUP BY cement_silo_id
			) AS m_period
		LEFT JOIN cement_silo_productions AS cs ON cs.cement_silo_id=m_period.cement_silo_id AND cs.date_time=m_period.date_time	
		LEFT JOIN vehicles AS vh ON vh.id=cs.vehicle_id
	) AS cs_state ON cs_state.cement_silo_id = t.id
	
	WHERE coalesce(t.visible,FALSE)=TRUE
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_for_order_list OWNER TO beton;


-- ******************* update 04/12/2019 11:08:15 ******************

		CREATE TABLE elkon_servers
		(id serial NOT NULL,data_base_name  varchar(150) NOT NULL,user_name  varchar(150) NOT NULL,user_password  varchar(150) NOT NULL,host  varchar(150) NOT NULL,port int NOT NULL,CONSTRAINT elkon_servers_pkey PRIMARY KEY (id)
		);
		ALTER TABLE elkon_servers OWNER TO beton;
		

-- ******************* update 04/12/2019 12:00:45 ******************

		CREATE TABLE elkon_log
		(id serial NOT NULL,date_time timestamp NOT NULL,production_site_id int,message text,CONSTRAINT elkon_log_pkey PRIMARY KEY (id)
		);
		ALTER TABLE elkon_log OWNER TO beton;
		

-- ******************* update 05/12/2019 09:21:03 ******************
-- View: public.pump_veh_list

 DROP VIEW public.pump_veh_list CASCADE;

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
			owners.row->'fields'->'owner'
		FROM
		(
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS row
		) AS owners
		ORDER BY owners.row->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,
		
		pv.comment_text,
		
		v.vehicle_owner_id,
		
		pv.phone_cels,
		pv.pump_prices
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_list
  OWNER TO beton;



-- ******************* update 05/12/2019 09:21:45 ******************
-- View: public.pump_veh_work_list

 DROP VIEW public.pump_veh_work_list;
-- CASCADE;

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
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		(SELECT
			owners.row->'fields'->'owner'
		FROM
		(
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS row
		) AS owners
		ORDER BY owners.row->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,		
		v.vehicle_owner_id AS pump_vehicle_owner_id,
		
		pv.phone_cels,
		pv.pump_prices
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	WHERE coalesce(pv.deleted,FALSE)=FALSE	
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_work_list
  OWNER TO beton;



-- ******************* update 05/12/2019 09:32:29 ******************
-- View: public.orders_make_list

-- DROP VIEW public.orders_make_list;

CREATE OR REPLACE VIEW public.orders_make_list AS 
	SELECT
		o.id,
		clients_ref(cl) AS clients_ref,
		destinations_ref(d) AS destinations_ref,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.comment_text,
		o.descr,
		o.phone_cel,
		o.unload_speed,
		o.date_time,
		o.date_time_to,
		o.quant,
		
		o.quant - COALESCE(
			( SELECT
				sum(shipments.quant) AS sum
			FROM shipments
			WHERE shipments.order_id = o.id AND shipments.shipped
			), 0::double precision)
		AS quant_rest,
		
		CASE
		WHEN o.date_time::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
			AND o.date_time_to::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time_to::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
				THEN o.quant
		WHEN o.date_time::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
				THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, o.date_time::date + (const_first_shift_start_time_val()::interval + const_day_shift_length_val()) - o.date_time) / 60::double precision))::numeric, 2)::double precision
		ELSE 0::double precision
		END AS quant_ordered_day,
		
		CASE
			WHEN now()::timestamp without time zone > o.date_time AND now()::timestamp without time zone < o.date_time_to THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, now()::timestamp without time zone::timestamp with time zone - o.date_time::timestamp with time zone) / 60::double precision))::numeric, 2)::double precision
			WHEN now()::timestamp without time zone > o.date_time_to THEN o.quant
			ELSE 0::double precision
		END AS quant_ordered_before_now,
		
		(SELECT
			COALESCE(sum(shipments.quant), 0::double precision) AS sum
		FROM shipments
		WHERE shipments.order_id = o.id AND shipments.ship_date_time < now()::timestamp without time zone
		) AS quant_shipped_before_now,
		
		(SELECT
			COALESCE(sum(shipments.quant), 0::double precision) AS sum
		FROM shipments
		WHERE shipments.order_id = o.id AND shipments.ship_date_time::time without time zone >= constant_first_shift_start_time()
			AND shipments.ship_date_time::time without time zone <= (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
		) AS quant_shipped_day_before_now,
		
		
		CASE
			WHEN
				(o.quant - COALESCE(
					(SELECT sum(shipments.quant) AS sum
					FROM shipments
					WHERE shipments.order_id = o.id AND shipments.shipped)
					, 0::double precision
					)
				) > 0::double precision
				AND (
					now()::timestamp without time zone::timestamp with time zone - (
					(SELECT shipments.ship_date_time
					FROM shipments
					WHERE shipments.order_id = o.id AND shipments.shipped
					ORDER BY shipments.ship_date_time DESC
					LIMIT 1)
					)::timestamp with time zone
				) > const_ord_mark_if_no_ship_time_val() THEN TRUE
			ELSE FALSE
		END AS no_ship_mark,
		
		o.payed,
		o.under_control,
		o.pay_cash,
		
		CASE
		    WHEN o.pay_cash THEN o.total
		    ELSE 0::numeric
		END AS total, 
		
		vh.owner AS pump_vehicle_owner,
		o.unload_type,
		--vehicle_owners_ref(v_own) AS pump_vehicle_owners_ref,
		(SELECT
			(owners.row->'fields'->'owner')::json
		FROM
		(
			SELECT jsonb_array_elements(vh.vehicle_owners->'rows') AS row
		) AS owners
		ORDER BY owners.row->'fields'->'dt_from' DESC
		LIMIT 1
		) AS pump_vehicle_owners_ref,
		
		pvh.pump_length AS pump_vehicle_length,
		pvh.comment_text AS pump_vehicle_comment
		
		
	FROM orders o
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = vh.vehicle_owner_id
	ORDER BY o.date_time;

ALTER TABLE public.orders_make_list OWNER TO beton;



-- ******************* update 05/12/2019 09:34:16 ******************
-- View: public.orders_make_for_lab_period_list

-- DROP VIEW public.orders_make_for_lab_period_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_period_list AS 
	SELECT
		o.*,
		(need_t.need_cnt > 0) AS is_needed
	FROM orders_make_list o
	LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (o.concrete_types_ref->'keys'->>'id')::int
	ORDER BY o.date_time;
ALTER TABLE public.orders_make_for_lab_period_list OWNER TO beton;



-- ******************* update 05/12/2019 09:34:52 ******************
-- View: public.orders_make_for_lab_list

-- DROP VIEW public.orders_make_for_lab_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_list AS 
 SELECT o.id,
    o.clients_ref,
    o.destinations_ref,
    o.concrete_types_ref,
    o.comment_text,
    o.descr,
    o.phone_cel,
    o.unload_speed,
    o.date_time,
    o.date_time_to,
    o.quant,
    o.quant_rest,
    o.quant_ordered_day,
    o.quant_ordered_before_now,
    o.quant_shipped_before_now,
    o.quant_shipped_day_before_now,
    o.no_ship_mark,
    o.payed,
    o.under_control,
    o.pay_cash,
    o.total,
    o.pump_vehicle_owner,
    o.unload_type,
    o.pump_vehicle_owners_ref,
    o.pump_vehicle_length,
    o.pump_vehicle_comment,
    need_t.need_cnt > 0::numeric AS is_needed
   FROM orders_make_list o
     LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (((o.concrete_types_ref -> 'keys'::text) ->> 'id'::text)::integer)
  WHERE o.date_time >= get_shift_start(now()::timestamp without time zone) AND o.date_time <= get_shift_end(get_shift_start(now()::timestamp without time zone))
  ORDER BY o.date_time;

ALTER TABLE public.orders_make_for_lab_list
  OWNER TO beton;



-- ******************* update 05/12/2019 09:37:29 ******************
-- View: public.orders_make_list

-- DROP VIEW public.orders_make_list CASCADE;

CREATE OR REPLACE VIEW public.orders_make_list AS 
	SELECT
		o.id,
		clients_ref(cl) AS clients_ref,
		destinations_ref(d) AS destinations_ref,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.comment_text,
		o.descr,
		o.phone_cel,
		o.unload_speed,
		o.date_time,
		o.date_time_to,
		o.quant,
		
		o.quant - COALESCE(
			( SELECT
				sum(shipments.quant) AS sum
			FROM shipments
			WHERE shipments.order_id = o.id AND shipments.shipped
			), 0::double precision)
		AS quant_rest,
		
		CASE
		WHEN o.date_time::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
			AND o.date_time_to::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time_to::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
				THEN o.quant
		WHEN o.date_time::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
				THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, o.date_time::date + (const_first_shift_start_time_val()::interval + const_day_shift_length_val()) - o.date_time) / 60::double precision))::numeric, 2)::double precision
		ELSE 0::double precision
		END AS quant_ordered_day,
		
		CASE
			WHEN now()::timestamp without time zone > o.date_time AND now()::timestamp without time zone < o.date_time_to THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, now()::timestamp without time zone::timestamp with time zone - o.date_time::timestamp with time zone) / 60::double precision))::numeric, 2)::double precision
			WHEN now()::timestamp without time zone > o.date_time_to THEN o.quant
			ELSE 0::double precision
		END AS quant_ordered_before_now,
		
		(SELECT
			COALESCE(sum(shipments.quant), 0::double precision) AS sum
		FROM shipments
		WHERE shipments.order_id = o.id AND shipments.ship_date_time < now()::timestamp without time zone
		) AS quant_shipped_before_now,
		
		(SELECT
			COALESCE(sum(shipments.quant), 0::double precision) AS sum
		FROM shipments
		WHERE shipments.order_id = o.id AND shipments.ship_date_time::time without time zone >= constant_first_shift_start_time()
			AND shipments.ship_date_time::time without time zone <= (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
		) AS quant_shipped_day_before_now,
		
		
		CASE
			WHEN
				(o.quant - COALESCE(
					(SELECT sum(shipments.quant) AS sum
					FROM shipments
					WHERE shipments.order_id = o.id AND shipments.shipped)
					, 0::double precision
					)
				) > 0::double precision
				AND (
					now()::timestamp without time zone::timestamp with time zone - (
					(SELECT shipments.ship_date_time
					FROM shipments
					WHERE shipments.order_id = o.id AND shipments.shipped
					ORDER BY shipments.ship_date_time DESC
					LIMIT 1)
					)::timestamp with time zone
				) > const_ord_mark_if_no_ship_time_val() THEN TRUE
			ELSE FALSE
		END AS no_ship_mark,
		
		o.payed,
		o.under_control,
		o.pay_cash,
		
		CASE
		    WHEN o.pay_cash THEN o.total
		    ELSE 0::numeric
		END AS total, 
		
		vh.owner AS pump_vehicle_owner,
		o.unload_type,
		--vehicle_owners_ref(v_own) AS pump_vehicle_owners_ref,
		(SELECT
			owners.row->'fields'->'owner'
		FROM
		(
			SELECT jsonb_array_elements(vh.vehicle_owners->'rows') AS row
		) AS owners
		--WHERE o.date_time>=owners.row->'fields'->'dt_from'
		ORDER BY owners.row->'fields'->'dt_from' DESC
		LIMIT 1
		) AS pump_vehicle_owners_ref,
		
		pvh.pump_length AS pump_vehicle_length,
		pvh.comment_text AS pump_vehicle_comment
		
		
	FROM orders o
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = vh.vehicle_owner_id
	ORDER BY o.date_time;

ALTER TABLE public.orders_make_list OWNER TO beton;



-- ******************* update 05/12/2019 09:37:45 ******************
-- View: public.orders_make_for_lab_list

-- DROP VIEW public.orders_make_for_lab_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_list AS 
 SELECT o.id,
    o.clients_ref,
    o.destinations_ref,
    o.concrete_types_ref,
    o.comment_text,
    o.descr,
    o.phone_cel,
    o.unload_speed,
    o.date_time,
    o.date_time_to,
    o.quant,
    o.quant_rest,
    o.quant_ordered_day,
    o.quant_ordered_before_now,
    o.quant_shipped_before_now,
    o.quant_shipped_day_before_now,
    o.no_ship_mark,
    o.payed,
    o.under_control,
    o.pay_cash,
    o.total,
    o.pump_vehicle_owner,
    o.unload_type,
    o.pump_vehicle_owners_ref,
    o.pump_vehicle_length,
    o.pump_vehicle_comment,
    need_t.need_cnt > 0::numeric AS is_needed
   FROM orders_make_list o
     LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (((o.concrete_types_ref -> 'keys'::text) ->> 'id'::text)::integer)
  WHERE o.date_time >= get_shift_start(now()::timestamp without time zone) AND o.date_time <= get_shift_end(get_shift_start(now()::timestamp without time zone))
  ORDER BY o.date_time;

ALTER TABLE public.orders_make_for_lab_list
  OWNER TO beton;



-- ******************* update 05/12/2019 09:37:50 ******************
-- View: public.orders_make_for_lab_period_list

-- DROP VIEW public.orders_make_for_lab_period_list;

CREATE OR REPLACE VIEW public.orders_make_for_lab_period_list AS 
	SELECT
		o.*,
		(need_t.need_cnt > 0) AS is_needed
	FROM orders_make_list o
	LEFT JOIN lab_entry_30days need_t ON need_t.concrete_type_id = (o.concrete_types_ref->'keys'->>'id')::int
	ORDER BY o.date_time;
ALTER TABLE public.orders_make_for_lab_period_list OWNER TO beton;



-- ******************* update 05/12/2019 09:38:51 ******************
-- View: public.orders_make_list

-- DROP VIEW public.orders_make_list CASCADE;

CREATE OR REPLACE VIEW public.orders_make_list AS 
	SELECT
		o.id,
		clients_ref(cl) AS clients_ref,
		destinations_ref(d) AS destinations_ref,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.comment_text,
		o.descr,
		o.phone_cel,
		o.unload_speed,
		o.date_time,
		o.date_time_to,
		o.quant,
		
		o.quant - COALESCE(
			( SELECT
				sum(shipments.quant) AS sum
			FROM shipments
			WHERE shipments.order_id = o.id AND shipments.shipped
			), 0::double precision)
		AS quant_rest,
		
		CASE
		WHEN o.date_time::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
			AND o.date_time_to::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time_to::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
				THEN o.quant
		WHEN o.date_time::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
				THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, o.date_time::date + (const_first_shift_start_time_val()::interval + const_day_shift_length_val()) - o.date_time) / 60::double precision))::numeric, 2)::double precision
		ELSE 0::double precision
		END AS quant_ordered_day,
		
		CASE
			WHEN now()::timestamp without time zone > o.date_time AND now()::timestamp without time zone < o.date_time_to THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, now()::timestamp without time zone::timestamp with time zone - o.date_time::timestamp with time zone) / 60::double precision))::numeric, 2)::double precision
			WHEN now()::timestamp without time zone > o.date_time_to THEN o.quant
			ELSE 0::double precision
		END AS quant_ordered_before_now,
		
		(SELECT
			COALESCE(sum(shipments.quant), 0::double precision) AS sum
		FROM shipments
		WHERE shipments.order_id = o.id AND shipments.ship_date_time < now()::timestamp without time zone
		) AS quant_shipped_before_now,
		
		(SELECT
			COALESCE(sum(shipments.quant), 0::double precision) AS sum
		FROM shipments
		WHERE shipments.order_id = o.id AND shipments.ship_date_time::time without time zone >= constant_first_shift_start_time()
			AND shipments.ship_date_time::time without time zone <= (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
		) AS quant_shipped_day_before_now,
		
		
		CASE
			WHEN
				(o.quant - COALESCE(
					(SELECT sum(shipments.quant) AS sum
					FROM shipments
					WHERE shipments.order_id = o.id AND shipments.shipped)
					, 0::double precision
					)
				) > 0::double precision
				AND (
					now()::timestamp without time zone::timestamp with time zone - (
					(SELECT shipments.ship_date_time
					FROM shipments
					WHERE shipments.order_id = o.id AND shipments.shipped
					ORDER BY shipments.ship_date_time DESC
					LIMIT 1)
					)::timestamp with time zone
				) > const_ord_mark_if_no_ship_time_val() THEN TRUE
			ELSE FALSE
		END AS no_ship_mark,
		
		o.payed,
		o.under_control,
		o.pay_cash,
		
		CASE
		    WHEN o.pay_cash THEN o.total
		    ELSE 0::numeric
		END AS total, 
		
		vh.owner AS pump_vehicle_owner,
		o.unload_type,
		--vehicle_owners_ref(v_own) AS pump_vehicle_owners_ref,
		(SELECT
			owners.row->'fields'->'owner'
		FROM
		(
			SELECT jsonb_array_elements(vh.vehicle_owners->'rows') AS row
		) AS owners
		--WHERE o.date_time >= (owners.row->'fields'->'dt_from')::timestamp
		ORDER BY owners.row->'fields'->'dt_from'
		LIMIT 1
		) AS pump_vehicle_owners_ref,
		
		pvh.pump_length AS pump_vehicle_length,
		pvh.comment_text AS pump_vehicle_comment
		
		
	FROM orders o
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = vh.vehicle_owner_id
	ORDER BY o.date_time;

ALTER TABLE public.orders_make_list OWNER TO beton;



-- ******************* update 05/12/2019 09:39:24 ******************
-- View: public.orders_make_list

-- DROP VIEW public.orders_make_list CASCADE;

CREATE OR REPLACE VIEW public.orders_make_list AS 
	SELECT
		o.id,
		clients_ref(cl) AS clients_ref,
		destinations_ref(d) AS destinations_ref,
		concrete_types_ref(concr) AS concrete_types_ref,
		o.comment_text,
		o.descr,
		o.phone_cel,
		o.unload_speed,
		o.date_time,
		o.date_time_to,
		o.quant,
		
		o.quant - COALESCE(
			( SELECT
				sum(shipments.quant) AS sum
			FROM shipments
			WHERE shipments.order_id = o.id AND shipments.shipped
			), 0::double precision)
		AS quant_rest,
		
		CASE
		WHEN o.date_time::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
			AND o.date_time_to::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time_to::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
				THEN o.quant
		WHEN o.date_time::time without time zone >= const_first_shift_start_time_val()
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
			AND o.date_time::time without time zone < (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
				THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, o.date_time::date + (const_first_shift_start_time_val()::interval + const_day_shift_length_val()) - o.date_time) / 60::double precision))::numeric, 2)::double precision
		ELSE 0::double precision
		END AS quant_ordered_day,
		
		CASE
			WHEN now()::timestamp without time zone > o.date_time AND now()::timestamp without time zone < o.date_time_to THEN round((o.quant / (date_part('epoch'::text, o.date_time_to - o.date_time) / 60::double precision) * (date_part('epoch'::text, now()::timestamp without time zone::timestamp with time zone - o.date_time::timestamp with time zone) / 60::double precision))::numeric, 2)::double precision
			WHEN now()::timestamp without time zone > o.date_time_to THEN o.quant
			ELSE 0::double precision
		END AS quant_ordered_before_now,
		
		(SELECT
			COALESCE(sum(shipments.quant), 0::double precision) AS sum
		FROM shipments
		WHERE shipments.order_id = o.id AND shipments.ship_date_time < now()::timestamp without time zone
		) AS quant_shipped_before_now,
		
		(SELECT
			COALESCE(sum(shipments.quant), 0::double precision) AS sum
		FROM shipments
		WHERE shipments.order_id = o.id AND shipments.ship_date_time::time without time zone >= constant_first_shift_start_time()
			AND shipments.ship_date_time::time without time zone <= (const_first_shift_start_time_val()::interval + const_day_shift_length_val())::time without time zone
		) AS quant_shipped_day_before_now,
		
		
		CASE
			WHEN
				(o.quant - COALESCE(
					(SELECT sum(shipments.quant) AS sum
					FROM shipments
					WHERE shipments.order_id = o.id AND shipments.shipped)
					, 0::double precision
					)
				) > 0::double precision
				AND (
					now()::timestamp without time zone::timestamp with time zone - (
					(SELECT shipments.ship_date_time
					FROM shipments
					WHERE shipments.order_id = o.id AND shipments.shipped
					ORDER BY shipments.ship_date_time DESC
					LIMIT 1)
					)::timestamp with time zone
				) > const_ord_mark_if_no_ship_time_val() THEN TRUE
			ELSE FALSE
		END AS no_ship_mark,
		
		o.payed,
		o.under_control,
		o.pay_cash,
		
		CASE
		    WHEN o.pay_cash THEN o.total
		    ELSE 0::numeric
		END AS total, 
		
		vh.owner AS pump_vehicle_owner,
		o.unload_type,
		--vehicle_owners_ref(v_own) AS pump_vehicle_owners_ref,
		(SELECT
			owners.row->'fields'->'owner'
		FROM
		(
			SELECT jsonb_array_elements(vh.vehicle_owners->'rows') AS row
		) AS owners
		WHERE o.date_time >= (owners.row->'fields'->>'dt_from')::timestamp
		ORDER BY (owners.row->'fields'->>'dt_from')::timestamp DESC
		LIMIT 1
		) AS pump_vehicle_owners_ref,
		
		pvh.pump_length AS pump_vehicle_length,
		pvh.comment_text AS pump_vehicle_comment
		
		
	FROM orders o
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = vh.vehicle_owner_id
	ORDER BY o.date_time;

ALTER TABLE public.orders_make_list OWNER TO beton;



-- ******************* update 05/12/2019 12:35:56 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_OP='INSERT' THEN
		--пытаемся определить авто по описанию элкон
		NEW.vehicle_id = vehicles_define_on_production_descr(NEW.production_vehicle_descr,NEW.production_dt_start::timestamp);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 05/12/2019 12:52:22 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_OP='INSERT' THEN
		-- пытаемся определить авто по описанию элкон
		-- выбираем из production_descr только числа
		-- находим авто с маской %in_production_descr% и назначенное в диапазоне получаса
		SELECT
			sh.id,
			vschs.id
		INTO
			NEW.vehicle_id,
			NEW.vehicle_schedule_state_id
		FROM shipments AS sh
		LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
		LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
		LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
		WHERE
			sh.date_time BETWEEN NEW.production_dt_start::timestamp-'60 minutes'::interval AND NEW.production_dt_start::timestamp
			AND vh.plate LIKE '%'||regexp_replace(NEW.production_vehicle_descr, '\D','','g')||'%'
		LIMIT 1;
		
		--NEW.vehicle_id = vehicles_define_on_production_descr(NEW.production_vehicle_descr,NEW.production_dt_start::timestamp);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 05/12/2019 12:52:53 ******************
-- Trigger: productions_trigger on productions

-- DROP TRIGGER productions_before_trigger ON productions;

CREATE TRIGGER productions_before_trigger
  BEFORE INSERT
  ON productions
  FOR EACH ROW
  EXECUTE PROCEDURE productions_process();



-- ******************* update 05/12/2019 13:06:24 ******************
-- VIEW: production_sites_last_production_list

--DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		last_prod_det.production_id,
		(last_prod_det.production_dt_end IS NOT NULL) AS closed
	FROM production_sites AS p_s
	LEFT JOIN (
		SELECT
			p.production_site_id,
			MAX(p.production_id) AS last_production_id
		FROM productions AS p
		GROUP BY p.production_site_id
	) AS last_prod ON last_prod.production_site_id=p_s.id
	LEFT JOIN productions AS last_prod_det ON last_prod_det.production_site_id=last_prod.production_site_id AND last_prod_det.production_id = last_prod.last_production_id
	WHERE p_s.active
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 05/12/2019 14:11:05 ******************

		ALTER TABLE material_fact_consumptions ADD COLUMN cement_silo_id int REFERENCES cement_silos(id);



-- ******************* update 10/12/2019 13:48:39 ******************
﻿-- Function: material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)

-- DROP FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)
  RETURNS record AS
$$
	SELECT
		sh.id AS vehicle_id,
		vschs.id AS vehicle_schedule_state_id
	FROM shipments AS sh
	LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
	WHERE
		sh.date_time BETWEEN in_production_dt_start-'60 minutes'::interval AND in_production_dt_start
		AND vh.plate LIKE '%'||regexp_replace(in_production_vehicle_descr, '\D','','g')||'%'
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp) OWNER TO beton;


-- ******************* update 10/12/2019 13:52:10 ******************
﻿-- Function: material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)

-- DROP FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)
  RETURNS record AS
$$
	-- пытаемся определить авто по описанию элкон
	-- выбираем из production_descr только числа
	-- находим авто с маской %in_production_descr% и назначенное в диапазоне получаса

	SELECT
		sh.id AS vehicle_id,
		vschs.id AS vehicle_schedule_state_id
	FROM shipments AS sh
	LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
	WHERE
		sh.date_time BETWEEN in_production_dt_start-'60 minutes'::interval AND in_production_dt_start
		AND vh.plate LIKE '%'||regexp_replace(in_production_vehicle_descr, '\D','','g')||'%'
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp) OWNER TO beton;


-- ******************* update 10/12/2019 13:53:18 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_OP='INSERT' THEN
		/*
		SELECT
			sh.id,
			vschs.id
		INTO
			NEW.vehicle_id,
			NEW.vehicle_schedule_state_id
		FROM shipments AS sh
		LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
		LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
		LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
		WHERE
			sh.date_time BETWEEN NEW.production_dt_start::timestamp-'60 minutes'::interval AND NEW.production_dt_start::timestamp
			AND vh.plate LIKE '%'||regexp_replace(NEW.production_vehicle_descr, '\D','','g')||'%'
		LIMIT 1;
		*/
		
		SELECT *
		INTO
			NEW.vehicle_id,
			NEW.vehicle_schedule_state_id
		FROM material_fact_consumptions_find_vehicle(
			NEW.production_vehicle_descr,
			NEW.production_dt_start::timestamp
		) AS (
			vehicle_id int,
			vehicle_schedule_state_id int
		);		
		--NEW.vehicle_id = vehicles_define_on_production_descr(NEW.production_vehicle_descr,);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 10/12/2019 17:08:34 ******************
-- VIEW: productions_list

--DROP VIEW productions_list;

CREATE OR REPLACE VIEW productions_list AS
	SELECT
		t.id,
		t.production_id,
		t.production_dt_start,
		t.production_dt_end,
		t.production_user,
		t.production_vehicle_descr,
		t.dt_start_set,
		t.dt_end_set,
		production_sites_ref(ps) AS production_sites_ref,
		shipments_ref(sh) AS shipments_ref,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.production_concrete_type_descr
	FROM productions AS t
	LEFT JOIN production_sites AS ps ON ps.id = t.production_site_id
	LEFT JOIN shipments AS sh ON sh.id = t.shipment_id
	LEFT JOIN concrete_types AS ct ON ct.id = t.concrete_type_id
	;
	
ALTER VIEW productions_list OWNER TO beton;


-- ******************* update 10/12/2019 17:09:25 ******************
-- VIEW: productions_list

--DROP VIEW productions_list;

CREATE OR REPLACE VIEW productions_list AS
	SELECT
		t.id,
		t.production_id,
		t.production_dt_start,
		t.production_dt_end,
		t.production_user,
		t.production_vehicle_descr,
		t.dt_start_set,
		t.dt_end_set,
		production_sites_ref(ps) AS production_sites_ref,
		shipments_ref(sh) AS shipments_ref,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.production_concrete_type_descr,
		orders_ref(o) AS orders_ref
	FROM productions AS t
	LEFT JOIN production_sites AS ps ON ps.id = t.production_site_id
	LEFT JOIN shipments AS sh ON sh.id = t.shipment_id
	LEFT JOIN concrete_types AS ct ON ct.id = t.concrete_type_id
	LEFT JOIN orders AS o ON o.id = sh.order_id
	;
	
ALTER VIEW productions_list OWNER TO beton;


-- ******************* update 11/12/2019 10:11:53 ******************
-- VIEW: production_sites_last_production_list

--DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		last_prod_det.production_id,
		(last_prod_det.production_dt_end IS NOT NULL) AS closed
	FROM production_sites AS p_s
	LEFT JOIN (
		SELECT
			p.production_site_id,
			MAX(p.production_id) AS last_production_id
		FROM productions AS p
		GROUP BY p.production_site_id
	) AS last_prod ON last_prod.production_site_id=p_s.id
	LEFT JOIN productions AS last_prod_det ON last_prod_det.production_site_id=last_prod.production_site_id AND last_prod_det.production_id = last_prod.last_production_id
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 11/12/2019 10:12:20 ******************
-- VIEW: production_sites_last_production_list

--DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		last_prod_det.production_id,
		(last_prod_det.production_dt_end IS NOT NULL) AS closed
	FROM production_sites AS p_s
	LEFT JOIN (
		SELECT
			p.production_site_id,
			MAX(p.production_id) AS last_production_id
		FROM productions AS p
		GROUP BY p.production_site_id
	) AS last_prod ON last_prod.production_site_id=p_s.id
	LEFT JOIN productions AS last_prod_det ON last_prod_det.production_site_id=last_prod.production_site_id AND last_prod_det.production_id = last_prod.last_production_id
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL AND last_prod_det.production_id IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 11/12/2019 10:13:18 ******************
-- VIEW: production_sites_last_production_list

--DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		last_prod_det.production_id,
		(last_prod_det.production_dt_end IS NOT NULL) AS closed
	FROM production_sites AS p_s
	LEFT JOIN (
		SELECT
			p.production_site_id,
			MAX(p.production_id) AS last_production_id
		FROM productions AS p
		GROUP BY p.production_site_id
	) AS last_prod ON last_prod.production_site_id=p_s.id
	LEFT JOIN productions AS last_prod_det ON last_prod_det.production_site_id=last_prod.production_site_id AND last_prod_det.production_id = last_prod.last_production_id
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 11/12/2019 13:25:35 ******************
-- VIEW: production_sites_last_production_list

--DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		p_s.last_elkon_production_id AS production_id,
		(SELECT pr.production_dt_end IS NOT NULL FROM productions AS pr WHERE pr.production_id=p_s.last_elkon_production_id
		) AS closed
	FROM production_sites AS p_s
	
	/*
	LEFT JOIN (
		SELECT
			p.production_site_id,
			MAX(p.production_id) AS last_production_id
		FROM productions AS p
		GROUP BY p.production_site_id
	) AS last_prod ON last_prod.production_site_id=p_s.id		
	LEFT JOIN productions AS last_prod_det ON last_prod_det.production_site_id=last_prod.production_site_id AND last_prod_det.production_id = last_prod.last_production_id
	*/
	
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL AND p_s.last_elkon_production_id IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 11/12/2019 13:28:23 ******************
-- VIEW: production_sites_last_production_list

--DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		p_s.last_elkon_production_id AS production_id,
		coalesce(
			(SELECT pr.production_dt_end IS NOT NULL FROM productions AS pr WHERE pr.production_id=p_s.last_elkon_production_id
			)
		,FALSE) AS closed
	FROM production_sites AS p_s
	
	/*
	LEFT JOIN (
		SELECT
			p.production_site_id,
			MAX(p.production_id) AS last_production_id
		FROM productions AS p
		GROUP BY p.production_site_id
	) AS last_prod ON last_prod.production_site_id=p_s.id		
	LEFT JOIN productions AS last_prod_det ON last_prod_det.production_site_id=last_prod.production_site_id AND last_prod_det.production_id = last_prod.last_production_id
	*/
	
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL AND p_s.last_elkon_production_id IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 11/12/2019 16:40:26 ******************
﻿-- Function: material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)

-- DROP FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)
  RETURNS record AS
$$
	-- пытаемся определить авто по описанию элкон
	-- выбираем из production_descr только числа
	-- находим авто с маской %in_production_descr% и назначенное в диапазоне получаса

	SELECT
		vsch.vehicle_id AS vehicle_id,
		vschs.id AS vehicle_schedule_state_id
	FROM shipments AS sh
	LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
	WHERE
		sh.date_time BETWEEN in_production_dt_start-'60 minutes'::interval AND in_production_dt_start
		AND vh.plate LIKE '%'||regexp_replace(in_production_vehicle_descr, '\D','','g')||'%'
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp) OWNER TO beton;


-- ******************* update 12/12/2019 13:13:38 ******************
﻿-- Function: material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)

-- DROP FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)
  RETURNS record AS
$$
	-- пытаемся определить авто по описанию элкон
	-- выбираем из production_descr только числа
	-- находим авто с маской %in_production_descr% и назначенное в диапазоне получаса

	SELECT
		vsch.vehicle_id AS vehicle_id,
		vschs.id AS vehicle_schedule_state_id,
		sh.id AS shipment_id
	FROM shipments AS sh
	LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
	WHERE
		sh.date_time BETWEEN in_production_dt_start-'60 minutes'::interval AND in_production_dt_start
		AND vh.plate LIKE '%'||regexp_replace(in_production_vehicle_descr, '\D','','g')||'%'
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp) OWNER TO beton;


-- ******************* update 12/12/2019 13:13:58 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_OP='INSERT' THEN
		/*
		SELECT
			sh.id,
			vschs.id
		INTO
			NEW.vehicle_id,
			NEW.vehicle_schedule_state_id
		FROM shipments AS sh
		LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
		LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
		LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
		WHERE
			sh.date_time BETWEEN NEW.production_dt_start::timestamp-'60 minutes'::interval AND NEW.production_dt_start::timestamp
			AND vh.plate LIKE '%'||regexp_replace(NEW.production_vehicle_descr, '\D','','g')||'%'
		LIMIT 1;
		*/
		
		SELECT *
		INTO
			NEW.vehicle_id,
			NEW.vehicle_schedule_state_id,
			NEW.shipment_id
		FROM material_fact_consumptions_find_vehicle(
			NEW.production_vehicle_descr,
			NEW.production_dt_start::timestamp
		) AS (
			vehicle_id int,
			vehicle_schedule_state_id int,
			shipment_id int
		);		
		--NEW.vehicle_id = vehicles_define_on_production_descr(NEW.production_vehicle_descr,);
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 12/12/2019 14:35:22 ******************
-- VIEW: production_sites_last_production_list

--DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		p_s.last_elkon_production_id AS production_id,
		coalesce(
			(SELECT pr.production_dt_end IS NOT NULL FROM productions AS pr WHERE pr.production_id=p_s.last_elkon_production_id
			)
		,FALSE) AS closed,
		
		(
		SELECT
			array_agg(production_id)||(
				SELECT CASE
					WHEN (SELECT TRUE FROM productions
						WHERE production_site_id=p_s.id AND production_id=p_s.last_elkon_production_id
					) THEN NULL
					ELSE ARRAY[p_s.last_elkon_production_id]
					END
			)
		FROM productions
		WHERE production_site_id=p_s.id AND production_dt_end IS NULL
		) AS production_ids
		
	FROM production_sites AS p_s
	
	/*
	LEFT JOIN (
		SELECT
			p.production_site_id,
			MAX(p.production_id) AS last_production_id
		FROM productions AS p
		GROUP BY p.production_site_id
	) AS last_prod ON last_prod.production_site_id=p_s.id		
	LEFT JOIN productions AS last_prod_det ON last_prod_det.production_site_id=last_prod.production_site_id AND last_prod_det.production_id = last_prod.last_production_id
	*/
	
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL AND p_s.last_elkon_production_id IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 12/12/2019 14:41:36 ******************
-- VIEW: production_sites_last_production_list

DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		
		/*
		p_s.last_elkon_production_id AS production_id,
		coalesce(
			(SELECT pr.production_dt_end IS NOT NULL FROM productions AS pr WHERE pr.production_id=p_s.last_elkon_production_id
			)
		,FALSE) AS closed,
		*/
		
		(
		SELECT
			array_agg(production_id)||(
				SELECT CASE
					WHEN (SELECT TRUE FROM productions
						WHERE production_site_id=p_s.id AND production_id=p_s.last_elkon_production_id
					) THEN NULL
					ELSE ARRAY[p_s.last_elkon_production_id]
					END
			)
		FROM productions
		WHERE production_site_id=p_s.id AND production_dt_end IS NULL
		) AS production_ids
		
	FROM production_sites AS p_s
	
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL AND p_s.last_elkon_production_id IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 12/12/2019 15:03:48 ******************
-- VIEW: production_sites_last_production_list

DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		
		p_s.last_elkon_production_id AS production_id,
		
		/*		
		coalesce(
			(SELECT pr.production_dt_end IS NOT NULL FROM productions AS pr WHERE pr.production_id=p_s.last_elkon_production_id
			)
		,FALSE) AS closed,
		*/
		
		(
		SELECT
			array_agg(production_id)||(
				SELECT CASE
					WHEN (SELECT TRUE FROM productions
						WHERE production_site_id=p_s.id AND production_id=p_s.last_elkon_production_id
					) THEN NULL
					ELSE ARRAY[p_s.last_elkon_production_id]
					END
			)
		FROM productions
		WHERE production_site_id=p_s.id AND production_dt_end IS NULL
		) AS production_ids
		
	FROM production_sites AS p_s
	
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL AND p_s.last_elkon_production_id IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 12/12/2019 15:04:03 ******************
-- VIEW: production_sites_last_production_list

DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		
		p_s.last_elkon_production_id AS last_production_id,
		
		/*		
		coalesce(
			(SELECT pr.production_dt_end IS NOT NULL FROM productions AS pr WHERE pr.production_id=p_s.last_elkon_production_id
			)
		,FALSE) AS closed,
		*/
		
		(
		SELECT
			array_agg(production_id)||(
				SELECT CASE
					WHEN (SELECT TRUE FROM productions
						WHERE production_site_id=p_s.id AND production_id=p_s.last_elkon_production_id
					) THEN NULL
					ELSE ARRAY[p_s.last_elkon_production_id]
					END
			)
		FROM productions
		WHERE production_site_id=p_s.id AND production_dt_end IS NULL
		) AS production_ids
		
	FROM production_sites AS p_s
	
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL AND p_s.last_elkon_production_id IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 12/12/2019 15:09:52 ******************
-- VIEW: production_sites_last_production_list

--DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		
		p_s.last_elkon_production_id AS last_production_id,
		
		/*		
		coalesce(
			(SELECT pr.production_dt_end IS NOT NULL FROM productions AS pr WHERE pr.production_id=p_s.last_elkon_production_id
			)
		,FALSE) AS closed,
		*/
		
		(
		SELECT
			array_agg(production_id)
			/*||(
				SELECT CASE
					WHEN (SELECT TRUE FROM productions
						WHERE production_site_id=p_s.id AND production_id=p_s.last_elkon_production_id
					) THEN NULL
					ELSE ARRAY[p_s.last_elkon_production_id]
					END
			)
			
			*/
		FROM productions
		WHERE production_site_id=p_s.id AND production_dt_end IS NULL
		) AS production_ids
		
	FROM production_sites AS p_s
	
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL AND p_s.last_elkon_production_id IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO beton;


-- ******************* update 12/12/2019 16:13:54 ******************
-- VIEW: production_sites_list

--DROP VIEW production_sites_list;

CREATE OR REPLACE VIEW production_sites_list AS
	SELECT
		id,
		name		 
	FROM production_sites
	ORDER BY name
	;
	
ALTER VIEW production_sites_list OWNER TO beton;


-- ******************* update 12/12/2019 16:14:51 ******************
-- VIEW: production_sites_for_edit_list

--DROP VIEW production_sites_for_edit_list;

CREATE OR REPLACE VIEW production_sites_for_edit_list AS
	SELECT
		*		 
	FROM production_sites
	ORDER BY name
	;
	
ALTER VIEW production_sites_for_edit_list OWNER TO beton;


-- ******************* update 12/12/2019 16:30:29 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10039',
		'ProductionSite_Controller',
		'get_list_for_edit',
		'ProductionSiteForEditList',
		'Справочники',
		'Заводы (все параметры)',
		FALSE
		);
	

-- ******************* update 12/12/2019 16:34:31 ******************
-- VIEW: elkon_log_list

--DROP VIEW elkon_log_list;

CREATE OR REPLACE VIEW elkon_log_list AS
	SELECT
		t.*,
		production_sites_ref(p_st) AS production_sites_ref
	FROM elkon_log AS t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	;
	
ALTER VIEW elkon_log_list OWNER TO beton;


-- ******************* update 12/12/2019 16:36:51 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20015',
		'ELKONLog_Controller',
		'get_list',
		'ELKONLogList',
		'Формы',
		'Журнал загрузки из ELKON',
		FALSE
		);
	

-- ******************* update 12/12/2019 16:44:47 ******************
-- VIEW: elkon_log_list

--DROP VIEW elkon_log_list;

CREATE OR REPLACE VIEW elkon_log_list AS
	SELECT
		t.*,
		production_sites_ref(p_st) AS production_sites_ref
	FROM elkon_log AS t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW elkon_log_list OWNER TO beton;


-- ******************* update 12/12/2019 16:45:44 ******************
-- VIEW: elkon_log_list

--DROP VIEW elkon_log_list;

CREATE OR REPLACE VIEW elkon_log_list AS
	SELECT
		t.*,
		production_sites_ref(p_st) AS production_sites_ref
	FROM elkon_log AS t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW elkon_log_list OWNER TO beton;


-- ******************* update 12/12/2019 16:47:28 ******************
-- VIEW: elkon_log_list

--DROP VIEW elkon_log_list;

CREATE OR REPLACE VIEW elkon_log_list AS
	SELECT
		t.*,
		production_sites_ref(p_st) AS production_sites_ref
	FROM elkon_log AS t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW elkon_log_list OWNER TO beton;


-- ******************* update 13/12/2019 08:57:23 ******************
-- VIEW: productions_list

--DROP VIEW productions_list;

CREATE OR REPLACE VIEW productions_list AS
	SELECT
		t.id,
		t.production_id,
		t.production_dt_start,
		t.production_dt_end,
		t.production_user,
		t.production_vehicle_descr,
		t.dt_start_set,
		t.dt_end_set,
		production_sites_ref(ps) AS production_sites_ref,
		shipments_ref(sh) AS shipments_ref,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.production_concrete_type_descr,
		orders_ref(o) AS orders_ref,
		vs.vehicle_id,
		vehicle_schedules_ref(vs,v,dr) AS vehicle_schedules_ref
		
	FROM productions AS t
	LEFT JOIN production_sites AS ps ON ps.id = t.production_site_id
	LEFT JOIN shipments AS sh ON sh.id = t.shipment_id
	LEFT JOIN concrete_types AS ct ON ct.id = t.concrete_type_id
	LEFT JOIN orders AS o ON o.id = sh.order_id
	LEFT JOIN vehicle_schedules AS vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS v ON v.id = vs.vehicle_id
	LEFT JOIN drivers AS dr ON dr.id = vs.driver_id
	;
	
ALTER VIEW productions_list OWNER TO beton;


-- ******************* update 13/12/2019 09:39:05 ******************
-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

-- DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;
/*
CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE INSERT OR UPDATE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();
*/

-- DROP TRIGGER material_fact_consumptions_trigger_after ON public.material_fact_consumptions;

CREATE TRIGGER material_fact_consumptions_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();



-- ******************* update 13/12/2019 10:15:51 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_cement_material_id int;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		v_cement_material_id = 	(const_cement_material_val()->'keys'->>'id')::int;
				
		IF NEW.raw_material_id IS NOT NULL AND NEW.raw_material_id<>v_cement_material_id  THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.raw_material_id IS NOT NULL
			AND NEW.raw_material_id=v_cement_material_id
			 AND NEW.cement_silo_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 13/12/2019 10:46:30 ******************
-- Trigger: productions_trigger on productions

-- DROP TRIGGER productions_before_trigger ON productions;
/*
CREATE TRIGGER productions_before_trigger
  BEFORE INSERT
  ON productions
  FOR EACH ROW
  EXECUTE PROCEDURE productions_process();
*/
-- DROP TRIGGER productions_after_trigger ON productions;

CREATE TRIGGER productions_after_trigger
  AFTER DELETE
  ON productions
  FOR EACH ROW
  EXECUTE PROCEDURE productions_process();



-- ******************* update 13/12/2019 10:48:41 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		
		SELECT *
		INTO
			NEW.vehicle_id,
			NEW.vehicle_schedule_state_id,
			NEW.shipment_id
		FROM material_fact_consumptions_find_vehicle(
			NEW.production_vehicle_descr,
			NEW.production_dt_start::timestamp
		) AS (
			vehicle_id int,
			vehicle_schedule_state_id int,
			shipment_id int
		);		
		
		RETURN NEW;
		
	ELSEIF TG_WHEN='AFTER' AND TG_OP='DELETE' THEN
		DELETE FROM material_fact_consumptions WHERE production_id = OLD.production_id;
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 13/12/2019 10:49:36 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_WHEN='BEFORE' THEN
		IF TG_OP='INSERT' THEN
			SELECT *
			INTO
				NEW.vehicle_id,
				NEW.vehicle_schedule_state_id,
				NEW.shipment_id
			FROM material_fact_consumptions_find_vehicle(
				NEW.production_vehicle_descr,
				NEW.production_dt_start::timestamp
			) AS (
				vehicle_id int,
				vehicle_schedule_state_id int,
				shipment_id int
			);		
		END IF;
				
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='AFTER' THEN
			DELETE FROM material_fact_consumptions WHERE production_id = OLD.production_id;
		END IF;	
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 13/12/2019 11:17:12 ******************
		CREATE TABLE user_map_to_production
		(id serial NOT NULL,production_site_id int REFERENCES production_sites(id),user_id int REFERENCES users(id),production_descr  varchar(100) NOT NULL,CONSTRAINT user_map_to_production_pkey PRIMARY KEY (id)
		);
	--DROP INDEX IF EXISTS user_map_to_production_production_descr_idx;
	CREATE UNIQUE INDEX user_map_to_production_production_descr_idx
	ON user_map_to_production(production_site_id,production_descr);
		ALTER TABLE user_map_to_production OWNER TO beton;



-- ******************* update 13/12/2019 11:20:32 ******************
-- VIEW: user_map_to_production_list

--DROP VIEW user_map_to_production_list;

CREATE OR REPLACE VIEW user_map_to_production_list AS
	SELECT
		t.id,
		production_sites_ref(p_st) AS production_sites_ref,
		users_ref(u) AS users_ref
	FROM user_map_to_production AS t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.user_id
	;
	
ALTER VIEW user_map_to_production_list OWNER TO beton;


-- ******************* update 13/12/2019 11:23:32 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10040',
		'UserMapToProduction_Controller',
		'get_list',
		'UserMapToProductionList',
		'Справочники',
		'Соответствие пользователей в производстве и в бетоне',
		FALSE
		);
	

-- ******************* update 13/12/2019 11:38:12 ******************
-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

-- DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;
/*
CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE INSERT OR UPDATE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();
*/

 DROP TRIGGER material_fact_consumptions_trigger_after ON public.material_fact_consumptions;



-- ******************* update 13/12/2019 11:38:30 ******************
-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

 DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;

CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE INSERT OR UPDATE OR DELETE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();



-- ******************* update 13/12/2019 11:41:32 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		SELECT *
		INTO
			NEW.vehicle_id,
			NEW.vehicle_schedule_state_id,
			NEW.shipment_id
		FROM material_fact_consumptions_find_vehicle(
			NEW.production_vehicle_descr,
			NEW.production_dt_start::timestamp
		) AS (
			vehicle_id int,
			vehicle_schedule_state_id int,
			shipment_id int
		);		
				
		RETURN NEW;
		
	ELSEIF TG_WHEN='AFTER' AND TG_OP='UPDATE' THEN
		
		/*
		ЭТО ДЕЛАЕТСЯ В КОНТРОЛЛЕРЕ Production_Controller->check_data!!!
		IF OLD.production_dt_end IS NULL
		AND NEW.production_dt_end IS NOT NULL
		AND NEW.shipment_id IS NOT NULL THEN
			
		END IF;
		*/
		RETURN NEW;
		
	ELSEIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM material_fact_consumptions WHERE production_id = OLD.production_id;
		RETURN OLD;
				
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 13/12/2019 13:16:32 ******************
-- VIEW: user_map_to_production_list

DROP VIEW user_map_to_production_list;

CREATE OR REPLACE VIEW user_map_to_production_list AS
	SELECT
		t.*,
		production_sites_ref(p_st) AS production_sites_ref,
		users_ref(u) AS users_ref
	FROM user_map_to_production AS t
	LEFT JOIN production_sites AS p_st ON p_st.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.user_id
	;
	
ALTER VIEW user_map_to_production_list OWNER TO beton;


-- ******************* update 13/12/2019 13:57:02 ******************
-- Trigger: productions_trigger on productions

-- DROP TRIGGER productions_before_trigger ON productions;
/*
CREATE TRIGGER productions_before_trigger
  BEFORE INSERT
  ON productions
  FOR EACH ROW
  EXECUTE PROCEDURE productions_process();
*/
 DROP TRIGGER productions_after_trigger ON productions;



-- ******************* update 13/12/2019 14:00:14 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
		IF TG_OP='INSERT' OR
			(TG_OP='UPDATE'
			AND (
				OLD.production_vehicle_descr!=NEW.production_vehicle_descr
				OR OLD.pproduction_dt_start!=NEW.production_dt_start
			)
			)
		THEN
			SELECT *
			INTO
				NEW.vehicle_id,
				NEW.vehicle_schedule_state_id,
				NEW.shipment_id
			FROM material_fact_consumptions_find_vehicle(
				NEW.production_vehicle_descr,
				NEW.production_dt_start::timestamp
			) AS (
				vehicle_id int,
				vehicle_schedule_state_id int,
				shipment_id int
			);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_WHEN='AFTER' AND TG_OP='UPDATE' THEN
		
		--ЭТО ДЕЛАЕТСЯ В КОНТРОЛЛЕРЕ Production_Controller->check_data!!!
		--IF OLD.production_dt_end IS NULL
		--AND NEW.production_dt_end IS NOT NULL
		--AND NEW.shipment_id IS NOT NULL THEN
		--END IF;
		RETURN NEW;
		
	ELSEIF TG_WHEN='AFTER' AND TG_OP='DELETE' THEN
		DELETE FROM material_fact_consumptions WHERE production_id = OLD.production_id;
		
		RETURN OLD;
				
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 13/12/2019 14:00:20 ******************
-- Trigger: productions_trigger on productions

 DROP TRIGGER productions_before_trigger ON productions;

CREATE TRIGGER productions_before_trigger
  BEFORE INSERT OR DELETE
  ON productions
  FOR EACH ROW
  EXECUTE PROCEDURE productions_process();



-- ******************* update 13/12/2019 14:00:36 ******************
-- Trigger: productions_trigger on productions

 DROP TRIGGER productions_before_trigger ON productions;

CREATE TRIGGER productions_before_trigger
  BEFORE INSERT OR UPDATE OR DELETE
  ON productions
  FOR EACH ROW
  EXECUTE PROCEDURE productions_process();



-- ******************* update 13/12/2019 14:01:14 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
		IF TG_OP='INSERT' OR
			(TG_OP='UPDATE'
			AND (
				OLD.production_vehicle_descr!=NEW.production_vehicle_descr
				OR OLD.pproduction_dt_start!=NEW.production_dt_start
			)
			)
		THEN
			SELECT *
			INTO
				NEW.vehicle_id,
				NEW.vehicle_schedule_state_id,
				NEW.shipment_id
			FROM material_fact_consumptions_find_vehicle(
				NEW.production_vehicle_descr,
				NEW.production_dt_start::timestamp
			) AS (
				vehicle_id int,
				vehicle_schedule_state_id int,
				shipment_id int
			);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_WHEN='AFTER' AND TG_OP='UPDATE' THEN
		
		--ЭТО ДЕЛАЕТСЯ В КОНТРОЛЛЕРЕ Production_Controller->check_data!!!
		--IF OLD.production_dt_end IS NULL
		--AND NEW.production_dt_end IS NOT NULL
		--AND NEW.shipment_id IS NOT NULL THEN
		--END IF;
		RETURN NEW;
		
	ELSEIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM material_fact_consumptions WHERE production_id = OLD.production_id;
		
		RETURN OLD;
				
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 13/12/2019 14:10:10 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20014',
		'Production_Controller',
		'get_list',
		'ProductionList',
		'Формы',
		'Производство ELKON',
		FALSE
		);
	

-- ******************* update 13/12/2019 14:26:07 ******************
-- VIEW: productions_list

--DROP VIEW productions_list;

CREATE OR REPLACE VIEW productions_list AS
	SELECT
		t.id,
		t.production_id,
		t.production_dt_start,
		t.production_dt_end,
		t.production_user,
		t.production_vehicle_descr,
		t.dt_start_set,
		t.dt_end_set,
		production_sites_ref(ps) AS production_sites_ref,
		shipments_ref(sh) AS shipments_ref,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.production_concrete_type_descr,
		orders_ref(o) AS orders_ref,
		vs.vehicle_id,
		vehicle_schedules_ref(vs,v,dr) AS vehicle_schedules_ref
		
	FROM productions AS t
	LEFT JOIN production_sites AS ps ON ps.id = t.production_site_id
	LEFT JOIN shipments AS sh ON sh.id = t.shipment_id
	LEFT JOIN concrete_types AS ct ON ct.id = t.concrete_type_id
	LEFT JOIN orders AS o ON o.id = sh.order_id
	LEFT JOIN vehicle_schedules AS vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS v ON v.id = vs.vehicle_id
	LEFT JOIN drivers AS dr ON dr.id = vs.driver_id
	ORDER BY t.production_dt_start DESC
	;
	
ALTER VIEW productions_list OWNER TO beton;


-- ******************* update 13/12/2019 17:28:20 ******************

		--constant value table
		CREATE TABLE IF NOT EXISTS const_production_material_quant_tolerance
		(name text, descr text, val int,
			val_type text,ctrl_class text,ctrl_options json, view_class text,view_options json);
		ALTER TABLE const_production_material_quant_tolerance OWNER TO beton;
		INSERT INTO const_production_material_quant_tolerance (name,descr,val,val_type,ctrl_class,ctrl_options,view_class,view_options) VALUES (
			'Процент расхождения в количестве требуемого материала'
			,'Если при загрузке данных производства Elkon имеется расхождение на данную величину в процентах (количество и количество требуемое), то такое расхождение будет отмечено'
			,10
			,'Int'
			,NULL
			,NULL
			,NULL
			,NULL
		);
		--constant get value
		CREATE OR REPLACE FUNCTION const_production_material_quant_tolerance_val()
		RETURNS int AS
		$BODY$
			SELECT val::int AS val FROM const_production_material_quant_tolerance LIMIT 1;
		$BODY$
		LANGUAGE sql STABLE COST 100;
		ALTER FUNCTION const_production_material_quant_tolerance_val() OWNER TO beton;
		--constant set value
		CREATE OR REPLACE FUNCTION const_production_material_quant_tolerance_set_val(Int)
		RETURNS void AS
		$BODY$
			UPDATE const_production_material_quant_tolerance SET val=$1;
		$BODY$
		LANGUAGE sql VOLATILE COST 100;
		ALTER FUNCTION const_production_material_quant_tolerance_set_val(Int) OWNER TO beton;
		--edit view: all keys and descr
		CREATE OR REPLACE VIEW const_production_material_quant_tolerance_view AS
		SELECT
			'production_material_quant_tolerance'::text AS id
			,t.name
			,t.descr
		,
		t.val::text AS val
		,t.val_type::text AS val_type
		,t.ctrl_class::text
		,t.ctrl_options::json
		,t.view_class::text
		,t.view_options::json
		FROM const_production_material_quant_tolerance AS t
		;
		ALTER VIEW const_production_material_quant_tolerance_view OWNER TO beton;
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
		FROM const_low_efficiency_tel_list_view
		UNION ALL
		SELECT *
		FROM const_material_closed_balance_date_view
		UNION ALL
		SELECT *
		FROM const_cement_material_view
		UNION ALL
		SELECT *
		FROM const_production_material_quant_tolerance_view;
		ALTER VIEW constants_list_view OWNER TO beton;
	

-- ******************* update 13/12/2019 17:40:38 ******************

		ALTER TABLE raw_materials ADD COLUMN max_required_quant_tolerance_percent  numeric(19,2);



-- ******************* update 13/12/2019 18:10:56 ******************
-- VIEW: material_fact_consumptions_list

--DROP VIEW material_fact_consumptions_list;

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
		t.material_quant_req,
		
		--Ошибка в марке
		(t.concrete_type_id IS NOT NULL AND t.concrete_type_id<>o.concrete_type_id) AS er_concrete_type,
		ra_mat.quant AS material_quant_shipped,
		(
			(CASE WHEN ra_mat.quant IS NULL OR ra_mat.quant=0 THEN TRUE
				ELSE abs(t.material_quant/ra_mat.quant*100-100)>=mat.max_required_quant_tolerance_percent
			END)
			OR
			(CASE WHEN t.material_quant_req IS NULL OR t.material_quant_req=0 THEN TRUE
				ELSE abs(t.material_quant/t.material_quant_req*100-100)>=mat.max_required_quant_tolerance_percent
			END
			)
		) AS quant_tolerance_exceeded
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	LEFT JOIN vehicle_schedule_states AS vh_sch_st ON vh_sch_st.id=t.vehicle_schedule_state_id
	LEFT JOIN shipments AS sh ON sh.id=vh_sch_st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=sh.id AND ra_mat.material_id=t.raw_material_id
	ORDER BY pr.name,t.date_time,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO beton;


-- ******************* update 13/12/2019 18:19:11 ******************
-- VIEW: material_fact_consumptions_rolled_list

--DROP VIEW material_fact_consumptions_rolled_list;

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
				'quant_req',material_quant_req,
				'quant_shipped',material_quant_shipped,
				'quant_tolerance_exceeded',material_quant_tolerance_exceeded
			)
		) AS materials,
		er_concrete_type
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
		shipments_inf,
		er_concrete_type
	ORDER BY date_time DESC

	;
	
ALTER VIEW material_fact_consumptions_rolled_list OWNER TO beton;


-- ******************* update 13/12/2019 18:27:47 ******************
-- VIEW: material_fact_consumptions_rolled_list

--DROP VIEW material_fact_consumptions_rolled_list;

CREATE OR REPLACE VIEW material_fact_consumptions_rolled_list AS
	SELECT
		date_time,
		upload_date_time,
		(upload_users_ref::text)::jsonb AS upload_users_ref,
		(production_sites_ref::text)::jsonb AS production_sites_ref,
		production_site_id,
		(concrete_types_ref::text)::jsonb AS concrete_types_ref,
		(order_concrete_types_ref::text)::jsonb AS order_concrete_types_ref,
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
				'quant_req',material_quant_req,
				'quant_shipped',material_quant_shipped,
				'quant_tolerance_exceeded',material_quant_tolerance_exceeded
			)
		) AS materials,
		err_concrete_type
	FROM material_fact_consumptions_list
	GROUP BY date_time,
		concrete_quant,
		upload_date_time,
		upload_users_ref::text,
		production_sites_ref::text,
		production_site_id,
		concrete_types_ref::text,
		order_concrete_types_ref::text,
		concrete_type_production_descr,
		vehicles_ref::text,
		vehicle_production_descr,
		orders_ref::text,
		shipments_inf,
		err_concrete_type
	ORDER BY date_time DESC

	;
	
ALTER VIEW material_fact_consumptions_rolled_list OWNER TO beton;


-- ******************* update 21/01/2020 09:23:39 ******************
-- View: public.vehicles_dialog

-- DROP VIEW public.vehicles_dialog;

CREATE OR REPLACE VIEW public.vehicles_dialog2 AS 
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
		
		(SELECT 
			r.f_vals->'fields'->'owner'
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,
		(SELECT 
			(r.f_vals->'fields'->'owner'->'keys'->>'id')::int
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owner_id
		
		
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,		
		--v.vehicle_owner_id
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate
	;

ALTER TABLE public.vehicles_dialog2
  OWNER TO beton;



-- ******************* update 21/01/2020 09:36:04 ******************
-- View: public.vehicles_dialog

-- DROP VIEW public.vehicles_dialog;

CREATE OR REPLACE VIEW public.vehicles_dialog2 AS 
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
		
		(SELECT 
			r.f_vals->'fields'->'owner'
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,
		(SELECT 
			(r.f_vals->'fields'->'owner'->'keys'->>'id')::int
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owner_id
		
		
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,		
		--v.vehicle_owner_id
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate
	;

ALTER TABLE public.vehicles_dialog2
  OWNER TO beton;



-- ******************* update 21/01/2020 09:36:08 ******************
-- View: public.vehicles_dialog

-- DROP VIEW public.vehicles_dialog;

CREATE OR REPLACE VIEW public.vehicles_dialog2 AS 
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
		
		(SELECT 
			r.f_vals->'fields'->'owner'
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,
		(SELECT 
			(r.f_vals->'fields'->'owner'->'keys'->>'id')::int
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owner_id
		
		
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,		
		--v.vehicle_owner_id
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate
	;

ALTER TABLE public.vehicles_dialog2
  OWNER TO beton;



-- ******************* update 21/01/2020 10:10:23 ******************
-- Function: public.vehicles_process()

-- DROP FUNCTION public.vehicles_process();

CREATE OR REPLACE FUNCTION public.vehicles_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		SELECT
			array_agg(
				CASE WHEN sub.obj->'fields'->'owner'->'keys'->>'id'='null' THEN NULL
				ELSE (sub.obj->'fields'->'owner'->'keys'->>'id')::int
				END
			)
		INTO NEW.vehicle_owners_ar
		FROM (
			SELECT jsonb_array_elements(NEW.vehicle_owners->'rows') AS obj
		) AS sub		
		;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicles_process()
  OWNER TO beton;



-- ******************* update 21/01/2020 10:12:31 ******************
-- Trigger: vehicles_before_trigger on vehicles

-- DROP TRIGGER vehicles_after_before ON vehicles;

 CREATE TRIGGER vehicles_before_trigger
  BEFORE INSERT
  ON vehicles
  FOR EACH ROW
  EXECUTE PROCEDURE vehicles_process();
  


-- ******************* update 21/01/2020 10:15:28 ******************
-- Function: public.vehicles_process()

-- DROP FUNCTION public.vehicles_process();

CREATE OR REPLACE FUNCTION public.vehicles_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
	
		IF TG_OP='INSERT' OR NEW.vehicle_owners<>OLD.vehicle_owners THEN
			SELECT
				array_agg(
					CASE WHEN sub.obj->'fields'->'owner'->'keys'->>'id'='null' THEN NULL
					ELSE (sub.obj->'fields'->'owner'->'keys'->>'id')::int
					END
				)
			INTO NEW.vehicle_owners_ar
			FROM (
				SELECT jsonb_array_elements(NEW.vehicle_owners->'rows') AS obj
			) AS sub		
			;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicles_process()
  OWNER TO beton;



-- ******************* update 21/01/2020 10:16:39 ******************
-- Trigger: vehicles_before_trigger on vehicles

 DROP TRIGGER vehicles_before_trigger ON vehicles;

 CREATE TRIGGER vehicles_before_trigger
  BEFORE INSERT OR UPDATE
  ON vehicles
  FOR EACH ROW
  EXECUTE PROCEDURE vehicles_process();
  


-- ******************* update 21/01/2020 10:16:44 ******************
-- Function: public.vehicles_process()

-- DROP FUNCTION public.vehicles_process();

CREATE OR REPLACE FUNCTION public.vehicles_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
	
		IF TG_OP='INSERT' OR NEW.vehicle_owners<>OLD.vehicle_owners THEN
			SELECT
				array_agg(
					CASE WHEN sub.obj->'fields'->'owner'->'keys'->>'id'='null' THEN NULL
					ELSE (sub.obj->'fields'->'owner'->'keys'->>'id')::int
					END
				)
			INTO NEW.vehicle_owners_ar
			FROM (
				SELECT jsonb_array_elements(NEW.vehicle_owners->'rows') AS obj
			) AS sub		
			;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicles_process()
  OWNER TO beton;



-- ******************* update 21/01/2020 10:19:25 ******************
-- Function: public.vehicles_process()

-- DROP FUNCTION public.vehicles_process();

CREATE OR REPLACE FUNCTION public.vehicles_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
	
		IF TG_OP='INSERT' OR (OLD.vehicle_owners IS NULL AND NEW.vehicle_owners IS NOT NULL) OR NEW.vehicle_owners<>OLD.vehicle_owners THEN
			SELECT
				array_agg(
					CASE WHEN sub.obj->'fields'->'owner'->'keys'->>'id'='null' THEN NULL
					ELSE (sub.obj->'fields'->'owner'->'keys'->>'id')::int
					END
				)
			INTO NEW.vehicle_owners_ar
			FROM (
				SELECT jsonb_array_elements(NEW.vehicle_owners->'rows') AS obj
			) AS sub		
			;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicles_process()
  OWNER TO beton;



-- ******************* update 21/01/2020 10:20:32 ******************
-- View: public.vehicles_dialog

-- DROP VIEW public.vehicles_dialog;

CREATE OR REPLACE VIEW public.vehicles_dialog2 AS 
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
		
		(SELECT 
			r.f_vals->'fields'->'owner'
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,
		(SELECT 
			(r.f_vals->'fields'->'owner'->'keys'->>'id')::int
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owner_id,
		
		v.vehicle_owners_ar
		
		
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,		
		--v.vehicle_owner_id
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate
	;

ALTER TABLE public.vehicles_dialog2
  OWNER TO beton;



-- ******************* update 21/01/2020 10:35:56 ******************
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
			(owners.r->'fields'->'owner'->'keys'->>'id')::int
		FROM
		(
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS r
		) AS owners
		ORDER BY owners.r->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owner_id,
		
		
		pv.phone_cels,
		pv.pump_prices
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_list
  OWNER TO beton;



-- ******************* update 21/01/2020 10:36:13 ******************
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
			(owners.r->'fields'->'owner'->'keys'->>'id')::int
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



-- ******************* update 21/01/2020 10:39:07 ******************
-- View: public.pump_veh_work_list

-- DROP VIEW public.pump_veh_work_list;
-- CASCADE;

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
		--v.vehicle_owner_id AS pump_vehicle_owner_id,
		(SELECT
			(owners.r->'fields'->'owner'->'keys'->>'id')::int
		FROM
		(
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS r
		) AS owners
		ORDER BY owners.r->'fields'->'dt_from' DESC
		LIMIT 1
		) AS pump_vehicle_owner_id,		
		
		pv.phone_cels,
		pv.pump_prices,
		
		v.vehicle_owners_ar AS pump_vehicle_owners_ar
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	WHERE coalesce(pv.deleted,FALSE)=FALSE	
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_work_list
  OWNER TO beton;



-- ******************* update 21/01/2020 11:12:29 ******************
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
		
		--vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		(SELECT
			owners.r->'fields'->'owner'
		FROM
		(
			SELECT jsonb_array_elements(pvh_v.vehicle_owners->'rows') AS r
		) AS owners
		WHERE (owners.r->'fields'->>'dt_from')::timestamp without time zone < o.date_time
		ORDER BY (owners.r->'fields'->>'dt_from')::timestamp without time zone DESC
		LIMIT 1
		) AS pump_vehicle_owners_ref,
		
		pvh.vehicle_id AS pump_vehicle_id,
		
		--pvh_v.vehicle_owner_id AS pump_vehicle_owner_id
		(SELECT
			(owners.r->'fields'->'owner'->'keys'->>'id')::int
		FROM
		(
			SELECT jsonb_array_elements(pvh_v.vehicle_owners->'rows') AS r
		) AS owners
		WHERE (owners.r->'fields'->>'dt_from')::timestamp without time zone < o.date_time
		ORDER BY (owners.r->'fields'->>'dt_from')::timestamp without time zone DESC
		LIMIT 1
		) AS pump_vehicle_owner_id
		
		
	FROM orders o
	LEFT JOIN order_pumps op ON o.id = op.order_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations d ON d.id = o.destination_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	--LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	
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



-- ******************* update 21/01/2020 11:16:38 ******************
-- View: public.vehicles_dialog

 DROP VIEW public.vehicles_dialog;

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
		
		(SELECT 
			r.f_vals->'fields'->'owner'
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,
		(SELECT 
			(r.f_vals->'fields'->'owner'->'keys'->>'id')::int
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owner_id,
		
		v.vehicle_owners_ar
		
		
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,		
		--v.vehicle_owner_id
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate
	;

ALTER TABLE public.vehicles_dialog
  OWNER TO beton;



-- ******************* update 21/01/2020 11:49:43 ******************
-- View: public.shipments_pump_list

-- DROP VIEW public.shipments_pump_list;

CREATE OR REPLACE VIEW public.shipments_pump_list AS 
	SELECT
		o.id AS order_id,
		sh_last.id AS last_ship_id,
		order_num(o.*) AS order_number,
		o.date_time,
		o.quant,
		o.concrete_type_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		
		sh_last.acc_comment,
		sh_last.owner_pump_agreed_date_time,
		sh_last.owner_pump_agreed,
		
		(CASE
			WHEN coalesce(sh_last.pump_cost_edit,FALSE) THEN sh_last.pump_cost
			--last ship only!!!
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
		END)::numeric AS pump_cost,
		/*
		shipments_pump_cost(
			(SELECT shipments FROM shipments WHERE shipments.id=sh_last.id),
			o,dest,pvh,
			TRUE
		) AS pump_cost,
		*/
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh_last.production_site_id
		
		
		
	FROM orders AS o
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN (
		SELECT
			max(sh.ship_date_time) AS ship_date_time,
			sh.order_id,
			sum(sh.quant) AS quant
		FROM shipments AS sh
		GROUP BY sh.order_id
	) AS sh ON sh.order_id = o.id
	LEFT JOIN (
		SELECT
			sh.id,
			sh.ship_date_time,
			sh.order_id,
			sh.acc_comment,
			sh.pump_cost_edit,
			sh.pump_cost,
			sh.owner_pump_agreed,
			sh.owner_pump_agreed_date_time,
			sh.production_site_id
		FROM shipments AS sh
	) AS sh_last ON sh_last.order_id = sh.order_id AND sh_last.ship_date_time = sh.ship_date_time
	LEFT JOIN production_sites ps ON ps.id = sh_last.production_site_id
	
	WHERE
		o.pump_vehicle_id IS NOT NULL
		AND coalesce(o.quant)>0
		AND o.quant=sh.quant
		
	ORDER BY o.date_time DESC
	;
ALTER TABLE public.shipments_pump_list
  OWNER TO beton;



-- ******************* update 21/01/2020 11:56:15 ******************
-- View: public.shipments_pump_list

-- DROP VIEW public.shipments_pump_list;

CREATE OR REPLACE VIEW public.shipments_pump_list AS 
	SELECT
		o.id AS order_id,
		sh_last.id AS last_ship_id,
		order_num(o.*) AS order_number,
		o.date_time,
		o.quant,
		o.concrete_type_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		
		sh_last.acc_comment,
		sh_last.owner_pump_agreed_date_time,
		sh_last.owner_pump_agreed,
		
		(CASE
			WHEN coalesce(sh_last.pump_cost_edit,FALSE) THEN sh_last.pump_cost
			--last ship only!!!
			WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
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
				)
		END)::numeric AS pump_cost,
		/*
		shipments_pump_cost(
			(SELECT shipments FROM shipments WHERE shipments.id=sh_last.id),
			o,dest,pvh,
			TRUE
		) AS pump_cost,
		*/
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh_last.production_site_id
		
		
		
	FROM orders AS o
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN (
		SELECT
			max(sh.ship_date_time) AS ship_date_time,
			sh.order_id,
			sum(sh.quant) AS quant
		FROM shipments AS sh
		GROUP BY sh.order_id
	) AS sh ON sh.order_id = o.id
	LEFT JOIN (
		SELECT
			sh.id,
			sh.ship_date_time,
			sh.order_id,
			sh.acc_comment,
			sh.pump_cost_edit,
			sh.pump_cost,
			sh.owner_pump_agreed,
			sh.owner_pump_agreed_date_time,
			sh.production_site_id
		FROM shipments AS sh
	) AS sh_last ON sh_last.order_id = sh.order_id AND sh_last.ship_date_time = sh.ship_date_time
	LEFT JOIN production_sites ps ON ps.id = sh_last.production_site_id
	
	WHERE
		o.pump_vehicle_id IS NOT NULL
		AND coalesce(o.quant)>0
		AND o.quant=sh.quant
		
	ORDER BY o.date_time DESC
	;
ALTER TABLE public.shipments_pump_list
  OWNER TO beton;



-- ******************* update 21/01/2020 12:00:38 ******************
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
						WHERE pr_vals.pump_price_id =(pump_vehicle_price_on_date(in_pump_vehicles.pump_prices,in_shipments.date_time)->'keys'->>'id')::int
							--in_pump_vehicles.pump_price_id
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



-- ******************* update 21/01/2020 12:01:54 ******************
-- View: public.shipments_pump_list

-- DROP VIEW public.shipments_pump_list;

CREATE OR REPLACE VIEW public.shipments_pump_list AS 
	SELECT
		o.id AS order_id,
		sh_last.id AS last_ship_id,
		order_num(o.*) AS order_number,
		o.date_time,
		o.quant,
		o.concrete_type_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		
		sh_last.acc_comment,
		sh_last.owner_pump_agreed_date_time,
		sh_last.owner_pump_agreed,
		
		(CASE
			WHEN coalesce(sh_last.pump_cost_edit,FALSE) THEN sh_last.pump_cost
			--last ship only!!!
			WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = (pump_vehicle_price_on_date(pvh.pump_prices,sh_last.ship_date_time)->'keys'->>'id')::int
					--pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)
		END)::numeric AS pump_cost,
		/*
		shipments_pump_cost(
			(SELECT shipments FROM shipments WHERE shipments.id=sh_last.id),
			o,dest,pvh,
			TRUE
		) AS pump_cost,
		*/
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh_last.production_site_id
		
		
		
	FROM orders AS o
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN (
		SELECT
			max(sh.ship_date_time) AS ship_date_time,
			sh.order_id,
			sum(sh.quant) AS quant
		FROM shipments AS sh
		GROUP BY sh.order_id
	) AS sh ON sh.order_id = o.id
	LEFT JOIN (
		SELECT
			sh.id,
			sh.ship_date_time,
			sh.order_id,
			sh.acc_comment,
			sh.pump_cost_edit,
			sh.pump_cost,
			sh.owner_pump_agreed,
			sh.owner_pump_agreed_date_time,
			sh.production_site_id
		FROM shipments AS sh
	) AS sh_last ON sh_last.order_id = sh.order_id AND sh_last.ship_date_time = sh.ship_date_time
	LEFT JOIN production_sites ps ON ps.id = sh_last.production_site_id
	
	WHERE
		o.pump_vehicle_id IS NOT NULL
		AND coalesce(o.quant)>0
		AND o.quant=sh.quant
		
	ORDER BY o.date_time DESC
	;
ALTER TABLE public.shipments_pump_list
  OWNER TO beton;



-- ******************* update 21/01/2020 12:02:21 ******************
-- View: public.shipments_pump_list

-- DROP VIEW public.shipments_pump_list;

CREATE OR REPLACE VIEW public.shipments_pump_list AS 
	SELECT
		o.id AS order_id,
		sh_last.id AS last_ship_id,
		order_num(o.*) AS order_number,
		o.date_time,
		o.quant,
		o.concrete_type_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		destinations_ref(dest) As destinations_ref,
		o.destination_id,
		pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
		vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		pvh.vehicle_id AS pump_vehicle_id,
		pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
		
		sh_last.acc_comment,
		sh_last.owner_pump_agreed_date_time,
		sh_last.owner_pump_agreed,
		/*
		(CASE
			WHEN coalesce(sh_last.pump_cost_edit,FALSE) THEN sh_last.pump_cost
			--last ship only!!!
			WHEN coalesce(o.unload_price,0)>0 THEN o.unload_price
			ELSE
				(SELECT
					CASE
						WHEN coalesce(pr_vals.price_fixed,0)>0 THEN pr_vals.price_fixed
						ELSE coalesce(pr_vals.price_m,0)*o.quant
					END
				FROM pump_prices_values AS pr_vals
				WHERE pr_vals.pump_price_id = (pump_vehicle_price_on_date(pvh.pump_prices,sh_last.ship_date_time)->'keys'->>'id')::int
					--pvh.pump_price_id
					AND o.quant<=pr_vals.quant_to
				ORDER BY pr_vals.quant_to ASC
				LIMIT 1
				)
		END)::numeric AS pump_cost,
		*/
		shipments_pump_cost(
			(SELECT shipments FROM shipments WHERE shipments.id=sh_last.id),
			o,dest,pvh,
			TRUE
		) AS pump_cost,
		
		clients_ref(cl) As clients_ref,
		o.client_id,
		
		users_ref(u) As users_ref,
		o.user_id,
		
		production_sites_ref(ps) AS production_sites_ref,
		sh_last.production_site_id
		
		
		
	FROM orders AS o
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
	LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
	LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN users u ON u.id = o.user_id
	LEFT JOIN (
		SELECT
			max(sh.ship_date_time) AS ship_date_time,
			sh.order_id,
			sum(sh.quant) AS quant
		FROM shipments AS sh
		GROUP BY sh.order_id
	) AS sh ON sh.order_id = o.id
	LEFT JOIN (
		SELECT
			sh.id,
			sh.ship_date_time,
			sh.order_id,
			sh.acc_comment,
			sh.pump_cost_edit,
			sh.pump_cost,
			sh.owner_pump_agreed,
			sh.owner_pump_agreed_date_time,
			sh.production_site_id
		FROM shipments AS sh
	) AS sh_last ON sh_last.order_id = sh.order_id AND sh_last.ship_date_time = sh.ship_date_time
	LEFT JOIN production_sites ps ON ps.id = sh_last.production_site_id
	
	WHERE
		o.pump_vehicle_id IS NOT NULL
		AND coalesce(o.quant)>0
		AND o.quant=sh.quant
		
	ORDER BY o.date_time DESC
	;
ALTER TABLE public.shipments_pump_list
  OWNER TO beton;



-- ******************* update 23/01/2020 11:33:59 ******************
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
		
		(SELECT 
			r.f_vals->'fields'->'owner'
		FROM (
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS f_vals
		) AS r
		ORDER BY r.f_vals->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,
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
		
		v.vehicle_owners_ar
		
		
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,		
		--v.vehicle_owner_id
		
	FROM vehicles v
	LEFT JOIN drivers dr ON dr.id = v.driver_id
	--LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	ORDER BY v.plate
	;

ALTER TABLE public.vehicles_dialog
  OWNER TO beton;



-- ******************* update 23/01/2020 11:51:12 ******************
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



-- ******************* update 24/01/2020 09:40:14 ******************
-- Function: public.vehicles_process()

-- DROP FUNCTION public.vehicles_process();

CREATE OR REPLACE FUNCTION public.vehicles_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
	
		IF TG_OP='INSERT' OR (OLD.vehicle_owners IS NULL AND NEW.vehicle_owners IS NOT NULL) OR NEW.vehicle_owners<>OLD.vehicle_owners THEN
			SELECT
				array_agg(
					CASE WHEN sub.obj->'fields'->'owner'->'keys'->>'id'='null' THEN NULL
					ELSE (sub.obj->'fields'->'owner'->'keys'->>'id')::int
					END
				)
			INTO NEW.vehicle_owners_ar
			FROM (
				SELECT jsonb_array_elements(NEW.vehicle_owners->'rows') AS obj
			) AS sub		
			;
			
			--last owner
			SELECT
				CASE WHEN owners.row->'fields'->'owner'->'keys'->>'id'='null' THEN NULL 
					ELSE (owners.row->'fields'->'owner'->'keys'->>'id')::int
				END
			INTO NEW.vehicle_owner_id
			FROM
			(
				SELECT jsonb_array_elements(vehicle_owners->'rows') AS row
			) AS owners
			ORDER BY (owners.row->'fields'->>'dt_from')::timestamp DESC
			LIMIT 1;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicles_process()
  OWNER TO beton;



-- ******************* update 24/01/2020 09:40:41 ******************
-- Function: public.vehicles_process()

-- DROP FUNCTION public.vehicles_process();

CREATE OR REPLACE FUNCTION public.vehicles_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
	
		IF TG_OP='INSERT' OR (OLD.vehicle_owners IS NULL AND NEW.vehicle_owners IS NOT NULL) OR NEW.vehicle_owners<>OLD.vehicle_owners THEN
			SELECT
				array_agg(
					CASE WHEN sub.obj->'fields'->'owner'->'keys'->>'id'='null' THEN NULL
					ELSE (sub.obj->'fields'->'owner'->'keys'->>'id')::int
					END
				)
			INTO NEW.vehicle_owners_ar
			FROM (
				SELECT jsonb_array_elements(NEW.vehicle_owners->'rows') AS obj
			) AS sub		
			;
			
			--last owner
			SELECT
				CASE WHEN owners.row->'fields'->'owner'->'keys'->>'id'='null' THEN NULL 
					ELSE (owners.row->'fields'->'owner'->'keys'->>'id')::int
				END
			INTO NEW.vehicle_owner_id
			FROM
			(
				SELECT jsonb_array_elements(NEW.vehicle_owners->'rows') AS row
			) AS owners
			ORDER BY (owners.row->'fields'->>'dt_from')::timestamp DESC
			LIMIT 1;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.vehicles_process()
  OWNER TO beton;



-- ******************* update 24/01/2020 09:43:30 ******************
-- View: public.vehicles_dialog

 DROP VIEW public.vehicles_dialog;

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



-- ******************* update 24/01/2020 09:45:02 ******************
-- View: public.pump_veh_work_list

 DROP VIEW public.pump_veh_work_list;
-- CASCADE;

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
		/*
		(SELECT
			owners.r->'fields'->'owner'
		FROM
		(
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS r
		) AS owners
		ORDER BY owners.r->'fields'->'dt_from' DESC
		LIMIT 1
		) AS vehicle_owners_ref,		
		*/
		
		v.vehicle_owner_id AS pump_vehicle_owner_id,
		/*
		(SELECT
			(owners.r->'fields'->'owner'->'keys'->>'id')::int
		FROM
		(
			SELECT jsonb_array_elements(v.vehicle_owners->'rows') AS r
		) AS owners
		ORDER BY owners.r->'fields'->'dt_from' DESC
		LIMIT 1
		) AS pump_vehicle_owner_id,		
		*/
		
		pv.phone_cels,
		pv.pump_prices,
		
		v.vehicle_owners_ar AS pump_vehicle_owners_ar
		
	FROM pump_vehicles pv
	LEFT JOIN vehicles v ON v.id = pv.vehicle_id
	LEFT JOIN pump_prices ppr ON ppr.id = pv.pump_price_id
	LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
	WHERE coalesce(pv.deleted,FALSE)=FALSE	
	ORDER BY v.plate;

ALTER TABLE public.pump_veh_work_list
  OWNER TO beton;



-- ******************* update 04/02/2020 11:17:57 ******************
-- VIEW: material_fact_consumption_corrections_list

--DROP VIEW material_fact_consumption_corrections_list;

CREATE OR REPLACE VIEW material_fact_consumption_corrections_list AS
	SELECT
		t.id,
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.date_time,
		t.date_time_set,
		t.user_id,
		users_ref(u) AS users_ref,
		material_id,
		materials_ref(m) AS materials_ref,
		t.cement_silo_id,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.production_id,
		t.elkon_id,
		t.quant
		
	FROM material_fact_consumption_corrections AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.user_id
	LEFT JOIN raw_materials AS m ON m.id=t.material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	;
	
ALTER VIEW material_fact_consumption_corrections_list OWNER TO beton;


-- ******************* update 04/02/2020 11:50:02 ******************
-- VIEW: material_fact_consumption_corrections_list

--DROP VIEW material_fact_consumption_corrections_list;

CREATE OR REPLACE VIEW material_fact_consumption_corrections_list AS
	SELECT
		t.id,
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.date_time,
		t.date_time_set,
		t.user_id,
		users_ref(u) AS users_ref,
		material_id,
		materials_ref(m) AS materials_ref,
		t.cement_silo_id,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.production_id,
		t.elkon_id,
		t.quant
		
	FROM material_fact_consumption_corrections AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.user_id
	LEFT JOIN raw_materials AS m ON m.id=t.material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW material_fact_consumption_corrections_list OWNER TO beton;


-- ******************* update 10/02/2020 08:50:53 ******************
-- Function: public.pump_vehicles_ref(pump_vehicles,vehicles)

-- DROP FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles);

CREATE OR REPLACE FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',coalesce($2.plate::text,'')||' '||coalesce($2.make::text,'')||coalesce(' ('||$1.pump_length::text||')',''),		
		'dataType','pump_vehicles'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles) OWNER TO beton;



-- ******************* update 10/02/2020 08:58:19 ******************
-- Function: public.pump_vehicles_ref(pump_vehicles,vehicles)

-- DROP FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles);

CREATE OR REPLACE FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles,vehicle_owners)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',coalesce($2.plate::text,'')||' '||coalesce($2.make::text,'')||coalesce(' ('||$1.pump_length::text||coalesce(', '||$3.name::text,'')||')',''),		
		'dataType','pump_vehicles'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles) OWNER TO beton;



-- ******************* update 10/02/2020 08:58:31 ******************
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
		
		--vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		vehicle_owner_on_date(v.vehicle_owners,sh.date_time) AS vehicle_owners_ref,
		
		sh.acc_comment,
		sh.acc_comment_shipment,
		--v_own.id AS vehicle_owner_id,
		((vehicle_owner_on_date(v.vehicle_owners,sh.date_time))->'keys'->>'id')::int AS vehicle_owner_id,
		
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
							WHERE pr_vals.pump_price_id = (pump_vehicle_price_on_date(pvh.pump_prices,sh.date_time)->'keys'->>'id')::int
								--pvh.pump_price_id
								AND o.quant<=pr_vals.quant_to
							ORDER BY pr_vals.quant_to ASC
							LIMIT 1
							)::numeric(15,2)
					END
				ELSE 0	
			END
		) AS pump_cost,
		
		pump_vehicles_ref(pvh,pvh_v,pvh_own) AS pump_vehicles_ref,
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
							WHERE pr_vals.pump_price_id = (pump_vehicle_price_on_date(pvh.pump_prices,sh.date_time)->'keys'->>'id')::int
								--pvh.pump_price_id
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



-- ******************* update 10/02/2020 09:02:20 ******************
-- Function: capit_first_letter(text)

--DROP FUNCTION capit_first_letter(text);

CREATE OR REPLACE FUNCTION capit_first_letter(text)
  RETURNS text AS
$BODY$
	SELECT 
		upper(substr($1,1,1)) ||
		lower(substr($1,2));	
$BODY$
LANGUAGE sql IMMUTABLE COST 100;
ALTER FUNCTION capit_first_letter(text) OWNER TO beton;


-- ******************* update 10/02/2020 09:02:23 ******************
-- Function: parse_person_name(text)

--DROP FUNCTION parse_person_name(text);

/*
SELECT
	first,second,middle
FROM parse_person_name('Михалевич Андрей Александрович')
	AS (first text,second text,middle text)
*/

CREATE OR REPLACE FUNCTION parse_person_name(text)
  RETURNS RECORD AS
$BODY$
	SELECT
		CASE
			WHEN position(' ' in $1)=0 THEN
				--нет Имя,отчество
				ROW(capit_first_letter($1)::text,''::text,''::text)
			ELSE
				CASE
					WHEN position(' ' in substr($1,position(' ' in $1)+1 ))=0 THEN
						--нет отчество
						ROW(
							capit_first_letter(substr($1,1,position(' ' in $1))::text),
							capit_first_letter(substr($1,position(' ' in $1)+1)::text),
							''::text
						)
					ELSE
						--есть все
						ROW(
							capit_first_letter(substr($1,1,position(' ' in $1)-1)::text),
							
							capit_first_letter(
							substr($1,position(' ' in $1)+1,
							   position(' ' in 
								substr($1,position(' ' in $1)+1)
								)-1		
							)::text
							),
							
							capit_first_letter(
								substr(substr($1,position(' ' in $1)+1),position(' ' in substr($1,position(' ' in $1)+1))+1)::text
							)
						)								
				END
		END
$BODY$
LANGUAGE sql IMMUTABLE COST 100;
ALTER FUNCTION parse_person_name(text) OWNER TO beton;


-- ******************* update 10/02/2020 09:03:40 ******************
-- Function: person_init(text)

--DROP FUNCTION person_init(text);

CREATE OR REPLACE FUNCTION person_init(text)
  RETURNS TEXT AS
$BODY$
	SELECT
		first||
		CASE WHEN length(second)>0 THEN ' '||substr(second,1,1)||'.' ELSE '' END||
		CASE WHEN length(middle)>0 THEN ' '||substr(middle,1,1)||'.' ELSE '' END
	FROM parse_person_name($1)
	AS (first text,second text,middle text)
$BODY$
LANGUAGE sql IMMUTABLE COST 100;
ALTER FUNCTION person_init(text) OWNER TO beton;


-- ******************* update 10/02/2020 09:04:03 ******************
-- Function: public.pump_vehicles_ref(pump_vehicles,vehicles)

-- DROP FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles);

CREATE OR REPLACE FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles,vehicle_owners)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',coalesce($2.plate::text,'')||' '||coalesce($2.make::text,'')||coalesce(' ('||$1.pump_length::text||coalesce(', '||person_init($3.name)::text,'')||')',''),		
		'dataType','pump_vehicles'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.pump_vehicles_ref(pump_vehicles,vehicles) OWNER TO beton;



-- ******************* update 11/02/2020 09:28:49 ******************
-- Function: public.mat_totals(date)

 DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_next_morn_balance numeric,--use instead  	
  	quant_cur_morn_balance numeric
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_next_morn_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_cur_morn_balance
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 11/02/2020 09:32:35 ******************
-- Function: public.mat_totals(date)

 DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 11/02/2020 13:46:15 ******************
-- VIEW: operator_production_detail_list

--DROP VIEW operator_production_detail_list;

CREATE OR REPLACE VIEW operator_production_detail_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		materials_ref(mat) AS materials_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW operator_production_detail_list OWNER TO beton;


-- ******************* update 11/02/2020 14:09:55 ******************
-- VIEW: operator_production_detail_list

DROP VIEW operator_production_detail_list;
/*
CREATE OR REPLACE VIEW operator_production_detail_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		materials_ref(mat) AS materials_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW operator_production_detail_list OWNER TO beton;
*/


-- ******************* update 11/02/2020 14:10:19 ******************
-- VIEW: production_detail_list

--DROP VIEW production_detail_list;

CREATE OR REPLACE VIEW production_detail_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		materials_ref(mat) AS materials_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_detail_list OWNER TO beton;



-- ******************* update 11/02/2020 14:14:04 ******************
-- VIEW: production_detail_list

DROP VIEW production_detail_list;
/*
CREATE OR REPLACE VIEW production_detail_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		materials_ref(mat) AS materials_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_detail_list OWNER TO beton;
*/


-- ******************* update 11/02/2020 14:14:27 ******************
-- VIEW: production_material_list

--DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		materials_ref(mat) AS materials_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 11/02/2020 14:20:27 ******************
-- VIEW: production_material_list

--DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		materials_ref(mat) AS materials_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		t_cor.quant AS quant_corrected
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 11/02/2020 14:21:43 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		t_cor.quant AS quant_corrected
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 11/02/2020 14:37:40 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'20016',
		'Production_Controller',
		'get_production_material_list',
		'ProductionMaterialList',
		'Формы',
		'Производство ELKON (материалы)',
		FALSE
		);
	

-- ******************* update 11/02/2020 15:58:08 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		t_cor.quant AS quant_corrected
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 11/02/2020 16:16:35 ******************
-- Function: public.productions_process()

-- DROP FUNCTION public.productions_process();

CREATE OR REPLACE FUNCTION public.productions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	
	IF TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN
		IF TG_OP='INSERT' OR
			(TG_OP='UPDATE'
			AND (
				OLD.production_vehicle_descr!=NEW.production_vehicle_descr
				OR OLD.production_dt_start!=NEW.production_dt_start
			)
			)
		THEN
			SELECT *
			INTO
				NEW.vehicle_id,
				NEW.vehicle_schedule_state_id,
				NEW.shipment_id
			FROM material_fact_consumptions_find_vehicle(
				NEW.production_vehicle_descr,
				NEW.production_dt_start::timestamp
			) AS (
				vehicle_id int,
				vehicle_schedule_state_id int,
				shipment_id int
			);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_WHEN='AFTER' AND TG_OP='UPDATE' THEN
		
		--ЭТО ДЕЛАЕТСЯ В КОНТРОЛЛЕРЕ Production_Controller->check_data!!!
		--IF OLD.production_dt_end IS NULL
		--AND NEW.production_dt_end IS NOT NULL
		--AND NEW.shipment_id IS NOT NULL THEN
		--END IF;
		RETURN NEW;
		
	ELSEIF TG_WHEN='BEFORE' AND TG_OP='DELETE' THEN
		DELETE FROM material_fact_consumptions WHERE production_id = OLD.production_id;
		
		RETURN OLD;
				
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.productions_process() OWNER TO beton;



-- ******************* update 11/02/2020 16:27:15 ******************
-- VIEW: productions_list

DROP VIEW productions_list;

CREATE OR REPLACE VIEW productions_list AS
	SELECT
		t.id,
		t.production_id,
		t.production_site_id,
		t.production_dt_start,
		t.production_dt_end,
		t.production_user,
		t.production_vehicle_descr,
		t.dt_start_set,
		t.dt_end_set,
		production_sites_ref(ps) AS production_sites_ref,
		shipments_ref(sh) AS shipments_ref,
		concrete_types_ref(ct) AS concrete_types_ref,
		t.production_concrete_type_descr,
		orders_ref(o) AS orders_ref,
		vs.vehicle_id,
		vehicle_schedules_ref(vs,v,dr) AS vehicle_schedules_ref
		
	FROM productions AS t
	LEFT JOIN production_sites AS ps ON ps.id = t.production_site_id
	LEFT JOIN shipments AS sh ON sh.id = t.shipment_id
	LEFT JOIN concrete_types AS ct ON ct.id = t.concrete_type_id
	LEFT JOIN orders AS o ON o.id = sh.order_id
	LEFT JOIN vehicle_schedules AS vs ON vs.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS v ON v.id = vs.vehicle_id
	LEFT JOIN drivers AS dr ON dr.id = vs.driver_id
	ORDER BY t.production_dt_start DESC
	;
	
ALTER VIEW productions_list OWNER TO beton;


-- ******************* update 11/02/2020 17:26:40 ******************
-- VIEW: production_material_list

--DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		t_cor.quant AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 11/02/2020 17:34:51 ******************
-- VIEW: production_material_list

--DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		t_cor.quant AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 11/02/2020 17:49:37 ******************

		ALTER TABLE raw_materials ADD COLUMN max_fact_quant_tolerance_percent  numeric(19,2);



-- ******************* update 11/02/2020 17:53:37 ******************
-- VIEW: production_material_list

--DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		t_cor.quant AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + t_cor.quant) as quant_dif,
		
		((ra_mat.quant - (t.material_quant + t_cor.quant)) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent) AS dif_violation
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 11/02/2020 17:55:34 ******************
-- VIEW: production_material_list

--DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		t_cor.quant AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + t_cor.quant) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + t_cor.quant)) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 12/02/2020 09:37:00 ******************

		ALTER TABLE material_fact_consumption_corrections ADD COLUMN comment_text text;



-- ******************* update 12/02/2020 09:38:04 ******************
-- VIEW: material_fact_consumption_corrections_list

--DROP VIEW material_fact_consumption_corrections_list;

CREATE OR REPLACE VIEW material_fact_consumption_corrections_list AS
	SELECT
		t.id,
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.date_time,
		t.date_time_set,
		t.user_id,
		users_ref(u) AS users_ref,
		material_id,
		materials_ref(m) AS materials_ref,
		t.cement_silo_id,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.production_id,
		t.elkon_id,
		t.quant,
		
		t.comment_text
		
	FROM material_fact_consumption_corrections AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.user_id
	LEFT JOIN raw_materials AS m ON m.id=t.material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW material_fact_consumption_corrections_list OWNER TO beton;


-- ******************* update 12/02/2020 09:55:21 ******************

					ALTER TYPE doc_types ADD VALUE 'material_fact_consumption_correction';
	/* function */
	CREATE OR REPLACE FUNCTION enum_doc_types_val(doc_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='material_procurement'::doc_types AND $2='ru'::locales THEN 'Поступление материалов'
		WHEN $1='shipment'::doc_types AND $2='ru'::locales THEN 'Отгрузка'
		WHEN $1='material_fact_consumption'::doc_types AND $2='ru'::locales THEN 'Фактический расход материалов'
		WHEN $1='material_fact_consumption_correction'::doc_types AND $2='ru'::locales THEN 'Корректировка фактического расхода материалов'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_doc_types_val(doc_types,locales) OWNER TO beton;		
		

-- ******************* update 12/02/2020 10:48:41 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		--
		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
				- NEW.required_balance_quant;
		--register actions ra_material_facts
		reg_material_facts.date_time		= ra_date_time;
		reg_material_facts.deb			= (add_quant>0);
		reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
		reg_material_facts.doc_id  		= NEW.id;
		reg_material_facts.material_id		= NEW.material_id;
		reg_material_facts.quant		= abs(add_quant);
		PERFORM ra_material_facts_add_act(reg_material_facts);	
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 12/02/2020 10:48:44 ******************
-- Trigger: material_fact_balance_corrections_trigger_before on public.material_fact_balance_corrections

-- DROP TRIGGER material_fact_balance_corrections_trigger_before ON public.material_fact_balance_corrections;

CREATE TRIGGER material_fact_balance_corrections_trigger_before
  BEFORE INSERT OR UPDATE OR DELETE
  ON public.material_fact_balance_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_balance_corrections_process();



-- ******************* update 12/02/2020 10:49:20 ******************
-- Trigger: material_fact_balance_corrections_trigger_before on public.material_fact_balance_corrections

-- DROP TRIGGER material_fact_balance_corrections_trigger_before ON public.material_fact_balance_corrections;

/*
CREATE TRIGGER material_fact_balance_corrections_trigger_before
  BEFORE INSERT OR UPDATE OR DELETE
  ON public.material_fact_balance_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_balance_corrections_process();
*/

-- DROP TRIGGER material_fact_balance_corrections_trigger_after ON public.material_fact_balance_corrections;

CREATE TRIGGER material_fact_balance_corrections_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_balance_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_balance_corrections_process();



-- ******************* update 12/02/2020 11:00:56 ******************
-- VIEW: material_fact_balance_corrections_list

--DROP VIEW material_fact_balance_corrections_list;

CREATE OR REPLACE VIEW material_fact_balance_corrections_list AS
	SELECT
		t.id,
		t.date_time,
		t.balance_date_time,
		t.user_id,
		users_ref(u) AS users_ref,
		t.material_id,
		materials_ref(mat) AS materials_ref,
		t.required_balance_quant,
		t.comment_text
		
	FROM material_fact_balance_corrections t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN raw_materials mat ON mat.id=t.material_id	
	;
	
ALTER VIEW material_fact_balance_corrections_list OWNER TO beton;


-- ******************* update 12/02/2020 11:09:23 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10042',
		'MaterialFactBalanceCorretion_Controller',
		'get_list',
		'MaterialFactBalanceCorretionList',
		'Формы',
		'Корректировки фактических остатков материалов',
		FALSE
		);
	

-- ******************* update 12/02/2020 11:16:16 ******************
-- VIEW: material_fact_balance_corrections_list

--DROP VIEW material_fact_balance_corrections_list;

CREATE OR REPLACE VIEW material_fact_balance_corrections_list AS
	SELECT
		t.id,
		t.date_time,
		t.balance_date_time,
		t.user_id,
		users_ref(u) AS users_ref,
		t.material_id,
		materials_ref(mat) AS materials_ref,
		t.required_balance_quant,
		t.comment_text
		
	FROM material_fact_balance_corrections t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN raw_materials mat ON mat.id=t.material_id	
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW material_fact_balance_corrections_list OWNER TO beton;


-- ******************* update 12/02/2020 11:57:36 ******************
-- Function: public.mat_totals(date)

 DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	balance_corrected_data json[]
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		
		--Корректировки
		(SELECT
			array_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'material_id',cr.material_id,
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 12/02/2020 12:35:04 ******************
-- Function: public.mat_totals(date)

 DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	balance_corrected_data json
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		
		--Корректировки
		(SELECT
			json_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'material_id',cr.material_id,
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 12/02/2020 12:41:00 ******************
-- Function: public.mat_totals(date)

-- DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	balance_corrected_data json
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		
		--Корректировки
		(SELECT
			json_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'materials_ref',materials_ref(m),
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 25/02/2020 09:50:47 ******************
-- Function: public.users_process()

-- DROP FUNCTION public.users_process();

CREATE OR REPLACE FUNCTION public.users_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		DELETE FROM logins
		WHERE user_id = OLD.id;
		
		RETURN OLD;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE') THEN
		--remove sessions
		IF (NEW.banned) THEN
			DELETE FROM sessions WHERE id IN (
				SELECT session_id FROM logins
				WHERE user_id=NEW.id
			);
			UPDATE logins
			SET date_time_out = now()
			WHERE user_id=NEW.id AND date_time_out IS NULL;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.users_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 09:51:59 ******************
-- Trigger: users_trigger_before on public.users

-- DROP TRIGGER users_trigger_before ON public.users;

/*
CREATE TRIGGER users_trigger_before
  BEFORE DELETE
  ON public.users
  FOR EACH ROW
  EXECUTE PROCEDURE public.users_process();
*/

-- Trigger: users_trigger_after on public.users

-- DROP TRIGGER users_trigger_after ON public.users;


CREATE TRIGGER users_trigger_after
  AFTER UPDATE
  ON public.users
  FOR EACH ROW
  EXECUTE PROCEDURE public.users_process();



-- ******************* update 25/02/2020 09:52:01 ******************
-- Function: public.users_process()

-- DROP FUNCTION public.users_process();

CREATE OR REPLACE FUNCTION public.users_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		DELETE FROM logins
		WHERE user_id = OLD.id;
		
		RETURN OLD;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='UPDATE') THEN
		--remove sessions
		IF (NEW.banned) THEN
			DELETE FROM sessions WHERE id IN (
				SELECT session_id FROM logins
				WHERE user_id=NEW.id
			);
			UPDATE logins
			SET date_time_out = now()
			WHERE user_id=NEW.id AND date_time_out IS NULL;
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.users_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 13:09:21 ******************
-- VIEW: production_material_list

--DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		t_cor.quant AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + t_cor.quant) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + t_cor.quant)) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 25/02/2020 14:00:55 ******************

		INSERT INTO views
		(id,c,f,t,section,descr,limited)
		VALUES (
		'10041',
		'MaterialFactConsumptionCorretion_Controller',
		'get_list',
		'MaterialFactConsumptionCorretionList',
		'Формы',
		'Корректировки фактического расхода материалов',
		FALSE
		);
	

-- ******************* update 25/02/2020 14:09:39 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant*1000 AS quant_consuption,
		t_cor.quant AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant*1000 - (t.material_quant + t_cor.quant) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant*1000 - (t.material_quant + t_cor.quant)) * 100 / ra_mat.quant*1000 >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 25/02/2020 14:19:04 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+t_cor.quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant*1000 AS quant_consuption,
		t_cor.quant AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant*1000 - (t.material_quant + t_cor.quant) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant*1000 - (t.material_quant + t_cor.quant)) * 100 / ra_mat.quant*1000 >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 25/02/2020 14:59:25 ******************

					ALTER TYPE doc_types ADD VALUE 'cement_silo_reset';
	/* function */
	CREATE OR REPLACE FUNCTION enum_doc_types_val(doc_types,locales)
	RETURNS text AS $$
		SELECT
		CASE
		WHEN $1='material_procurement'::doc_types AND $2='ru'::locales THEN 'Поступление материалов'
		WHEN $1='shipment'::doc_types AND $2='ru'::locales THEN 'Отгрузка'
		WHEN $1='material_fact_consumption'::doc_types AND $2='ru'::locales THEN 'Фактический расход материалов'
		WHEN $1='material_fact_consumption_correction'::doc_types AND $2='ru'::locales THEN 'Корректировка фактического расхода материалов'
		WHEN $1='material_fact_balance_correction'::doc_types AND $2='ru'::locales THEN 'Корректировка остатка материала'
		WHEN $1='cement_silo_reset'::doc_types AND $2='ru'::locales THEN 'Обнуление силоса'
		ELSE ''
		END;		
	$$ LANGUAGE sql;	
	ALTER FUNCTION enum_doc_types_val(doc_types,locales) OWNER TO beton;		
		

-- ******************* update 25/02/2020 15:25:59 ******************
-- VIEW: cement_silo_balance_resets_list

--DROP VIEW cement_silo_balance_resets_list;

CREATE OR REPLACE VIEW cement_silo_balance_resets_list AS
	SELECT
		t.id
		,t.date_time
		,t.user_id
		,users_ref(u) AS users_ref
		,t.cement_silo_id
		,cement_silos_ref(sil) AS cement_silos_ref
		,t.comment_text
		
	FROM cement_silo_balance_resets AS t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN cement_silos sil ON sil.id=t.cement_silo_id
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW cement_silo_balance_resets_list OWNER TO beton;


-- ******************* update 25/02/2020 15:48:28 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		SELECT rg.balance
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,ARRAY[NEW.id]) AS rg;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN TRUE ELSE FALSE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 15:56:09 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.balance
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,ARRAY[NEW.id]) AS rg;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN TRUE ELSE FALSE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 15:59:44 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		--
		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
				- NEW.required_balance_quant;
		--register actions ra_material_facts
		reg_material_facts.date_time		= ra_date_time;
		reg_material_facts.deb			= (add_quant>0);
		reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
		reg_material_facts.doc_id  		= NEW.id;
		reg_material_facts.material_id		= NEW.material_id;
		reg_material_facts.quant		= abs(add_quant);
		PERFORM ra_material_facts_add_act(reg_material_facts);	
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 15:59:48 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.balance
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,ARRAY[NEW.id]) AS rg;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN TRUE ELSE FALSE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 16:00:18 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.balance
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,ARRAY[NEW.id]) AS rg;
		RAISE EXCEPTION 'v_quant=%',v_quant;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN TRUE ELSE FALSE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 16:04:28 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.balance
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,ARRAY[NEW.id],ARRAY[]) AS rg;
		RAISE EXCEPTION 'v_quant=%',v_quant;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN TRUE ELSE FALSE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 16:04:48 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.balance
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,ARRAY[NEW.id],ARRAY[]::int) AS rg;
		RAISE EXCEPTION 'v_quant=%',v_quant;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN TRUE ELSE FALSE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 16:05:05 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.balance
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,ARRAY[NEW.id],ARRAY[]::int[]) AS rg;
		RAISE EXCEPTION 'v_quant=%',v_quant;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN TRUE ELSE FALSE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 16:05:31 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.balance
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,NEW.id,ARRAY[]::int[]) AS rg;
		RAISE EXCEPTION 'v_quant=%',v_quant;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN TRUE ELSE FALSE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 16:05:55 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,NEW.id,ARRAY[]::int[]) AS rg;
		RAISE EXCEPTION 'v_quant=%',v_quant;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN TRUE ELSE FALSE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 16:06:24 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,NEW.id,ARRAY[]::int[]) AS rg;
		RAISE EXCEPTION 'v_quant=%',v_quant;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN FALSE ELSE TRUE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 16:06:31 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,NEW.id,ARRAY[]::int[]) AS rg;
		--RAISE EXCEPTION 'v_quant=%',v_quant;
		--register actions ra_cement
		reg_cement.date_time		= NEW.date_time;
		reg_cement.deb			= CASE WHEN v_quant>0 THEN FALSE ELSE TRUE END;
		reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
		reg_cement.doc_id  		= NEW.id;
		reg_cement.cement_silos_id	= NEW.cement_silo_id;
		reg_cement.quant		= abs(v_quant);
		PERFORM ra_cement_add_act(reg_cement);	
	
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 25/02/2020 16:13:11 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,NEW.id,ARRAY[]::int[]) AS rg;
		--RAISE EXCEPTION 'v_quant=%',v_quant;
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= CASE WHEN v_quant>0 THEN FALSE ELSE TRUE END;
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 26/02/2020 10:55:46 ******************
-- VIEW: cement_silo_balance_resets_list

--DROP VIEW cement_silo_balance_resets_list;

CREATE OR REPLACE VIEW cement_silo_balance_resets_list AS
	SELECT
		t.id
		,t.date_time
		,t.user_id
		,users_ref(u) AS users_ref
		,t.cement_silo_id
		,cement_silos_ref(sil) AS cement_silos_ref
		,t.comment_text
		,ra.quant
		
	FROM cement_silo_balance_resets AS t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN cement_silos sil ON sil.id=t.cement_silo_id
	LEFT JOIN ra_cement AS ra ON ra.doc_id = t.id AND ra.doc_type='cement_silo_balance_reset'::doc_types
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW cement_silo_balance_resets_list OWNER TO beton;


-- ******************* update 26/02/2020 11:00:57 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+t_cor.quant AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		t_cor.quant AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + t_cor.quant) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + t_cor.quant)) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 26/02/2020 11:31:28 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,NEW.id,ARRAY[NEW.cement_silo_id]) AS rg;
		--RAISE EXCEPTION 'v_quant=%',v_quant;
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= CASE WHEN v_quant>0 THEN FALSE ELSE TRUE END;
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 26/02/2020 11:42:31 ******************
-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;

CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE DELETE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();

/*
-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

-- DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;

CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE INSERT OR UPDATE OR DELETE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();
*/


-- ******************* update 26/02/2020 11:42:53 ******************
-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

--DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;
/*
CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE DELETE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();
*/

-- Trigger: material_fact_consumptions_trigger_after on public.material_fact_consumptions

-- DROP TRIGGER material_fact_consumptions_trigger_after ON public.material_fact_consumptions;

CREATE TRIGGER material_fact_consumptions_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();



-- ******************* update 26/02/2020 11:42:56 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_cement_material_id int;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		v_cement_material_id = 	(const_cement_material_val()->'keys'->>'id')::int;
				
		IF NEW.raw_material_id IS NOT NULL AND NEW.raw_material_id<>v_cement_material_id  THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.raw_material_id IS NOT NULL
			AND NEW.raw_material_id=v_cement_material_id
			 AND NEW.cement_silo_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 26/02/2020 11:44:01 ******************
-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;

CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE UPDATE OR DELETE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();


-- Trigger: material_fact_consumptions_trigger_after on public.material_fact_consumptions

-- DROP TRIGGER material_fact_consumptions_trigger_after ON public.material_fact_consumptions;
/*
CREATE TRIGGER material_fact_consumptions_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();
*/


-- ******************* update 26/02/2020 11:44:30 ******************
-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;

CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE INSERT OR UPDATE OR DELETE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();


-- Trigger: material_fact_consumptions_trigger_after on public.material_fact_consumptions

-- DROP TRIGGER material_fact_consumptions_trigger_after ON public.material_fact_consumptions;
/*
CREATE TRIGGER material_fact_consumptions_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();
*/


-- ******************* update 26/02/2020 12:27:55 ******************
-- Function: public.rg_cement_update_periods(timestamp without time zone, int, numeric)

-- DROP FUNCTION public.rg_cement_update_periods(timestamp without time zone, int,numeric);

CREATE OR REPLACE FUNCTION public.rg_cement_update_periods(
    in_date_time timestamp without time zone,
    in_cement_silos_id int,
    in_delta_quant numeric)
  RETURNS void AS
$BODY$
DECLARE
	v_loop_rg_period timestamp;
	v_calc_interval interval;			  			
	CURRENT_BALANCE_DATE_TIME timestamp;
	CALC_DATE_TIME timestamp;
BEGIN
	CALC_DATE_TIME = rg_calc_period('cement'::reg_types);
	v_loop_rg_period = rg_period('cement'::reg_types,in_date_time);
	v_calc_interval = rg_calc_interval('cement'::reg_types);
	LOOP
		UPDATE rg_cement
		SET
			quant = quant + in_delta_quant
		WHERE 
			date_time=v_loop_rg_period
			AND cement_silos_id = in_cement_silos_id;
			
		IF NOT FOUND THEN
			BEGIN
				INSERT INTO rg_cement (date_time
				,cement_silos_id
				,quant)				
				VALUES (v_loop_rg_period
				,in_cement_silos_id
				,in_delta_quant);
			EXCEPTION WHEN OTHERS THEN
				UPDATE rg_cement
				SET
					quant = quant + in_delta_quant
				WHERE date_time = v_loop_rg_period
				AND cement_silos_id = in_cement_silos_id;
			END;
		END IF;
		v_loop_rg_period = v_loop_rg_period + v_calc_interval;
		IF v_loop_rg_period > CALC_DATE_TIME THEN
			EXIT;  -- exit loop
		END IF;
	END LOOP;
	
	--Current balance
	CURRENT_BALANCE_DATE_TIME = reg_current_balance_time();
	UPDATE rg_cement
	SET
		quant = quant + in_delta_quant
	WHERE 
		date_time=CURRENT_BALANCE_DATE_TIME
		AND cement_silos_id = in_cement_silos_id;
		
	IF NOT FOUND THEN
		BEGIN
			INSERT INTO rg_cement (date_time
			,cement_silos_id
			,quant)				
			VALUES (CURRENT_BALANCE_DATE_TIME
			,in_cement_silos_id
			,in_delta_quant);
		EXCEPTION WHEN OTHERS THEN
			UPDATE rg_cement
			SET
				quant = quant + in_delta_quant
			WHERE 
				date_time=CURRENT_BALANCE_DATE_TIME
				AND cement_silos_id = in_cement_silos_id;
		END;
	END IF;					
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.rg_cement_update_periods(timestamp without time zone, int,numeric)
  OWNER TO beton;



-- ******************* update 26/02/2020 12:28:40 ******************
-- Function: public.ra_cement_process()

-- DROP FUNCTION public.ra_cement_process();

CREATE OR REPLACE FUNCTION public.ra_cement_process()
  RETURNS trigger AS
$BODY$
			DECLARE
				v_delta_quant  numeric(19,3) DEFAULT 0;
				CALC_DATE_TIME timestamp without time zone;
				CURRENT_BALANCE_DATE_TIME timestamp without time zone;
				v_loop_rg_period timestamp;
				v_calc_interval interval;			  			
			BEGIN
				IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
					RETURN NEW;
				ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
					RETURN NEW;
				ELSIF (TG_WHEN='AFTER' AND (TG_OP='UPDATE' OR TG_OP='INSERT')) THEN
					CALC_DATE_TIME = rg_calc_period('cement'::reg_types);
					IF (CALC_DATE_TIME IS NULL) OR (NEW.date_time::date > rg_period_balance('cement'::reg_types, CALC_DATE_TIME)) THEN
						CALC_DATE_TIME = rg_period('cement'::reg_types,NEW.date_time);
						PERFORM rg_cement_set_custom_period(CALC_DATE_TIME);						
					END IF;
					
					IF TG_OP='UPDATE' AND
					(NEW.date_time<>OLD.date_time
					) THEN
						--delete old data completely
						PERFORM rg_cement_update_periods(OLD.date_time, OLD.cement_silos_id,-1*OLD.quant);
						v_delta_quant = 0;
					ELSIF TG_OP='UPDATE' THEN						
						v_delta_quant = OLD.quant;
					ELSE
						v_delta_quant = 0;
					END IF;
					
					v_delta_quant = NEW.quant - v_delta_quant;
					IF NOT NEW.deb THEN
						v_delta_quant = -1 * v_delta_quant;
					END IF;

					PERFORM rg_cement_update_periods(NEW.date_time, NEW.cement_silos_id, v_delta_quant);

					RETURN NEW;					
				ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
					RETURN OLD;
				ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
					CALC_DATE_TIME = rg_calc_period('cement'::reg_types);
					IF (CALC_DATE_TIME IS NULL) OR (OLD.date_time::date > rg_period_balance('cement'::reg_types, CALC_DATE_TIME)) THEN
						CALC_DATE_TIME = rg_period('cement'::reg_types,OLD.date_time);
						PERFORM rg_cement_set_custom_period(CALC_DATE_TIME);						
					END IF;
					v_delta_quant = OLD.quant;
					IF OLD.deb THEN
						v_delta_quant = -1*v_delta_quant;					
					END IF;

					PERFORM rg_cement_update_periods(OLD.date_time, OLD.cement_silos_id,v_delta_quant);
					
					RETURN OLD;					
				END IF;
			END;
			$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.ra_cement_process()
  OWNER TO beton;



-- ******************* update 03/03/2020 11:58:44 ******************
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
				WHERE pr_vals.pump_price_id = (pump_vehicle_price_on_date(pvh.pump_prices,o.date_time)->'keys'->>'id')::int
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
				WHERE pr_vals.pump_price_id = (pump_vehicle_price_on_date(pvh.pump_prices,o.date_time)->'keys'->>'id')::int
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


-- ******************* update 13/03/2020 15:37:23 ******************
﻿-- Function: material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)

-- DROP FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)
  RETURNS record AS
$$
	-- пытаемся определить авто по описанию элкон
	-- выбираем из production_descr только числа
	-- находим авто с маской %in_production_descr% и назначенное в диапазоне получаса

	SELECT
		vsch.vehicle_id AS vehicle_id,
		vschs.id AS vehicle_schedule_state_id,
		sh.id AS shipment_id
	FROM shipments AS sh
	LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
	WHERE
		sh.date_time BETWEEN in_production_dt_start-'60 minutes'::interval AND in_production_dt_start
		AND vh.plate LIKE '%'||regexp_replace(in_production_vehicle_descr, '\D','','g')||'%'
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp) OWNER TO beton;


-- ******************* update 13/03/2020 15:40:58 ******************
﻿-- Function: material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)

-- DROP FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp);

CREATE OR REPLACE FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp)
  RETURNS record AS
$$
	-- пытаемся определить авто по описанию элкон
	-- выбираем из production_descr только числа
	-- находим авто с маской %in_production_descr% и назначенное в диапазоне получаса

	SELECT
		vsch.vehicle_id AS vehicle_id,
		vschs.id AS vehicle_schedule_state_id,
		sh.id AS shipment_id
	FROM shipments AS sh
	LEFT JOIN vehicle_schedule_states AS vschs ON vschs.schedule_id = sh.vehicle_schedule_id
	LEFT JOIN vehicle_schedules AS vsch ON vsch.id = sh.vehicle_schedule_id
	LEFT JOIN vehicles AS vh ON vh.id=vsch.vehicle_id
	WHERE
		sh.date_time BETWEEN in_production_dt_start-'30 minutes'::interval AND in_production_dt_start+'60 minutes'::interval
		AND vh.plate LIKE '%'||regexp_replace(in_production_vehicle_descr, '\D','','g')||'%'
	LIMIT 1;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_fact_consumptions_find_vehicle(in_production_vehicle_descr text,in_production_dt_start timestamp) OWNER TO beton;


-- ******************* update 13/03/2020 16:58:02 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 08:53:49 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant
		INTO v_quant
		FROM rg_cement_balance('cement_silo_balance_reset'::doc_types,NEW.id,ARRAY[NEW.cement_silo_id]) AS rg;
		RAISE EXCEPTION 'v_quant=%',v_quant;
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= CASE WHEN v_quant>0 THEN FALSE ELSE TRUE END;
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 31/03/2020 09:00:11 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant
		INTO v_quant
		FROM rg_cement_balance(ARRAY[NEW.cement_silo_id]) AS rg;
		--'cement_silo_balance_reset'::doc_types,NEW.id
		RAISE EXCEPTION 'v_quant=%',v_quant;
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= CASE WHEN v_quant>0 THEN FALSE ELSE TRUE END;
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 31/03/2020 09:00:29 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	v_quant numeric(19,4);
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant
		INTO v_quant
		FROM rg_cement_balance(ARRAY[NEW.cement_silo_id]) AS rg;
		--'cement_silo_balance_reset'::doc_types,NEW.id
		--RAISE EXCEPTION 'v_quant=%',v_quant;
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= CASE WHEN v_quant>0 THEN FALSE ELSE TRUE END;
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 31/03/2020 09:21:55 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	/*
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	*/
	
	SELECT
		t.id AS material_fact_consumption_id,
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		sum(t.material_quant) + sum(coalesce(t_cor.quant,0)) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		sum(ra_mat.quant) AS quant_consuption,
		sum(coalesce(t_cor.quant,0)) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		sum(ra_mat.quant) - (sum(t.material_quant) + sum(coalesce(t_cor.quant,0))) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			((sum(ra_mat.quant) - (sum(t.material_quant) + sum(coalesce(t_cor.quant,0)))) * 100 / sum(ra_mat.quant) >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.id,t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,mat.ord,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 09:44:01 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
	
/*	
	SELECT
		t.id AS material_fact_consumption_id,
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		sum(t.material_quant) + sum(coalesce(t_cor.quant,0)) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		sum(ra_mat.quant) AS quant_consuption,
		sum(coalesce(t_cor.quant,0)) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		sum(ra_mat.quant) - (sum(t.material_quant) + sum(coalesce(t_cor.quant,0))) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			((sum(ra_mat.quant) - (sum(t.material_quant) + sum(coalesce(t_cor.quant,0)))) * 100 / sum(ra_mat.quant) >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.id,t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,mat.ord,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 09:48:44 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
/*	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/	
	
	SELECT
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		sum(t.material_quant) + sum(coalesce(t_cor.quant,0)) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		sum(ra_mat.quant) AS quant_consuption,
		sum(coalesce(t_cor.quant,0)) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		sum(ra_mat.quant) - (sum(t.material_quant) + sum(coalesce(t_cor.quant,0))) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			((sum(ra_mat.quant) - (sum(t.material_quant) + sum(coalesce(t_cor.quant,0)))) * 100 / sum(ra_mat.quant) >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,mat.ord,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 09:56:42 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
/*	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/	
	
	SELECT
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		sum(t.material_quant) + sum(coalesce(t_cor.quant,0)) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		sum(coalesce(t_cor.quant,0)) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		ra_mat.quant - sum(t.material_quant + coalesce(t_cor.quant,0)) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			( sum( (ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100) / sum(ra_mat.quant) >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,mat.ord,ra_mat.quant,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 10:28:08 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
/*	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/	
	
	SELECT
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id AS material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		sum(t.material_quant) + sum(coalesce(t_cor.quant,0)) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		sum(coalesce(t_cor.quant,0)) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		ra_mat.quant - sum(t.material_quant + coalesce(t_cor.quant,0)) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			( sum( (ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100) / sum(ra_mat.quant) >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,mat.ord,ra_mat.quant,t.raw_material_id,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 10:38:23 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
/*	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/	
	
	SELECT
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id AS material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.cement_silo_id,
		sum(t.material_quant) AS material_quant,
		sum(t.material_quant) + sum(coalesce(t_cor.quant,0)) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		sum(coalesce(t_cor.quant,0)) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		ra_mat.quant - sum(t.material_quant + coalesce(t_cor.quant,0)) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			( sum( (ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100) / sum(ra_mat.quant) >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,
		mat.ord,ra_mat.quant,t.raw_material_id,t.cement_silo_id,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 10:47:00 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
/*	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/	
	
	SELECT
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id AS material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.cement_silo_id,
		sum(t.material_quant) AS material_quant,
		sum(t.material_quant) + sum(coalesce(t_cor.quant,0)) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		sum(coalesce(t_cor.quant,0)) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		ra_mat.quant - sum(t.material_quant + coalesce(t_cor.quant,0)) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			( sum( (ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100) / sum(ra_mat.quant) >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id AND t_cor.cement_silo_id=t.cement_silo_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,
		mat.ord,ra_mat.quant,t.raw_material_id,t.cement_silo_id,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 10:51:27 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
/*	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/	
	
	SELECT
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id AS material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.cement_silo_id,
		sum(t.material_quant) AS material_quant,
		sum(t.material_quant) + sum(coalesce(t_cor.quant,0)) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		sum(coalesce(t_cor.quant,0)) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		ra_mat.quant - sum(t.material_quant + coalesce(t_cor.quant,0)) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			( sum( (ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100) / sum(ra_mat.quant) >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id --AND t_cor.cement_silo_id=t.cement_silo_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,
		mat.ord,ra_mat.quant,t.raw_material_id,t.cement_silo_id,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 10:53:17 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
/*	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/	
	
	SELECT
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id AS material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.cement_silo_id,
		sum(t.material_quant) AS material_quant,
		sum(t.material_quant) + coalesce(t_cor.quant,0) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		ra_mat.quant - sum(t.material_quant) + coalesce(t_cor.quant,0) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			( (ra_mat.quant - (sum(t.material_quant) + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id --AND t_cor.cement_silo_id=t.cement_silo_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,
		mat.ord,ra_mat.quant,t.raw_material_id,t.cement_silo_id,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set,t_cor.quant
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 31/03/2020 10:54:33 ******************
-- VIEW: production_material_list

DROP VIEW production_material_list;

CREATE OR REPLACE VIEW production_material_list AS
/*	
	SELECT
		t.production_site_id,
		t.production_id,
		production_sites_ref(ps) AS production_sites_ref,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.material_quant+coalesce(t_cor.quant,0) AS quant_fact,
		t.material_quant_req AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,
		
		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,
		
		--подбор - (Факт + исправление)
		ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0)) as quant_dif,
		
		CASE WHEN ra_mat.quant = 0 THEN FALSE
		ELSE
			((ra_mat.quant - (t.material_quant + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
		END AS dif_violation,
		
		t.id AS material_fact_consumption_id
		
		
	FROM material_fact_consumptions AS t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
*/	
	
	SELECT
		t.production_site_id,
		production_sites_ref(ps) AS production_sites_ref,
		t.production_id,
		t.raw_material_id AS material_id,
		materials_ref(mat) AS materials_ref,
		cement_silos_ref(cem) AS cement_silos_ref,
		t.cement_silo_id,
		sum(t.material_quant) AS material_quant,
		sum(t.material_quant) + coalesce(t_cor.quant,0) AS quant_fact,
		sum(t.material_quant_req) AS quant_fact_req,
		ra_mat.quant AS quant_consuption,
		coalesce(t_cor.quant,0) AS quant_corrected,

		t_cor.elkon_id AS elkon_correction_id,
		users_ref(cor_u) AS correction_users_ref,
		t_cor.date_time_set correction_date_time_set,

		--подбор - (Факт + исправление)
		ra_mat.quant - (sum(t.material_quant) + coalesce(t_cor.quant,0)) as quant_dif
	
		,CASE WHEN sum(ra_mat.quant) = 0 THEN FALSE
		ELSE
			coalesce(
			( (ra_mat.quant - (sum(t.material_quant) + coalesce(t_cor.quant,0))) * 100 / ra_mat.quant >= mat.max_fact_quant_tolerance_percent)
			,FALSE)
		END AS dif_violation
	

	FROM material_fact_consumptions t
	LEFT JOIN production_sites AS ps ON ps.id=t.production_site_id
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN cement_silos AS cem ON cem.id=t.cement_silo_id
	LEFT JOIN vehicle_schedule_states AS vsch ON vsch.id=t.vehicle_schedule_state_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=vsch.shipment_id AND ra_mat.material_id=t.raw_material_id
	LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
			AND t_cor.material_id=t.raw_material_id --AND t_cor.cement_silo_id=t.cement_silo_id
	LEFT JOIN users AS cor_u ON cor_u.id=t_cor.user_id

	GROUP BY
		t.production_site_id,t.production_id,t.raw_material_id,mat.max_fact_quant_tolerance_percent,
		mat.ord,ra_mat.quant,t.raw_material_id,t.cement_silo_id,
		ps.*,mat.*,cem.*,
		t_cor.elkon_id,cor_u.*,t_cor.date_time_set,t_cor.quant
	ORDER BY t.production_site_id,
		t.production_id,
		mat.ord
			
	;
	
ALTER VIEW production_material_list OWNER TO beton;



-- ******************* update 17/04/2020 08:28:07 ******************
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
		
		,orders_ref(o) AS orders_ref
		
		
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



-- ******************* update 17/04/2020 08:38:58 ******************
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
		
		IF (NEW.order_id <> OLD.order_id) THEN
			/* смена заявки
			 * 1) Удалить vehicle_schedule_states сданным id отгрузки и статусом at_dest, как будто и не доехал еще
			 * 2) Исправить все оставшиеся vehicle_schedule_states where shipment_id = NEW.id на новый destionation_id из orders
			 */
			DELETE FROM vehicle_schedule_states WHERE shipment_id = NEW.id AND state= 'at_dest'::vehicle_states;
			UPDATE vehicle_schedule_states
			SET
				destination_id = (SELECT orders.destination_id FROM orders WHERE orders.id=NEW.order_id)
			WHERE shipment_id = NEW.id;
		END IF;
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.shipment_process()
  OWNER TO beton;



-- ******************* update 20/04/2020 10:43:00 ******************
-- Function: public.mat_totals(date)

 DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_fact_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	quant_morn_fact_cur_balance numeric,
  	balance_corrected_data json
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		COALESCE(bal.quant,0)::numeric AS quant_fact_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		COALESCE(bal_morn_fact.quant,0)::numeric AS quant_morn_fact_cur_balance,
		
		--Корректировки
		(SELECT
			json_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'materials_ref',materials_ref(m),
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn_fact ON bal_morn_fact.material_id=m.id

	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_material_facts_balance('{}')
	) AS bal_fact ON bal_fact.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 20/04/2020 10:45:44 ******************
-- Function: public.mat_totals(date)

-- DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_fact_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	quant_morn_fact_cur_balance numeric,
  	balance_corrected_data json
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		COALESCE(bal_fact.quant,0)::numeric AS quant_fact_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		COALESCE(bal_morn_fact.quant,0)::numeric AS quant_morn_fact_cur_balance,
		
		--Корректировки
		(SELECT
			json_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'materials_ref',materials_ref(m),
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn_fact ON bal_morn_fact.material_id=m.id

	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_material_facts_balance('{}')
	) AS bal_fact ON bal_fact.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 20/04/2020 11:08:37 ******************
-- Function: public.mat_totals(date)

-- DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_fact_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	quant_morn_fact_cur_balance numeric,
  	balance_corrected_data json
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		COALESCE(bal_fact.quant,0)::numeric AS quant_fact_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		COALESCE(bal_morn_fact.quant,0)::numeric AS quant_morn_fact_cur_balance,
		
		--Корректировки
		(SELECT
			json_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'materials_ref',materials_ref(m),
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	LEFT JOIN (
		SELECT *
		FROM rg_material_facts_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn_fact ON bal_morn_fact.material_id=m.id

	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_material_facts_balance('{}')
	) AS bal_fact ON bal_fact.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 20/04/2020 12:01:12 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		--
		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
				- NEW.required_balance_quant;
		IF add_quant <> 0 THEN
			--register actions ra_material_facts		
			reg_material_facts.date_time		= ra_date_time;
			reg_material_facts.deb			= (add_quant<0);
			reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= abs(add_quant);
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
					
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 20/04/2020 12:04:48 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		--
		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
				- NEW.required_balance_quant;
		IF add_quant <> 0 THEN
			--register actions ra_material_facts		
			reg_material_facts.date_time		= ra_date_time;
			reg_material_facts.deb			= (add_quant<0);
			reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= abs(add_quant);
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
					
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 20/04/2020 12:07:09 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		--
		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
				- NEW.required_balance_quant;
		IF add_quant <> 0 THEN
			RAISE EXCEPTION 'add_quant=%',add_quant;
			--register actions ra_material_facts		
			reg_material_facts.date_time		= ra_date_time;
			reg_material_facts.deb			= (add_quant<0);
			reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= abs(add_quant);
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
					
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 20/04/2020 12:09:32 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		--
		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
				- NEW.required_balance_quant;
		IF add_quant <> 0 THEN
			--RAISE EXCEPTION 'add_quant=%',add_quant;
			--register actions ra_material_facts		
			reg_material_facts.date_time		= ra_date_time;
			reg_material_facts.deb			= (add_quant<0);
			reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= abs(add_quant);
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
					
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 20/04/2020 12:56:20 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
			
		IF NEW.material_id = (const_cement_material_val()->'keys'->>'id')::int THEN
			--ЦЕМЕНТ
			add_quant = coalesce((SELECT quant FROM rg_cement_balance(ra_date_time)),0)
					- NEW.required_balance_quant;
			IF add_quant <> 0 THEN
				reg_cement.date_time		= ra_date_time;
				reg_cement.deb			= (add_quant<0);
				reg_cement.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_cement.doc_id  		= NEW.id;
				reg_cement.cement_silos_id	= NEW.cement_silo_id;
				reg_cement.quant		= abs(add_quant);
				PERFORM ra_cement_add_act(reg_cement);	
				
			END IF;
		
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
					- NEW.required_balance_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 20/04/2020 12:57:15 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
			
		IF NEW.material_id = (const_cement_material_val()->'keys'->>'id')::int THEN
			--ЦЕМЕНТ
			IF NEW.cement_silo_id IS NULL THEN
				RAISE EXCEPTION 'Не выбран силос по цементу';
			END IF;
			add_quant = coalesce((SELECT quant FROM rg_cement_balance(ra_date_time)),0)
					- NEW.required_balance_quant;
			IF add_quant <> 0 THEN
				reg_cement.date_time		= ra_date_time;
				reg_cement.deb			= (add_quant<0);
				reg_cement.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_cement.doc_id  		= NEW.id;
				reg_cement.cement_silos_id	= NEW.cement_silo_id;
				reg_cement.quant		= abs(add_quant);
				PERFORM ra_cement_add_act(reg_cement);	
				
			END IF;
		
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
					- NEW.required_balance_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 20/04/2020 13:01:34 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
			
		IF NEW.material_id = (const_cement_material_val()->'keys'->>'id')::int THEN
			--ЦЕМЕНТ
			IF NEW.cement_silo_id IS NULL THEN
				RAISE EXCEPTION 'Не выбран силос по цементу';
			END IF;
			add_quant = coalesce((SELECT quant FROM rg_cement_balance(ra_date_time,ARRAY[NEW.cement_silo_id])),0)
					- NEW.required_balance_quant;
			IF add_quant <> 0 THEN
				reg_cement.date_time		= ra_date_time;
				reg_cement.deb			= (add_quant<0);
				reg_cement.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_cement.doc_id  		= NEW.id;
				reg_cement.cement_silos_id	= NEW.cement_silo_id;
				reg_cement.quant		= abs(add_quant);
				PERFORM ra_cement_add_act(reg_cement);	
				
			END IF;
		
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
					- NEW.required_balance_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 20/04/2020 14:06:34 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
			
		IF NEW.material_id = (const_cement_material_val()->'keys'->>'id')::int THEN
			--ЦЕМЕНТ
			RAISE EXCEPTION 'Остатки по цементу обнуляются в разрезе силосов!';
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
					- NEW.required_balance_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 20/04/2020 14:23:48 ******************
-- Function: public.mat_totals(date)

-- DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_fact_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	quant_morn_fact_cur_balance numeric,
  	balance_corrected_data json
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		
		CASE WHEN m.id = (const_cement_material_val()->'keys'->>'id')::int THEN
			-- Цемент
			COALESCE(
				(SELECT sum(quant) from rg_cement_balance('{}'))
			,0)::numeric
		ELSE
			COALESCE(bal_fact.quant,0)::numeric
		END AS quant_fact_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		
		CASE WHEN m.id = (const_cement_material_val()->'keys'->>'id')::int THEN
			-- Цемент
			COALESCE(
				(SELECT sum(quant) from rg_cement_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}'))
			,0)::numeric
		ELSE
			COALESCE(bal_morn_fact.quant,0)::numeric
		END AS quant_morn_fact_cur_balance,
		
		--Корректировки
		(SELECT
			json_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'materials_ref',materials_ref(m),
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	LEFT JOIN (
		SELECT * FROM rg_material_facts_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn_fact ON bal_morn_fact.material_id=m.id

	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	LEFT JOIN (
		SELECT * FROM rg_material_facts_balance('{}')
	) AS bal_fact ON bal_fact.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 20/04/2020 14:35:57 ******************
--DROP FUNCTION material_fact_consumptions_add_material(text,timestamp)
CREATE OR REPLACE FUNCTION material_fact_consumptions_add_material(text,timestamp)
RETURNS int as $$
DECLARE
	v_raw_material_id int;
BEGIN
	v_raw_material_id = NULL;
	SELECT raw_material_id INTO v_raw_material_id
	FROM raw_material_map_to_production
	WHERE production_descr = $1 AND date_time<=$2
	ORDER BY date_time DESC
	LIMIT 1;
	
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

ALTER FUNCTION material_fact_consumptions_add_material(text,timestamp) OWNER TO beton;


-- ******************* update 21/04/2020 08:06:59 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
			
		IF NEW.material_id = (const_cement_material_val()->'keys'->>'id')::int THEN
			--ЦЕМЕНТ
			RAISE EXCEPTION 'Остатки по цементу обнуляются в разрезе силосов!';
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)
					- NEW.required_balance_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.balance_date_time<>OLD.balance_date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 21/04/2020 08:16:15 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
			
		IF NEW.material_id = (const_cement_material_val()->'keys'->>'id')::int THEN
			--ЦЕМЕНТ
			RAISE EXCEPTION 'Остатки по цементу обнуляются в разрезе силосов!';
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0);
			RAISE EXCEPTION 'BALANCE=%',add_quant;
--					- NEW.required_balance_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.balance_date_time<>OLD.balance_date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 21/04/2020 08:19:12 ******************
-- Function: public.rg_total_recalc_material_facts()

-- DROP FUNCTION public.rg_total_recalc_material_facts();

CREATE OR REPLACE FUNCTION public.rg_total_recalc_material_facts()
  RETURNS void AS
$BODY$  
DECLARE
	period_row RECORD;
	v_act_date_time timestamp without time zone;
	v_cur_period timestamp without time zone;
BEGIN	
	v_act_date_time = reg_current_balance_time();
	SELECT date_time INTO v_cur_period FROM rg_calc_periods;
	
	FOR period_row IN
		WITH
		periods AS (
			(SELECT
				DISTINCT date_trunc('month', date_time) AS d,
				material_id
			FROM ra_material_facts)
			UNION		
			(SELECT
				date_time AS d,
				material_id
			FROM rg_material_facts WHERE date_time<=v_cur_period
			)
			ORDER BY d			
		)
		SELECT sub.d,sub.material_id,sub.balance_fact,sub.balance_paper
		FROM
		(
		SELECT
			periods.d,
			periods.material_id,
			COALESCE((
				SELECT SUM(CASE WHEN deb THEN quant ELSE 0 END)-SUM(CASE WHEN NOT deb THEN quant ELSE 0 END)
				FROM ra_material_facts AS ra WHERE ra.date_time <= last_month_day(periods.d::date)+'23:59:59'::interval AND ra.material_id=periods.material_id
			),0) AS balance_fact,
			
			(
			SELECT SUM(quant) FROM rg_material_facts WHERE date_time=periods.d AND material_id=periods.material_id
			) AS balance_paper
			
		FROM periods
		) AS sub
		WHERE sub.balance_fact<>sub.balance_paper ORDER BY sub.d	
	LOOP
		
		UPDATE rg_material_facts AS rg
		SET quant = period_row.balance_fact
		WHERE rg.date_time=period_row.d AND rg.material_id=period_row.material_id;
		
		IF NOT FOUND THEN
			INSERT INTO rg_material_facts (date_time,material_id,quant)
			VALUES (period_row.d,period_row.material_id,period_row.balance_fact);
		END IF;
	END LOOP;

	--АКТУАЛЬНЫЕ ИТОГИ
	DELETE FROM rg_material_facts WHERE date_time>v_cur_period;
	
	INSERT INTO rg_material_facts (date_time,material_id,quant)
	(
	SELECT
		v_act_date_time,
		rg.material_id,
		COALESCE(rg.quant,0) +
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_material_facts AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.material_id=rg.material_id
			AND ra.deb=TRUE
		),0) - 
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_material_facts AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.material_id=rg.material_id
			AND ra.deb=FALSE
		),0)
		
	FROM rg_material_facts AS rg
	WHERE date_time=(v_cur_period-'1 month'::interval)
	);	
END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.rg_total_recalc_material_facts()
  OWNER TO beton;



-- ******************* update 21/04/2020 08:20:22 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
			
		IF NEW.material_id = (const_cement_material_val()->'keys'->>'id')::int THEN
			--ЦЕМЕНТ
			RAISE EXCEPTION 'Остатки по цементу обнуляются в разрезе силосов!';
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)			
					- NEW.required_balance_quant;
			--RAISE EXCEPTION 'BALANCE=%',add_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.balance_date_time<>OLD.balance_date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 21/04/2020 08:32:07 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time-'1 second'::interval);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
			
		IF NEW.material_id = (const_cement_material_val()->'keys'->>'id')::int THEN
			--ЦЕМЕНТ
			RAISE EXCEPTION 'Остатки по цементу обнуляются в разрезе силосов!';
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)			
					- NEW.required_balance_quant;
			--RAISE EXCEPTION 'BALANCE=%',add_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.balance_date_time<>OLD.balance_date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time-'1 second'::interval);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 21/04/2020 09:50:01 ******************
-- Function: public.rg_material_facts_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_material_facts_balance(
    IN in_date_time timestamp without time zone,
    IN in_material_id_ar integer[])
  RETURNS TABLE(material_id integer, quant numeric) AS
$BODY$
	WITH
	cur_per AS (SELECT rg_period('material_fact'::reg_types, in_date_time) AS v ),
	act_forward AS (
		SELECT
			rg_period_balance('material_fact'::reg_types,in_date_time) - in_date_time >
			(SELECT t.v FROM cur_per t) - in_date_time
			AS v
	),
	act_sg AS (SELECT CASE WHEN t.v THEN 1 ELSE -1 END AS v FROM act_forward t),
	last_calc_per AS (SELECT rg_period_balance('material_fact'::reg_types,rg_calc_period('material_fact'::reg_types)) AS v)
	SELECT 
	sub.material_id
	,SUM(sub.quant) AS quant				
	FROM(
		(SELECT
		b.material_id
		,b.quant				
		FROM rg_material_facts AS b
		WHERE
		(
			--date bigger than last calc period
			(in_date_time > (SELECT v FROM last_calc_per) AND b.date_time = (SELECT rg_current_balance_time()))
			OR (
				in_date_time < (SELECT v FROM last_calc_per)
				AND (
					--forward from previous period
					( (SELECT t.v FROM act_forward t) AND b.date_time = (SELECT t.v FROM cur_per t)-rg_calc_interval('material_fact'::reg_types)
					)
					--backward from current
					OR			
					( NOT (SELECT t.v FROM act_forward t) AND b.date_time = (SELECT t.v FROM cur_per t)				
					)
				)
			)
		)	
		AND ( (in_material_id_ar IS NULL OR ARRAY_LENGTH(in_material_id_ar,1) IS NULL) OR (b.material_id=ANY(in_material_id_ar)))
		AND (
		b.quant<>0
		)
		)
		UNION ALL
		(SELECT
		act.material_id
		,CASE act.deb
			WHEN TRUE THEN act.quant * (SELECT t.v FROM act_sg t)
			ELSE -act.quant * (SELECT t.v FROM act_sg t)
		END AS quant
		FROM doc_log
		LEFT JOIN ra_material_facts AS act ON act.doc_type=doc_log.doc_type AND act.doc_id=doc_log.doc_id
		WHERE
		(
			--forward from previous period
			( (SELECT t.v FROM act_forward t) AND
					act.date_time >= (SELECT t.v FROM cur_per t)
					AND act.date_time <= 
						(SELECT l.date_time FROM doc_log l
						WHERE date_trunc('second',l.date_time)<=date_trunc('second',in_date_time)
						ORDER BY l.date_time DESC LIMIT 1
						)
			)
			--backward from current
			OR			
			( NOT (SELECT t.v FROM act_forward t) AND
					act.date_time >= 
						(SELECT l.date_time FROM doc_log l
						WHERE date_trunc('second',l.date_time)>=date_trunc('second',in_date_time)
						ORDER BY l.date_time ASC LIMIT 1
						)			
					AND act.date_time <= (SELECT t.v FROM cur_per t)
			)
		)
		AND (in_material_id_ar IS NULL OR ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (act.material_id=ANY(in_material_id_ar)))
		AND (
		act.quant<>0
		)
		ORDER BY doc_log.date_time,doc_log.id)
	) AS sub
	WHERE
	 (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (sub.material_id=ANY(in_material_id_ar)))
	GROUP BY
		sub.material_id
	HAVING
		SUM(sub.quant)<>0
	ORDER BY
		sub.material_id;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[])
  OWNER TO beton;



-- ******************* update 21/04/2020 10:25:56 ******************
-- Function: public.rg_material_facts_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_material_facts_balance(
    IN in_date_time timestamp without time zone,
    IN in_material_id_ar integer[])
  RETURNS TABLE(material_id integer, quant numeric) AS
$BODY$
DECLARE
	v_cur_per timestamp;
	v_act_direct boolean;
	v_act_direct_sgn int;
	v_calc_interval interval;
BEGIN
	v_cur_per = rg_period('material_fact'::reg_types, in_date_time);
	v_calc_interval = rg_calc_interval('material_fact'::reg_types);
	v_act_direct = TRUE;--( (rg_calc_period_end('material_fact'::reg_types,v_cur_per)-in_date_time)>(in_date_time - v_cur_per) );
	v_act_direct_sgn = 1;
	/*
	IF v_act_direct THEN
		v_act_direct_sgn = 1;
	ELSE
		v_act_direct_sgn = -1;
	END IF;
	*/
	--RAISE 'v_act_direct=%, v_cur_per=%, v_calc_interval=%',v_act_direct,v_cur_per,v_calc_interval;
	RETURN QUERY 
	SELECT 
	
	sub.material_id
	,SUM(sub.quant) AS quant				
	FROM(
		SELECT
		
		b.material_id
		,b.quant				
		FROM rg_material_facts AS b
		WHERE (v_act_direct AND b.date_time = (v_cur_per-v_calc_interval)) OR (NOT v_act_direct AND b.date_time = v_cur_per)
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (b.material_id=ANY(in_material_id_ar)))
		
		AND (
		b.quant<>0
		)
		
		UNION ALL
		
		(SELECT
		
		act.material_id
		,CASE act.deb
			WHEN TRUE THEN act.quant*v_act_direct_sgn
			ELSE -act.quant*v_act_direct_sgn
		END AS quant
										
		FROM doc_log
		LEFT JOIN ra_material_facts AS act ON act.doc_type=doc_log.doc_type AND act.doc_id=doc_log.doc_id
		WHERE (v_act_direct AND (doc_log.date_time>=v_cur_per AND doc_log.date_time<in_date_time) )
			OR (NOT v_act_direct AND (doc_log.date_time<(v_cur_per+v_calc_interval) AND doc_log.date_time>=in_date_time) )
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (act.material_id=ANY(in_material_id_ar)))
		
		AND (
		
		act.quant<>0
		)
		ORDER BY doc_log.date_time,doc_log.id)


		UNION ALL
		--РУЧНЫЕ ИЗМЕНЕНИЯ
		(SELECT
		act.material_id
		,CASE act.deb
			WHEN TRUE THEN act.quant
			ELSE -act.quant
		END AS quant
										
		FROM ra_material_facts AS act
		
		WHERE (v_act_direct AND (act.date_time>=v_cur_per AND act.date_time<in_date_time)
			OR (NOT v_act_direct AND (act.date_time<(v_cur_per+v_calc_interval) AND act.date_time>=in_date_time) )
			)
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (act.material_id=ANY(in_material_id_ar)))
		AND act.doc_type IS NULL AND act.doc_id IS NULL
		AND (
		
		act.quant<>0
		)
		)
		
	) AS sub
	WHERE (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (sub.material_id=ANY(in_material_id_ar)))
	
	GROUP BY
		
		sub.material_id
	HAVING
		
		SUM(sub.quant)<>0
						
	ORDER BY
		
		sub.material_id;
END;			
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[])
  OWNER TO beton;



-- ******************* update 21/04/2020 12:06:46 ******************
-- Function: public.rg_material_facts_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_material_facts_balance(
    IN in_date_time timestamp without time zone,
    IN in_material_id_ar integer[])
  RETURNS TABLE(material_id integer, quant numeric) AS
$BODY$
DECLARE
	v_cur_per timestamp;
	v_act_direct boolean;
	v_act_direct_sgn int;
	v_calc_interval interval;
BEGIN
	v_cur_per = rg_period('material_fact'::reg_types, in_date_time);
	v_calc_interval = rg_calc_interval('material_fact'::reg_types);
	v_act_direct = TRUE;--( (rg_calc_period_end('material_fact'::reg_types,v_cur_per)-in_date_time)>(in_date_time - v_cur_per) );
	v_act_direct_sgn = 1;
	/*
	IF v_act_direct THEN
		v_act_direct_sgn = 1;
	ELSE
		v_act_direct_sgn = -1;
	END IF;
	*/
	--RAISE 'v_act_direct=%, v_cur_per=%, v_calc_interval=%',v_act_direct,v_cur_per,v_calc_interval;
	RETURN QUERY 
	SELECT 
	
	sub.material_id
	,SUM(sub.quant) AS quant				
	FROM(
		SELECT
		
		b.material_id
		,b.quant				
		FROM rg_material_facts AS b
		WHERE (v_act_direct AND b.date_time = (v_cur_per-v_calc_interval)) OR (NOT v_act_direct AND b.date_time = v_cur_per)
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (b.material_id=ANY(in_material_id_ar)))
		
		AND (
		b.quant<>0
		)
		
		UNION ALL
		
		(SELECT
		
		act.material_id
		,CASE act.deb
			WHEN TRUE THEN act.quant*v_act_direct_sgn
			ELSE -act.quant*v_act_direct_sgn
		END AS quant
										
		FROM doc_log
		LEFT JOIN ra_material_facts AS act ON act.doc_type=doc_log.doc_type AND act.doc_id=doc_log.doc_id
		WHERE (v_act_direct AND (doc_log.date_time>=v_cur_per AND doc_log.date_time<in_date_time) )
			OR (NOT v_act_direct AND (doc_log.date_time<(v_cur_per+v_calc_interval) AND doc_log.date_time>=in_date_time) )
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (act.material_id=ANY(in_material_id_ar)))
		
		AND (
		
		act.quant<>0
		)
		ORDER BY doc_log.date_time,doc_log.id)


		UNION ALL
		--РУЧНЫЕ ИЗМЕНЕНИЯ
		(SELECT
		act.material_id
		,CASE act.deb
			WHEN TRUE THEN act.quant
			ELSE -act.quant
		END AS quant
										
		FROM ra_material_facts AS act
		
		WHERE (v_act_direct AND (act.date_time>=v_cur_per AND act.date_time<in_date_time)
			--OR (NOT v_act_direct AND (act.date_time<(v_cur_per+v_calc_interval) AND act.date_time>=in_date_time) )
			)
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (act.material_id=ANY(in_material_id_ar)))
		--AND act.doc_type IS NULL AND act.doc_id IS NULL
		AND (
		
		act.quant<>0
		)
		)
		
	) AS sub
	WHERE (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (sub.material_id=ANY(in_material_id_ar)))
	
	GROUP BY
		
		sub.material_id
	HAVING
		
		SUM(sub.quant)<>0
						
	ORDER BY
		
		sub.material_id;
END;			
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[])
  OWNER TO beton;



-- ******************* update 21/04/2020 12:14:02 ******************
-- Function: public.rg_material_facts_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_material_facts_balance(
    IN in_date_time timestamp without time zone,
    IN in_material_id_ar integer[])
  RETURNS TABLE(material_id integer, quant numeric) AS
$BODY$
DECLARE
	v_cur_per timestamp;
	v_act_direct boolean;
	v_act_direct_sgn int;
	v_calc_interval interval;
BEGIN
	v_cur_per = rg_period('material_fact'::reg_types, in_date_time);
	v_calc_interval = rg_calc_interval('material_fact'::reg_types);
	v_act_direct = TRUE;--( (rg_calc_period_end('material_fact'::reg_types,v_cur_per)-in_date_time)>(in_date_time - v_cur_per) );
	v_act_direct_sgn = 1;
	/*
	IF v_act_direct THEN
		v_act_direct_sgn = 1;
	ELSE
		v_act_direct_sgn = -1;
	END IF;
	*/
	--RAISE 'v_act_direct=%, v_cur_per=%, v_calc_interval=%',v_act_direct,v_cur_per,v_calc_interval;
	RETURN QUERY 
	SELECT 
	
	sub.material_id
	,SUM(sub.quant) AS quant				
	FROM(
		SELECT
		
		b.material_id
		,b.quant				
		FROM rg_material_facts AS b
		WHERE (v_act_direct AND b.date_time = (v_cur_per-v_calc_interval)) OR (NOT v_act_direct AND b.date_time = v_cur_per)
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (b.material_id=ANY(in_material_id_ar)))
		
		AND (
		b.quant<>0
		)
		
		UNION ALL
		
		(SELECT
		
		act.material_id
		,CASE act.deb
			WHEN TRUE THEN act.quant*v_act_direct_sgn
			ELSE -act.quant*v_act_direct_sgn
		END AS quant
										
		FROM doc_log
		LEFT JOIN ra_material_facts AS act ON act.doc_type=doc_log.doc_type AND act.doc_id=doc_log.doc_id
		WHERE (v_act_direct AND (doc_log.date_time>=v_cur_per AND doc_log.date_time<in_date_time) )
			OR (NOT v_act_direct AND (doc_log.date_time<(v_cur_per+v_calc_interval) AND doc_log.date_time>=in_date_time) )
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (act.material_id=ANY(in_material_id_ar)))
		
		AND (
		
		act.quant<>0
		)
		ORDER BY doc_log.date_time,doc_log.id)


	) AS sub
	WHERE (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (sub.material_id=ANY(in_material_id_ar)))
	
	GROUP BY
		
		sub.material_id
	HAVING
		
		SUM(sub.quant)<>0
						
	ORDER BY
		
		sub.material_id;
END;			
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[])
  OWNER TO beton;



-- ******************* update 21/04/2020 12:17:37 ******************
-- Function: public.rg_material_facts_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_material_facts_balance(
    IN in_date_time timestamp without time zone,
    IN in_material_id_ar integer[])
  RETURNS TABLE(material_id integer, quant numeric) AS
$BODY$
DECLARE
	v_cur_per timestamp;
	v_act_direct boolean;
	v_act_direct_sgn int;
	v_calc_interval interval;
BEGIN
	v_cur_per = rg_period('material_fact'::reg_types, in_date_time);
	v_calc_interval = rg_calc_interval('material_fact'::reg_types);
	v_act_direct = TRUE;--( (rg_calc_period_end('material_fact'::reg_types,v_cur_per)-in_date_time)>(in_date_time - v_cur_per) );
	v_act_direct_sgn = 1;
	/*
	IF v_act_direct THEN
		v_act_direct_sgn = 1;
	ELSE
		v_act_direct_sgn = -1;
	END IF;
	*/
	--RAISE 'v_act_direct=%, v_cur_per=%, v_calc_interval=%',v_act_direct,v_cur_per,v_calc_interval;
	RETURN QUERY 
	SELECT 
	
	sub.material_id
	,SUM(sub.quant) AS quant				
	FROM(
		SELECT
		
		b.material_id
		,b.quant				
		FROM rg_material_facts AS b
		WHERE (v_act_direct AND b.date_time = (v_cur_per-v_calc_interval)) OR (NOT v_act_direct AND b.date_time = v_cur_per)
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (b.material_id=ANY(in_material_id_ar)))
		
		AND (
		b.quant<>0
		)
		
		UNION ALL
		
		(SELECT
		
		act.material_id
		,CASE act.deb
			WHEN TRUE THEN act.quant*v_act_direct_sgn
			ELSE -act.quant*v_act_direct_sgn
		END AS quant
										
		FROM ra_material_facts AS act
		WHERE (v_act_direct AND (act.date_time>=v_cur_per AND act<in_date_time) )
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (act.material_id=ANY(in_material_id_ar)))
		
		AND (
		
		act.quant<>0
		)
		ORDER BY act.date_time,act.id)


	) AS sub
	WHERE (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (sub.material_id=ANY(in_material_id_ar)))
	
	GROUP BY
		
		sub.material_id
	HAVING
		
		SUM(sub.quant)<>0
						
	ORDER BY
		
		sub.material_id;
END;			
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[])
  OWNER TO beton;



-- ******************* update 21/04/2020 12:18:38 ******************
-- Function: public.rg_material_facts_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_material_facts_balance(
    IN in_date_time timestamp without time zone,
    IN in_material_id_ar integer[])
  RETURNS TABLE(material_id integer, quant numeric) AS
$BODY$
DECLARE
	v_cur_per timestamp;
	v_act_direct boolean;
	v_act_direct_sgn int;
	v_calc_interval interval;
BEGIN
	v_cur_per = rg_period('material_fact'::reg_types, in_date_time);
	v_calc_interval = rg_calc_interval('material_fact'::reg_types);
	v_act_direct = TRUE;--( (rg_calc_period_end('material_fact'::reg_types,v_cur_per)-in_date_time)>(in_date_time - v_cur_per) );
	v_act_direct_sgn = 1;
	/*
	IF v_act_direct THEN
		v_act_direct_sgn = 1;
	ELSE
		v_act_direct_sgn = -1;
	END IF;
	*/
	--RAISE 'v_act_direct=%, v_cur_per=%, v_calc_interval=%',v_act_direct,v_cur_per,v_calc_interval;
	RETURN QUERY 
	SELECT 
	
	sub.material_id
	,SUM(sub.quant) AS quant				
	FROM(
		SELECT
		
		b.material_id
		,b.quant				
		FROM rg_material_facts AS b
		WHERE (v_act_direct AND b.date_time = (v_cur_per-v_calc_interval)) OR (NOT v_act_direct AND b.date_time = v_cur_per)
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (b.material_id=ANY(in_material_id_ar)))
		
		AND (
		b.quant<>0
		)
		
		UNION ALL
		
		(SELECT
		
		act.material_id
		,CASE act.deb
			WHEN TRUE THEN act.quant*v_act_direct_sgn
			ELSE -act.quant*v_act_direct_sgn
		END AS quant
										
		FROM ra_material_facts AS act
		WHERE (v_act_direct AND (act.date_time>=v_cur_per AND act.date_time<in_date_time) )
		
		AND (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (act.material_id=ANY(in_material_id_ar)))
		
		AND (
		
		act.quant<>0
		)
		ORDER BY act.date_time,act.id)


	) AS sub
	WHERE (ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (sub.material_id=ANY(in_material_id_ar)))
	
	GROUP BY
		
		sub.material_id
	HAVING
		
		SUM(sub.quant)<>0
						
	ORDER BY
		
		sub.material_id;
END;			
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_material_facts_balance(timestamp without time zone, integer[])
  OWNER TO beton;



-- ******************* update 21/04/2020 12:28:58 ******************
-- Function: public.rg_total_recalc_cement()

-- DROP FUNCTION public.rg_total_recalc_cement();

CREATE OR REPLACE FUNCTION public.rg_total_recalc_cement()
  RETURNS void AS
$BODY$  
DECLARE
	period_row RECORD;
	v_act_date_time timestamp without time zone;
	v_cur_period timestamp without time zone;
BEGIN	
	v_act_date_time = reg_current_balance_time();
	SELECT date_time INTO v_cur_period FROM rg_calc_periods;
	
	FOR period_row IN
		WITH
		periods AS (
			(SELECT
				DISTINCT date_trunc('month', date_time) AS d,
				cement_silos_id
			FROM ra_cement)
			UNION		
			(SELECT
				date_time AS d,
				cement_silos_id
			FROM rg_cement WHERE date_time<=v_cur_period
			)
			ORDER BY d			
		)
		SELECT sub.d,sub.cement_silos_id,sub.balance_fact,sub.balance_paper
		FROM
		(
		SELECT
			periods.d,
			periods.cement_silos_id,
			COALESCE((
				SELECT SUM(CASE WHEN deb THEN quant ELSE 0 END)-SUM(CASE WHEN NOT deb THEN quant ELSE 0 END)
				FROM ra_cement AS ra WHERE ra.date_time <= last_month_day(periods.d::date)+'23:59:59'::interval AND ra.cement_silos_id=periods.material_id
			),0) AS balance_fact,
			
			(
			SELECT SUM(quant) FROM rg_cement WHERE date_time=periods.d AND cement_silos_id=periods.cement_silos_id
			) AS balance_paper
			
		FROM periods
		) AS sub
		WHERE sub.balance_fact<>sub.balance_paper ORDER BY sub.d	
	LOOP
		
		UPDATE rg_cement AS rg
		SET quant = period_row.balance_fact
		WHERE rg.date_time=period_row.d AND rg.cement_silos_id=period_row.cement_silos_id;
		
		IF NOT FOUND THEN
			INSERT INTO rg_cement (date_time,cement_silos_id,quant)
			VALUES (period_row.d,period_row.cement_silos_id,period_row.balance_fact);
		END IF;
	END LOOP;

	--АКТУАЛЬНЫЕ ИТОГИ
	DELETE FROM rg_cement WHERE date_time>v_cur_period;
	
	INSERT INTO rg_cement (date_time,cement_silos_id,quant)
	(
	SELECT
		v_act_date_time,
		rg.cement_silos_id,
		COALESCE(rg.quant,0) +
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=TRUE
		),0) - 
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=FALSE
		),0)
		
	FROM rg_cement AS rg
	WHERE date_time=(v_cur_period-'1 month'::interval)
	);	
END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.rg_total_recalc_material_facts()
  OWNER TO beton;



-- ******************* update 21/04/2020 12:29:25 ******************
-- Function: public.rg_total_recalc_cement()

-- DROP FUNCTION public.rg_total_recalc_cement();

CREATE OR REPLACE FUNCTION public.rg_total_recalc_cement()
  RETURNS void AS
$BODY$  
DECLARE
	period_row RECORD;
	v_act_date_time timestamp without time zone;
	v_cur_period timestamp without time zone;
BEGIN	
	v_act_date_time = reg_current_balance_time();
	SELECT date_time INTO v_cur_period FROM rg_calc_periods;
	
	FOR period_row IN
		WITH
		periods AS (
			(SELECT
				DISTINCT date_trunc('month', date_time) AS d,
				cement_silos_id
			FROM ra_cement)
			UNION		
			(SELECT
				date_time AS d,
				cement_silos_id
			FROM rg_cement WHERE date_time<=v_cur_period
			)
			ORDER BY d			
		)
		SELECT sub.d,sub.cement_silos_id,sub.balance_fact,sub.balance_paper
		FROM
		(
		SELECT
			periods.d,
			periods.cement_silos_id,
			COALESCE((
				SELECT SUM(CASE WHEN deb THEN quant ELSE 0 END)-SUM(CASE WHEN NOT deb THEN quant ELSE 0 END)
				FROM ra_cement AS ra WHERE ra.date_time <= last_month_day(periods.d::date)+'23:59:59'::interval AND ra.cement_silos_id=periods.material_id
			),0) AS balance_fact,
			
			(
			SELECT SUM(quant) FROM rg_cement WHERE date_time=periods.d AND cement_silos_id=periods.cement_silos_id
			) AS balance_paper
			
		FROM periods
		) AS sub
		WHERE sub.balance_fact<>sub.balance_paper ORDER BY sub.d	
	LOOP
		
		UPDATE rg_cement AS rg
		SET quant = period_row.balance_fact
		WHERE rg.date_time=period_row.d AND rg.cement_silos_id=period_row.cement_silos_id;
		
		IF NOT FOUND THEN
			INSERT INTO rg_cement (date_time,cement_silos_id,quant)
			VALUES (period_row.d,period_row.cement_silos_id,period_row.balance_fact);
		END IF;
	END LOOP;

	--АКТУАЛЬНЫЕ ИТОГИ
	DELETE FROM rg_cement WHERE date_time>v_cur_period;
	
	INSERT INTO rg_cement (date_time,cement_silos_id,quant)
	(
	SELECT
		v_act_date_time,
		rg.cement_silos_id,
		COALESCE(rg.quant,0) +
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=TRUE
		),0) - 
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=FALSE
		),0)
		
	FROM rg_cement AS rg
	WHERE date_time=(v_cur_period-'1 month'::interval)
	);	
END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.rg_total_recalc_material_facts()
  OWNER TO beton;



-- ******************* update 21/04/2020 12:30:07 ******************
-- Function: public.rg_cement_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_cement_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_cement_balance(
    IN in_date_time timestamp without time zone,
    IN in_cement_silos_id_ar integer[])
  RETURNS TABLE(cement_silos_id integer, quant numeric) AS
$BODY$
DECLARE
	v_cur_per timestamp;
	v_act_direct boolean;
	v_act_direct_sgn int;
	v_calc_interval interval;
BEGIN
	v_cur_per = rg_period('cement'::reg_types, in_date_time);
	v_calc_interval = rg_calc_interval('cement'::reg_types);
	v_act_direct = TRUE;--( (rg_calc_period_end('cement'::reg_types,v_cur_per)-in_date_time)>(in_date_time - v_cur_per) );
	v_act_direct_sgn = 1;
	/*
	IF v_act_direct THEN
		v_act_direct_sgn = 1;
	ELSE
		v_act_direct_sgn = -1;
	END IF;
	*/
	--RAISE 'v_act_direct=%, v_cur_per=%, v_calc_interval=%',v_act_direct,v_cur_per,v_calc_interval;
	RETURN QUERY 
	SELECT 
	
	sub.cement_silos_id
	,SUM(sub.quant) AS quant				
	FROM(
		SELECT
		
		b.cement_silos_id
		,b.quant				
		FROM rg_cement AS b
		WHERE (v_act_direct AND b.date_time = (v_cur_per-v_calc_interval)) OR (NOT v_act_direct AND b.date_time = v_cur_per)
		
		AND (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (b.cement_silos_id=ANY(in_cement_silos_id_ar)))
		
		AND (
		b.quant<>0
		)
		
		UNION ALL
		
		(SELECT
		
		act.cement_silos_id
		,CASE act.deb
			WHEN TRUE THEN act.quant*v_act_direct_sgn
			ELSE -act.quant*v_act_direct_sgn
		END AS quant
										
		FROM ra_cement AS act
		WHERE (v_act_direct AND (act.date_time>=v_cur_per AND act.date_time<in_date_time) )
		
		AND (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (act.cement_silos_id=ANY(in_cement_silos_id_ar)))
		
		AND (
		
		act.quant<>0
		)
		ORDER BY act.date_time,act.id)


	) AS sub
	WHERE (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (sub.cement_silos_id=ANY(in_cement_silos_id_ar)))
	
	GROUP BY
		
		sub.cement_silos_id
	HAVING
		
		SUM(sub.quant)<>0
						
	ORDER BY
		
		sub.cement_silos_id;
END;			
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_cement_balance(timestamp without time zone, integer[])
  OWNER TO beton;



-- ******************* update 21/04/2020 12:30:44 ******************
-- Function: public.rg_total_recalc_cement()

-- DROP FUNCTION public.rg_total_recalc_cement();

CREATE OR REPLACE FUNCTION public.rg_total_recalc_cement()
  RETURNS void AS
$BODY$  
DECLARE
	period_row RECORD;
	v_act_date_time timestamp without time zone;
	v_cur_period timestamp without time zone;
BEGIN	
	v_act_date_time = reg_current_balance_time();
	SELECT date_time INTO v_cur_period FROM rg_calc_periods;
	
	FOR period_row IN
		WITH
		periods AS (
			(SELECT
				DISTINCT date_trunc('month', date_time) AS d,
				cement_silos_id
			FROM ra_cement)
			UNION		
			(SELECT
				date_time AS d,
				cement_silos_id
			FROM rg_cement WHERE date_time<=v_cur_period
			)
			ORDER BY d			
		)
		SELECT sub.d,sub.cement_silos_id,sub.balance_fact,sub.balance_paper
		FROM
		(
		SELECT
			periods.d,
			periods.cement_silos_id,
			COALESCE((
				SELECT SUM(CASE WHEN deb THEN quant ELSE 0 END)-SUM(CASE WHEN NOT deb THEN quant ELSE 0 END)
				FROM ra_cement AS ra WHERE ra.date_time <= last_month_day(periods.d::date)+'23:59:59'::interval AND ra.cement_silos_id=periods.material_id
			),0) AS balance_fact,
			
			(
			SELECT SUM(quant) FROM rg_cement WHERE date_time=periods.d AND cement_silos_id=periods.cement_silos_id
			) AS balance_paper
			
		FROM periods
		) AS sub
		WHERE sub.balance_fact<>sub.balance_paper ORDER BY sub.d	
	LOOP
		
		UPDATE rg_cement AS rg
		SET quant = period_row.balance_fact
		WHERE rg.date_time=period_row.d AND rg.cement_silos_id=period_row.cement_silos_id;
		
		IF NOT FOUND THEN
			INSERT INTO rg_cement (date_time,cement_silos_id,quant)
			VALUES (period_row.d,period_row.cement_silos_id,period_row.balance_fact);
		END IF;
	END LOOP;

	--АКТУАЛЬНЫЕ ИТОГИ
	DELETE FROM rg_cement WHERE date_time>v_cur_period;
	
	INSERT INTO rg_cement (date_time,cement_silos_id,quant)
	(
	SELECT
		v_act_date_time,
		rg.cement_silos_id,
		COALESCE(rg.quant,0) +
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=TRUE
		),0) - 
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=FALSE
		),0)
		
	FROM rg_cement AS rg
	WHERE date_time=(v_cur_period-'1 month'::interval)
	);	
END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.rg_total_recalc_cement()
  OWNER TO beton;



-- ******************* update 21/04/2020 12:31:02 ******************
-- Function: public.rg_total_recalc_cement()

-- DROP FUNCTION public.rg_total_recalc_cement();

CREATE OR REPLACE FUNCTION public.rg_total_recalc_cement()
  RETURNS void AS
$BODY$  
DECLARE
	period_row RECORD;
	v_act_date_time timestamp without time zone;
	v_cur_period timestamp without time zone;
BEGIN	
	v_act_date_time = reg_current_balance_time();
	SELECT date_time INTO v_cur_period FROM rg_calc_periods;
	
	FOR period_row IN
		WITH
		periods AS (
			(SELECT
				DISTINCT date_trunc('month', date_time) AS d,
				cement_silos_id
			FROM ra_cement)
			UNION		
			(SELECT
				date_time AS d,
				cement_silos_id
			FROM rg_cement WHERE date_time<=v_cur_period
			)
			ORDER BY d			
		)
		SELECT sub.d,sub.cement_silos_id,sub.balance_fact,sub.balance_paper
		FROM
		(
		SELECT
			periods.d,
			periods.cement_silos_id,
			COALESCE((
				SELECT SUM(CASE WHEN deb THEN quant ELSE 0 END)-SUM(CASE WHEN NOT deb THEN quant ELSE 0 END)
				FROM ra_cement AS ra WHERE ra.date_time <= last_month_day(periods.d::date)+'23:59:59'::interval AND ra.cement_silos_id=periods.cement_silos_id
			),0) AS balance_fact,
			
			(
			SELECT SUM(quant) FROM rg_cement WHERE date_time=periods.d AND cement_silos_id=periods.cement_silos_id
			) AS balance_paper
			
		FROM periods
		) AS sub
		WHERE sub.balance_fact<>sub.balance_paper ORDER BY sub.d	
	LOOP
		
		UPDATE rg_cement AS rg
		SET quant = period_row.balance_fact
		WHERE rg.date_time=period_row.d AND rg.cement_silos_id=period_row.cement_silos_id;
		
		IF NOT FOUND THEN
			INSERT INTO rg_cement (date_time,cement_silos_id,quant)
			VALUES (period_row.d,period_row.cement_silos_id,period_row.balance_fact);
		END IF;
	END LOOP;

	--АКТУАЛЬНЫЕ ИТОГИ
	DELETE FROM rg_cement WHERE date_time>v_cur_period;
	
	INSERT INTO rg_cement (date_time,cement_silos_id,quant)
	(
	SELECT
		v_act_date_time,
		rg.cement_silos_id,
		COALESCE(rg.quant,0) +
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=TRUE
		),0) - 
		COALESCE((
		SELECT sum(ra.quant) FROM
		ra_cement AS ra
		WHERE ra.date_time BETWEEN v_cur_period AND last_month_day(v_cur_period::date)+'23:59:59'::interval
			AND ra.cement_silos_id=rg.cement_silos_id
			AND ra.deb=FALSE
		),0)
		
	FROM rg_cement AS rg
	WHERE date_time=(v_cur_period-'1 month'::interval)
	);	
END;	
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.rg_total_recalc_cement()
  OWNER TO beton;



-- ******************* update 21/04/2020 13:25:12 ******************
-- Function: public.rg_cement_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_cement_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_cement_balance(
    IN in_date_time timestamp without time zone,
    IN in_cement_silos_id_ar integer[])
  RETURNS TABLE(cement_silos_id integer, quant numeric) AS
$BODY$
DECLARE
	v_cur_per timestamp;
	v_act_direct boolean;
	v_act_direct_sgn int;
	v_calc_interval interval;
BEGIN
	v_cur_per = rg_period('cement'::reg_types, in_date_time);
	v_calc_interval = rg_calc_interval('cement'::reg_types);
	v_act_direct = TRUE;--( (rg_calc_period_end('cement'::reg_types,v_cur_per)-in_date_time)>(in_date_time - v_cur_per) );
	v_act_direct_sgn = 1;
	/*
	IF v_act_direct THEN
		v_act_direct_sgn = 1;
	ELSE
		v_act_direct_sgn = -1;
	END IF;
	*/
	--RAISE 'v_act_direct=%, v_cur_per=%, v_calc_interval=%',v_act_direct,v_cur_per,v_calc_interval;
	RETURN QUERY 
	SELECT 
	
	sub.cement_silos_id
	,SUM(sub.quant) AS quant				
	FROM(
		SELECT
		
		b.cement_silos_id
		,b.quant				
		FROM rg_cement AS b
		WHERE (v_act_direct AND b.date_time = (v_cur_per-v_calc_interval)) OR (NOT v_act_direct AND b.date_time = v_cur_per)
		
		AND (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (b.cement_silos_id=ANY(in_cement_silos_id_ar)))
		
		AND (
		b.quant<>0
		)
		
		UNION ALL
		
		(SELECT
		
		act.cement_silos_id
		,CASE act.deb
			WHEN TRUE THEN act.quant*v_act_direct_sgn
			ELSE -act.quant*v_act_direct_sgn
		END AS quant
										
		FROM ra_cement AS act
		WHERE (v_act_direct AND (act.date_time>=v_cur_per AND act.date_time<in_date_time) )
		
		AND (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (act.cement_silos_id=ANY(in_cement_silos_id_ar)))
		
		AND (
		
		act.quant<>0
		)
		ORDER BY act.date_time,act.id)


	) AS sub
	WHERE (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (sub.cement_silos_id=ANY(in_cement_silos_id_ar)))
	
	GROUP BY
		
		sub.cement_silos_id
	HAVING
		
		SUM(sub.quant)<>0
						
	ORDER BY
		
		sub.cement_silos_id;
END;			
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_cement_balance(timestamp without time zone, integer[])
  OWNER TO beton;



-- ******************* update 21/04/2020 13:28:05 ******************
-- Function: public.rg_cement_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_cement_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_cement_balance(
    IN in_date_time timestamp without time zone,
    IN in_cement_silos_id_ar integer[])
  RETURNS TABLE(cement_silos_id integer, quant numeric) AS
$BODY$
DECLARE
	v_cur_per timestamp;
	v_act_direct boolean;
	v_act_direct_sgn int;
	v_calc_interval interval;
BEGIN
	v_cur_per = rg_period('cement'::reg_types, in_date_time);
	v_calc_interval = rg_calc_interval('cement'::reg_types);
	v_act_direct = TRUE;--( (rg_calc_period_end('cement'::reg_types,v_cur_per)-in_date_time)>(in_date_time - v_cur_per) );
	v_act_direct_sgn = 1;
	/*
	IF v_act_direct THEN
		v_act_direct_sgn = 1;
	ELSE
		v_act_direct_sgn = -1;
	END IF;
	*/
	--RAISE 'v_act_direct=%, v_cur_per=%, v_calc_interval=%',v_act_direct,v_cur_per,v_calc_interval;
	RETURN QUERY 
	SELECT 
	
	sub.cement_silos_id
	,SUM(sub.quant) AS quant				
	FROM(
		SELECT
		
		b.cement_silos_id
		,b.quant				
		FROM rg_cement AS b
		WHERE (v_act_direct AND b.date_time = (v_cur_per-v_calc_interval)) OR (NOT v_act_direct AND b.date_time = v_cur_per)
		
		AND (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (b.cement_silos_id=ANY(in_cement_silos_id_ar)))
		
		AND (
		b.quant<>0
		)
		
		UNION ALL
		
		(SELECT
		
		act.cement_silos_id
		,CASE act.deb
			WHEN TRUE THEN act.quant*v_act_direct_sgn
			ELSE -act.quant*v_act_direct_sgn
		END AS quant
										
		FROM ra_cement AS act
		WHERE (v_act_direct AND (act.date_time>=v_cur_per AND act.date_time<in_date_time) )
		
		AND (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (act.cement_silos_id=ANY(in_cement_silos_id_ar)))
		
		AND (
		
		act.quant<>0
		)
		--ORDER BY act.date_time,act.id
		)


	) AS sub
	WHERE (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (sub.cement_silos_id=ANY(in_cement_silos_id_ar)))
	
	GROUP BY
		
		sub.cement_silos_id
	HAVING
		
		SUM(sub.quant)<>0
						
	ORDER BY
		
		sub.cement_silos_id;
END;			
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_cement_balance(timestamp without time zone, integer[])
  OWNER TO beton;



-- ******************* update 21/04/2020 13:45:25 ******************
-- VIEW: material_fact_consumptions_list

--DROP VIEW material_fact_consumptions_list CASCADE;

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
		t.material_quant_req,
		
		--Ошибка в марке
		(t.concrete_type_id IS NOT NULL AND t.concrete_type_id<>o.concrete_type_id) AS err_concrete_type,
		
		ra_mat.quant AS material_quant_shipped,
		(
			(CASE WHEN ra_mat.quant IS NULL OR ra_mat.quant=0 THEN TRUE
				ELSE abs(t.material_quant/ra_mat.quant*100-100)>=mat.max_required_quant_tolerance_percent
			END)
			OR
			(CASE WHEN t.material_quant_req IS NULL OR t.material_quant_req=0 THEN TRUE
				ELSE abs(t.material_quant/t.material_quant_req*100-100)>=mat.max_required_quant_tolerance_percent
			END
			)
		) AS material_quant_tolerance_exceeded,
		
		concrete_types_ref(ct_o) AS order_concrete_types_ref
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	LEFT JOIN vehicle_schedule_states AS vh_sch_st ON vh_sch_st.id=t.vehicle_schedule_state_id
	LEFT JOIN shipments AS sh ON sh.id=vh_sch_st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id
	LEFT JOIN concrete_types AS ct_o ON ct_o.id=o.concrete_type_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=sh.id AND ra_mat.material_id=t.raw_material_id
	ORDER BY pr.name,t.date_time DESC,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO beton;


-- ******************* update 21/04/2020 14:27:19 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		IF NEW.raw_material_id IS NOT NULL THEN
			SELECT is_cement INTO v_is_cement FROM raw_materials WHERE id=NEW.raw_material_id;
		END IF;	
				
		IF NEW.raw_material_id IS NOT NULL AND v_is_cement  THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.raw_material_id IS NOT NULL
			AND v_is_cement
			 AND NEW.cement_silo_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 21/04/2020 14:33:42 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time-'1 second'::interval);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		
		IF (SELECT is_cement FROM raw_materials WHERE id=NEW.material_id) THEN
			--ЦЕМЕНТ
			RAISE EXCEPTION 'Остатки по цементу обнуляются в разрезе силосов!';
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)			
					- NEW.required_balance_quant;
			--RAISE EXCEPTION 'BALANCE=%',add_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.balance_date_time<>OLD.balance_date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time-'1 second'::interval);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 21/04/2020 14:37:35 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		IF NEW.raw_material_id IS NOT NULL THEN
			SELECT is_cement INTO v_is_cement FROM raw_materials WHERE id=NEW.raw_material_id;
		END IF;	
				
		IF NEW.raw_material_id IS NOT NULL AND NOT v_is_cement  THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.raw_material_id IS NOT NULL
			AND v_is_cement
			 AND NEW.cement_silo_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 21/04/2020 17:43:13 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		IF NEW.raw_material_id IS NOT NULL THEN
			SELECT is_cement INTO v_is_cement FROM raw_materials WHERE id=NEW.raw_material_id;
		END IF;	
				
		IF NEW.raw_material_id IS NOT NULL AND NOT v_is_cement  THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.raw_material_id IS NOT NULL
			AND v_is_cement
			 AND NEW.cement_silo_id IS NOT NULL THEN
			 
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
			 
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 21/04/2020 17:52:59 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		IF NEW.raw_material_id IS NOT NULL THEN
			SELECT is_cement INTO v_is_cement FROM raw_materials WHERE id=NEW.raw_material_id;
		END IF;	
				
		IF NEW.raw_material_id IS NOT NULL AND NOT v_is_cement  THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		ELSIF NEW.raw_material_id IS NOT NULL
			AND v_is_cement
			 AND NEW.cement_silo_id IS NOT NULL THEN
			 
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
			 
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 08:23:06 ******************
-- VIEW: material_fact_consumptions_list

--DROP VIEW material_fact_consumptions_list CASCADE;

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
		t.material_quant_req,
		
		--Ошибка в марке
		(t.concrete_type_id IS NOT NULL AND t.concrete_type_id<>o.concrete_type_id) AS err_concrete_type,
		
		ra_mat.quant AS material_quant_shipped,
		(
			(CASE WHEN ra_mat.quant IS NULL OR ra_mat.quant=0 THEN TRUE
				ELSE abs(t.material_quant/ra_mat.quant*100-100)>=mat.max_required_quant_tolerance_percent
			END)
			OR
			(CASE WHEN t.material_quant_req IS NULL OR t.material_quant_req=0 THEN TRUE
				ELSE abs(t.material_quant/t.material_quant_req*100-100)>=mat.max_required_quant_tolerance_percent
			END
			)
		) AS material_quant_tolerance_exceeded,
		
		concrete_types_ref(ct_o) AS order_concrete_types_ref,
		
		t.production_id
		
	FROM material_fact_consumptions AS t
	LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
	LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
	LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
	LEFT JOIN production_sites AS pr ON pr.id=t.production_site_id
	LEFT JOIN users AS u ON u.id=t.upload_user_id
	LEFT JOIN vehicle_schedule_states AS vh_sch_st ON vh_sch_st.id=t.vehicle_schedule_state_id
	LEFT JOIN shipments AS sh ON sh.id=vh_sch_st.shipment_id
	LEFT JOIN orders AS o ON o.id=sh.order_id
	LEFT JOIN concrete_types AS ct_o ON ct_o.id=o.concrete_type_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=sh.id AND ra_mat.material_id=t.raw_material_id
	ORDER BY pr.name,t.date_time DESC,mat.name
	;
	
ALTER VIEW material_fact_consumptions_list OWNER TO beton;


-- ******************* update 22/04/2020 08:23:43 ******************
-- VIEW: material_fact_consumptions_rolled_list

--DROP VIEW material_fact_consumptions_rolled_list;

CREATE OR REPLACE VIEW material_fact_consumptions_rolled_list AS
	SELECT
		date_time,
		upload_date_time,
		(upload_users_ref::text)::jsonb AS upload_users_ref,
		(production_sites_ref::text)::jsonb AS production_sites_ref,
		production_site_id,
		(concrete_types_ref::text)::jsonb AS concrete_types_ref,
		(order_concrete_types_ref::text)::jsonb AS order_concrete_types_ref,
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
				'quant_req',material_quant_req,
				'quant_shipped',material_quant_shipped,
				'quant_tolerance_exceeded',material_quant_tolerance_exceeded
			)
		) AS materials,
		err_concrete_type,
		production_id
		
	FROM material_fact_consumptions_list
	GROUP BY date_time,
		concrete_quant,
		upload_date_time,
		upload_users_ref::text,
		production_sites_ref::text,
		production_site_id,
		concrete_types_ref::text,
		order_concrete_types_ref::text,
		concrete_type_production_descr,
		vehicles_ref::text,
		vehicle_production_descr,
		orders_ref::text,
		shipments_inf,
		err_concrete_type,
		production_id
	ORDER BY date_time DESC

	;
	
ALTER VIEW material_fact_consumptions_rolled_list OWNER TO beton;


-- ******************* update 22/04/2020 14:47:21 ******************
-- Function: public.doc_material_procurements_process()

-- DROP FUNCTION public.doc_material_procurements_process();

CREATE OR REPLACE FUNCTION public.doc_material_procurements_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_act ra_materials%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER') AND (TG_OP='INSERT' OR TG_OP='UPDATE') THEN					
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;

		--register actions ra_materials
		reg_act.date_time		= NEW.date_time;
		reg_act.deb			= true;
		reg_act.doc_type  		= 'material_procurement'::doc_types;
		reg_act.doc_id  		= NEW.id;
		reg_act.material_id		= NEW.material_id;
		reg_act.quant			= NEW.quant_net;
		PERFORM ra_materials_add_act(reg_act);	
		
		--По материалам делаем всегда движения, а если есть учет по силосам и есть силос - то и по силосам
		--register actions ra_material_facts
		reg_material_facts.date_time		= NEW.date_time;
		reg_material_facts.deb			= true;
		reg_material_facts.doc_type  		= 'material_procurement'::doc_types;
		reg_material_facts.doc_id  		= NEW.id;
		reg_material_facts.material_id		= NEW.material_id;
		reg_material_facts.quant		= NEW.quant_net;
		PERFORM ra_material_facts_add_act(reg_material_facts);	
		
		IF coalesce( (SELECT is_cement FROM raw_materials WHERE id = NEW.material_id),FALSE)
		AND NEW.cement_silos_id IS NOT NULL THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= true;
			reg_cement.doc_type  		= 'material_procurement'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.quant_net;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;
				
		RETURN NEW;
		
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);

		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_procurement'::doc_types,NEW.id,NEW.date_time);
		END IF;
						
		RETURN NEW;
	ELSIF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		RETURN OLD;
	ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN
		--detail tables
		
		--register actions										
		PERFORM ra_materials_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('material_procurement'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_procurement'::doc_types,OLD.id);
		
		--log
		PERFORM doc_log_delete('material_procurement'::doc_types,OLD.id);
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.doc_material_procurements_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 14:53:40 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		IF NEW.raw_material_id IS NOT NULL THEN
			SELECT is_cement INTO v_is_cement FROM raw_materials WHERE id=NEW.raw_material_id;
		END IF;	
		
		--Все материалы проходят по регистру учета материалов
		IF NEW.raw_material_id IS NOT NULL  THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
		
		--А те, что учитываются по силосам (с отметкой в справочнике), еще и по регистру силосов
		IF NEW.raw_material_id IS NOT NULL
		AND v_is_cement
		AND NEW.cement_silo_id IS NOT NULL THEN
			 
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
			 
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 14:57:06 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		IF NEW.raw_material_id IS NOT NULL THEN
			SELECT is_cement INTO v_is_cement FROM raw_materials WHERE id=NEW.raw_material_id;
		END IF;	
		
		--Все материалы проходят по регистру учета материалов
		IF NEW.raw_material_id IS NOT NULL  THEN
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
		
		--А те, что учитываются по силосам (с отметкой в справочнике), еще и по регистру силосов
		IF NEW.raw_material_id IS NOT NULL
		AND v_is_cement
		AND NEW.cement_silo_id IS NOT NULL THEN
			 
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
			 
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 14:57:46 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		--Все материалы проходят по регистру учета материалов
		IF NEW.raw_material_id IS NOT NULL  THEN
			SELECT is_cement INTO v_is_cement FROM raw_materials WHERE id=NEW.raw_material_id;		
			
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
		
		--А те, что учитываются по силосам (с отметкой в справочнике), еще и по регистру силосов
		IF NEW.raw_material_id IS NOT NULL
		AND v_is_cement
		AND NEW.cement_silo_id IS NOT NULL THEN
			 
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
			 
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 14:58:03 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		--Все материалы проходят по регистру учета материалов
		IF NEW.raw_material_id IS NOT NULL  THEN
			SELECT is_cement INTO v_is_cement FROM raw_materials WHERE id=NEW.raw_material_id;		
			
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
		
		--А те, что учитываются по силосам (с отметкой в справочнике), еще и по регистру силосов
		IF NEW.raw_material_id IS NOT NULL
		AND v_is_cement
		AND NEW.cement_silo_id IS NOT NULL THEN
			 
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silos_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_cement_add_act(reg_cement);	
			 
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 14:59:18 ******************
-- Function: public.material_fact_consumptions_process()

-- DROP FUNCTION public.material_fact_consumptions_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumptions_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_is_cement bool;
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;	
BEGIN
	IF (TG_WHEN='BEFORE' AND TG_OP='INSERT') THEN
		IF NEW.vehicle_schedule_state_id IS NULL THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;
		
		RETURN NEW;

	ELSEIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN

		--Все материалы проходят по регистру учета материалов
		IF NEW.raw_material_id IS NOT NULL  THEN
			SELECT is_cement INTO v_is_cement FROM raw_materials WHERE id=NEW.raw_material_id;		
			
			--register actions ra_material_facts
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.raw_material_id;
			reg_material_facts.quant		= NEW.material_quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;
		
		--А те, что учитываются по силосам (с отметкой в справочнике), еще и по регистру силосов
		IF NEW.raw_material_id IS NOT NULL
		AND v_is_cement
		AND NEW.cement_silo_id IS NOT NULL THEN
			 
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= NEW.material_quant;
			PERFORM ra_cement_add_act(reg_cement);	
			 
		END IF;
			
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF (
		(coalesce(NEW.vehicle_id,0)<>coalesce(OLD.vehicle_id,0) OR NEW.date_time<>OLD.date_time)
		AND NEW.vehicle_schedule_state_id IS NULL
		) THEN
			SELECT material_fact_consumptions_find_schedule(NEW.date_time,NEW.vehicle_id) INTO NEW.vehicle_schedule_state_id;
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		IF OLD.cement_silo_id IS NOT NULL THEN
			PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
		END IF;
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		

			PERFORM ra_material_facts_remove_acts('material_fact_consumption'::doc_types,OLD.id);
		
			IF OLD.cement_silo_id IS NOT NULL THEN
				PERFORM ra_cement_remove_acts('material_fact_consumption'::doc_types,OLD.id);		
			END IF;
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumptions_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 15:01:23 ******************
-- Function: public.material_fact_balance_corrections_process()

-- DROP FUNCTION public.material_fact_balance_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_balance_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
	add_quant numeric(19,4);
	ra_date_time timestamp;	
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		IF NEW.balance_date_time IS NULL THEN
			NEW.balance_date_time = get_shift_start(NEW.date_time);
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time-'1 second'::interval);
		END IF;

		ra_date_time = NEW.balance_date_time-'1 second'::interval;
		
		IF (SELECT is_cement FROM raw_materials WHERE id=NEW.material_id) THEN
			--ЦЕМЕНТ
			RAISE EXCEPTION 'Остатки по материалам, учитываемым в силосах, корректируются в разрезе силосов!';
		ELSE
			add_quant = coalesce((SELECT quant FROM rg_material_facts_balance(ra_date_time,ARRAY[NEW.material_id])),0)			
					- NEW.required_balance_quant;
			--RAISE EXCEPTION 'BALANCE=%',add_quant;
			IF add_quant <> 0 THEN
				--RAISE EXCEPTION 'add_quant=%',add_quant;
				--register actions ra_material_facts		
				reg_material_facts.date_time		= ra_date_time;
				reg_material_facts.deb			= (add_quant<0);
				reg_material_facts.doc_type  		= 'material_fact_balance_correction'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= NEW.material_id;
				reg_material_facts.quant		= abs(add_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.balance_date_time<>OLD.balance_date_time THEN
			PERFORM doc_log_update('material_fact_balance_correction'::doc_types,NEW.id,NEW.balance_date_time-'1 second'::interval);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_balance_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_balance_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_balance_corrections_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 15:10:43 ******************
-- Function: public.material_fact_consumption_corrections_process()

-- DROP FUNCTION public.material_fact_consumption_corrections_process();

CREATE OR REPLACE FUNCTION public.material_fact_consumption_corrections_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_material_facts ra_material_facts%ROWTYPE;
	reg_cement ra_cement%ROWTYPE;
BEGIN
	IF TG_WHEN='BEFORE' AND TG_OP='INSERT' THEN
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('material_fact_consumption_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;


		IF NEW.quant <> 0 THEN
			--register actions ra_material_facts		
			reg_material_facts.date_time		= NEW.date_time;
			reg_material_facts.deb			= FALSE;
			reg_material_facts.doc_type  		= 'material_fact_consumption_correction'::doc_types;
			reg_material_facts.doc_id  		= NEW.id;
			reg_material_facts.material_id		= NEW.material_id;
			reg_material_facts.quant		= NEW.quant;
			PERFORM ra_material_facts_add_act(reg_material_facts);	
		END IF;

		IF (SELECT is_cement FROM raw_materials WHERE id=NEW.material_id)
		AND NEW.cement_silo_id IS NOT NULL THEN
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= FALSE;
			reg_cement.doc_type  		= 'material_fact_consumption_correction'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= NEW.quant;
			PERFORM ra_cement_add_act(reg_cement);	
		END IF;

		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('material_fact_consumption_correction'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_material_facts_remove_acts('material_fact_consumption_correction'::doc_types,OLD.id);
		PERFORM ra_cement_remove_acts('material_fact_consumption_correction'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('material_fact_consumption_correction'::doc_types,OLD.id);

			PERFORM ra_material_facts_remove_acts('material_fact_consumption_correction'::doc_types,OLD.id);
			PERFORM ra_cement_remove_acts('material_fact_consumption_correction'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.material_fact_consumption_corrections_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 15:11:41 ******************
-- Trigger: material_fact_consumption_corrections_trigger_before on public.material_fact_consumption_corrections

-- DROP TRIGGER material_fact_consumption_corrections_trigger_before ON public.material_fact_consumption_corrections;

/*
CREATE TRIGGER material_fact_consumption_corrections_trigger_before
  BEFORE UPDATE OR DELETE
  ON public.material_fact_consumption_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumption_corrections_process();
*/

-- DROP TRIGGER material_fact_consumption_corrections_trigger_after ON public.material_fact_consumption_corrections;

CREATE TRIGGER material_fact_consumption_corrections_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_consumption_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumption_corrections_process();



-- ******************* update 22/04/2020 15:11:50 ******************
-- Trigger: material_fact_consumption_corrections_trigger_before on public.material_fact_consumption_corrections

-- DROP TRIGGER material_fact_consumption_corrections_trigger_before ON public.material_fact_consumption_corrections;


CREATE TRIGGER material_fact_consumption_corrections_trigger_before
  BEFORE UPDATE OR DELETE
  ON public.material_fact_consumption_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumption_corrections_process();

/*
-- DROP TRIGGER material_fact_consumption_corrections_trigger_after ON public.material_fact_consumption_corrections;

CREATE TRIGGER material_fact_consumption_corrections_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_consumption_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumption_corrections_process();
*/


-- ******************* update 22/04/2020 15:18:49 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(ARRAY[NEW.cement_silo_id]) AS rg;		
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= CASE WHEN v_quant>0 THEN FALSE ELSE TRUE END;
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);	
			
			--Остатки материалов, материал отпределить по последнему приходу в силос
			SELECT material_id
			INTO v_material_id
			FROM doc_material_procurements
			WHERE cement_silos_id = NEW.cement_silo_id
			ORDER BY date_time DESC
			LIMIT 1;
			
			IF coalesce(v_material_id,0)>0 THEN
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= FALSE;
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;			
		END IF;
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 15:28:33 ******************
-- Function: public.mat_totals(date)

-- DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_fact_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	quant_morn_fact_cur_balance numeric,
  	balance_corrected_data json
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		
		COALESCE(bal_fact.quant,0)::numeric AS quant_fact_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		
		COALESCE(bal_morn_fact.quant,0)::numeric AS quant_morn_fact_cur_balance,
		
		--Корректировки
		(SELECT
			json_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'materials_ref',materials_ref(m),
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	LEFT JOIN (
		SELECT * FROM rg_material_facts_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn_fact ON bal_morn_fact.material_id=m.id

	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	LEFT JOIN (
		SELECT * FROM rg_material_facts_balance('{}')
	) AS bal_fact ON bal_fact.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;



-- ******************* update 22/04/2020 15:54:23 ******************
-- VIEW: cement_silo_balance_resets_list

--DROP VIEW cement_silo_balance_resets_list;

CREATE OR REPLACE VIEW cement_silo_balance_resets_list AS
	SELECT
		t.id
		,t.date_time
		,t.user_id
		,users_ref(u) AS users_ref
		,t.cement_silo_id
		,cement_silos_ref(sil) AS cement_silos_ref
		,t.comment_text
		,ra.quant
		,t.quant_required
		
	FROM cement_silo_balance_resets AS t
	LEFT JOIN users u ON u.id=t.user_id
	LEFT JOIN cement_silos sil ON sil.id=t.cement_silo_id
	LEFT JOIN ra_cement AS ra ON ra.doc_id = t.id AND ra.doc_type='cement_silo_balance_reset'::doc_types
	ORDER BY t.date_time DESC
	;
	
ALTER VIEW cement_silo_balance_resets_list OWNER TO beton;


-- ******************* update 22/04/2020 16:05:02 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(ARRAY[v_material_id]) AS rg;		
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:08:26 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN
		RAISE EXCEPTION 'v_material_id=%',v_material_id;
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(ARRAY[v_material_id]) AS rg;		
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:09:01 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN		
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(ARRAY[v_material_id]) AS rg;		
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			RAISE EXCEPTION 'v_quant=%',v_quant;
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:09:37 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN		
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(ARRAY[v_material_id]) AS rg;		
			RAISE EXCEPTION 'v_quant=%',v_quant;
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:12:59 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(NEW.date_time,ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN		
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(NEW.date_time,ARRAY[v_material_id]) AS rg;		
			RAISE EXCEPTION 'v_quant=%',v_quant;
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:13:05 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(NEW.date_time,ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN		
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(NEW.date_time,ARRAY[v_material_id]) AS rg;		
			--RAISE EXCEPTION 'v_quant=%',v_quant;
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:15:47 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(NEW.date_time,ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN		
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(NEW.date_time,ARRAY[v_material_id]) AS rg;		
			RAISE EXCEPTION 'v_quant=%',v_quant;
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:16:06 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(NEW.date_time,ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN		
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(NEW.date_time,ARRAY[v_material_id]) AS rg;		
			
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			RAISE EXCEPTION 'v_quant=%',v_quant;
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:16:38 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(NEW.date_time,ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN		
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(NEW.date_time,ARRAY[v_material_id]) AS rg;		
			
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			--RAISE EXCEPTION 'v_quant=%',v_quant;
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= v_quant;
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:18:16 ******************
-- Function: public.cement_silo_balance_resets_process()

-- DROP FUNCTION public.cement_silo_balance_resets_process();

CREATE OR REPLACE FUNCTION public.cement_silo_balance_resets_process()
  RETURNS trigger AS
$BODY$
DECLARE
	reg_cement ra_cement%ROWTYPE;
	reg_material_facts ra_material_facts%ROWTYPE;
	v_quant numeric(19,4);
	v_material_id int;
BEGIN
	IF (TG_WHEN='AFTER' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN
		IF (TG_OP='INSERT') THEN						
			--log
			PERFORM doc_log_insert('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;
	
		SELECT rg.quant INTO v_quant FROM rg_cement_balance(NEW.date_time,ARRAY[NEW.cement_silo_id]) AS rg;		
		v_quant = NEW.quant_required - coalesce(v_quant,0);
		IF v_quant<>0 THEN
			--register actions ra_cement
			reg_cement.date_time		= NEW.date_time;
			reg_cement.deb			= (v_quant>0);
			reg_cement.doc_type  		= 'cement_silo_balance_reset'::doc_types;
			reg_cement.doc_id  		= NEW.id;
			reg_cement.cement_silos_id	= NEW.cement_silo_id;
			reg_cement.quant		= abs(v_quant);
			PERFORM ra_cement_add_act(reg_cement);				
		END IF;
		
		--Остатки материалов, материал отпределить по последнему приходу в силос
		SELECT material_id
		INTO v_material_id
		FROM doc_material_procurements
		WHERE cement_silos_id = NEW.cement_silo_id
		ORDER BY date_time DESC
		LIMIT 1;
		
		IF coalesce(v_material_id,0)>0 THEN		
			--здесь определяем свое количество по регистру материалов
			SELECT rg.quant INTO v_quant FROM rg_material_facts_balance(NEW.date_time,ARRAY[v_material_id]) AS rg;		
			
			v_quant = NEW.quant_required - coalesce(v_quant,0);
			--RAISE EXCEPTION 'v_quant=%',v_quant;
			IF v_quant<>0 THEN			
				reg_material_facts.date_time		= NEW.date_time;
				reg_material_facts.deb			= (v_quant>0);
				reg_material_facts.doc_type  		= 'cement_silo_balance_reset'::doc_types;
				reg_material_facts.doc_id  		= NEW.id;
				reg_material_facts.material_id		= v_material_id;
				reg_material_facts.quant		= abs(v_quant);
				PERFORM ra_material_facts_add_act(reg_material_facts);	
			END IF;
		END IF;			
		
		RETURN NEW;
		
	ELSEIF (TG_WHEN='BEFORE' AND TG_OP='UPDATE') THEN
		IF NEW.date_time<>OLD.date_time THEN
			PERFORM doc_log_update('cement_silo_balance_reset'::doc_types,NEW.id,NEW.date_time);
		END IF;

		PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		RETURN NEW;
		
	ELSEIF TG_OP='DELETE' THEN
		IF TG_WHEN='BEFORE' THEN		
			--log
			PERFORM doc_log_delete('cement_silo_balance_reset'::doc_types,OLD.id);

			PERFORM ra_cement_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
			PERFORM ra_material_facts_remove_acts('cement_silo_balance_reset'::doc_types,OLD.id);
		
		END IF;
	
		RETURN OLD;
	END IF;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silo_balance_resets_process()
  OWNER TO beton;



-- ******************* update 22/04/2020 16:23:17 ******************
-- Function: public.mat_totals(date)

-- DROP FUNCTION public.mat_totals(date);

CREATE OR REPLACE FUNCTION public.mat_totals(IN date)
  RETURNS TABLE(
  	material_id integer,
  	material_descr text,
  	quant_ordered numeric,
  	quant_procured numeric,
  	quant_balance numeric,
  	quant_fact_balance numeric,
  	quant_morn_balance numeric,--depricated
  	quant_morn_next_balance numeric,--use instead  	
  	quant_morn_cur_balance numeric,
  	quant_morn_fact_cur_balance numeric,
  	balance_corrected_data json
  ) AS
$BODY$
	/*
	WITH rates AS(
	SELECT *
	FROM raw_material_cons_rates(NULL,$1)	
	)
	*/
	SELECT
		m.id AS material_id,
		m.name::text AS material_descr,
		
		--заявки поставщикам на сегодня
		COALESCE(sup_ord.quant,0)::numeric AS quant_ordered,
		
		--Поставки
		COALESCE(proc.quant,0)::numeric AS quant_procured,
		
		--остатки
		COALESCE(bal.quant,0)::numeric AS quant_balance,
		
		COALESCE(bal_fact.quant,0)::numeric AS quant_fact_balance,
		
		--остатки на завтра на утро
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_balance,
		COALESCE(plan_proc.quant,0)::numeric AS quant_morn_next_balance,
		
		COALESCE(bal_morn.quant,0)::numeric AS quant_morn_cur_balance,
		
		COALESCE(bal_morn_fact.quant,0)::numeric AS quant_morn_fact_cur_balance,
		
		--Корректировки
		(SELECT
			json_agg(
				json_build_object(
					'date_time',cr.date_time,
					'balance_date_time',cr.balance_date_time,
					'users_ref',users_ref(cr_u),
					'materials_ref',materials_ref(m),
					'required_balance_quant',cr.required_balance_quant,
					'comment_text',cr.comment_text
				)
			)
		FROM material_fact_balance_corrections AS cr
		LEFT JOIN users AS cr_u ON cr_u.id=cr.user_id	
		WHERE cr.material_id=m.id AND cr.balance_date_time=$1+const_first_shift_start_time_val()
		) AS balance_corrected_data
		
	FROM raw_materials AS m

	LEFT JOIN (
		SELECT *
		FROM rg_materials_balance($1+const_first_shift_start_time_val()-'1 second'::interval,'{}')
	) AS bal_morn ON bal_morn.material_id=m.id
	LEFT JOIN (
		SELECT * FROM rg_material_facts_balance($1+const_first_shift_start_time_val(),'{}')
	) AS bal_morn_fact ON bal_morn_fact.material_id=m.id

	
	LEFT JOIN (
		SELECT *
		--$1+const_first_shift_start_time_val()+const_shift_length_time_val()::interval-'1 second'::interval,
		FROM rg_materials_balance('{}')
	) AS bal ON bal.material_id=m.id
	LEFT JOIN (
		SELECT * FROM rg_material_facts_balance('{}')
	) AS bal_fact ON bal_fact.material_id=m.id
	
	LEFT JOIN (
		SELECT
			ra.material_id,
			sum(ra.quant) AS quant
		FROM ra_materials ra
		WHERE ra.date_time BETWEEN
					get_shift_start(now()::date+'1 day'::interval)
				AND get_shift_end(get_shift_start(now()::date+'1 day'::interval))
			AND ra.deb
			AND ra.doc_type='material_procurement'
		GROUP BY ra.material_id
	) AS proc ON proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			plan_proc.material_id,
			plan_proc.balance_start AS quant
		FROM mat_plan_procur(
		get_shift_end((get_shift_end(get_shift_start(now()::timestamp))+'1 second')),
		now()::timestamp,
		now()::timestamp,
		NULL
		) AS plan_proc
	) AS plan_proc ON plan_proc.material_id=m.id
	
	LEFT JOIN (
		SELECT
			so.material_id,
			SUM(so.quant) AS quant
		FROM supplier_orders AS so
		WHERE so.date=$1
		GROUP BY so.material_id
	) AS sup_ord ON sup_ord.material_id=m.id
	
	WHERE m.concrete_part
	ORDER BY m.ord;
$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.mat_totals(date) OWNER TO beton;