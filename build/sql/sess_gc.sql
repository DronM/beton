-- Function: sess_gc(interval)

-- DROP FUNCTION sess_gc(interval);

CREATE OR REPLACE FUNCTION sess_gc(in_lifetime interval)
  RETURNS void AS
$BODY$	
	UPDATE public.logins
	SET date_time_out = now()
	WHERE session_id IN (SELECT id FROM public.sessions WHERE set_time<(now()-in_lifetime));
	
	DELETE FROM public.sessions WHERE set_time < (now()-in_lifetime);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION sess_gc(interval)
  OWNER TO beton;

