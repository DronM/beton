-- Trigger: sessions_trigger_after on public.sessions

-- DROP TRIGGER sessions_trigger_after ON public.sessions;

CREATE TRIGGER sessions_trigger_after
  AFTER DELETE
  ON public.sessions
  FOR EACH ROW
  EXECUTE PROCEDURE public.sessions_process();

