-- Function: sessions_process()

-- DROP FUNCTION sessions_process();

CREATE OR REPLACE FUNCTION sessions_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='DELETE') THEN
		UPDATE logins SET date_time_out = now() WHERE session_id=OLD.id;
		
		RETURN OLD;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sessions_process() OWNER TO ;

