-- Trigger: logins_trigger_after on public.logins

-- DROP TRIGGER logins_trigger_after ON public.logins;


CREATE TRIGGER logins_trigger_after
  AFTER UPDATE
  ON public.logins
  FOR EACH ROW
  EXECUTE PROCEDURE public.logins_process();

