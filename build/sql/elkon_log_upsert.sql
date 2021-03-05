-- Function: elkon_log_upsert(in_elkon_log elkon_log)

-- DROP FUNCTION elkon_log_upsert(in_elkon_log elkon_log);

CREATE OR REPLACE FUNCTION elkon_log_upsert(in_elkon_log elkon_log)
  RETURNS void AS
$$
DECLARE
	v_message text;
	v_id int;
BEGIN
	SELECT
		id,
		message
	INTO
		v_id,
		v_message
	FROM elkon_log	
	WHERE production_site_id=in_elkon_log.production_site_id
	ORDER BY date_time desc
	LIMIT 1;
	
	IF v_id IS NOT NULL AND v_message = in_elkon_log.message THEN
		UPDATE elkon_log
		SET date_time = now()
		WHERE id = v_id;
	ELSE
		INSERT INTO elkon_log (production_site_id, level, message)
		values (in_elkon_log.production_site_id, in_elkon_log.level, in_elkon_log.message);
	END IF;
END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION elkon_log_upsert(in_elkon_log elkon_log) OWNER TO ;
