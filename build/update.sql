
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

