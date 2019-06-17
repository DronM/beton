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