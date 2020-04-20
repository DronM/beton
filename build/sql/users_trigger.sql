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

