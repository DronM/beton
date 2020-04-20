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
  OWNER TO ;

