-- Trigger:cement_silo_balance_resets_trigger_after on public.cement_silo_balance_resets

-- DROP TRIGGER cement_silo_balance_resets_trigger_after ON public.cement_silo_balance_resets;
/*
CREATE TRIGGER cement_silo_balance_resets_trigger_after
  AFTER INSERT OR UPDATE
  ON public.cement_silo_balance_resets
  FOR EACH ROW
  EXECUTE PROCEDURE public.cement_silo_balance_resets_process();
*/

-- Trigger:cement_silo_balance_resets_trigger_before on public.cement_silo_balance_resets

 DROP TRIGGER cement_silo_balance_resets_trigger_before ON public.cement_silo_balance_resets;

CREATE TRIGGER cement_silo_balance_resets_trigger_before
  BEFORE DELETE OR UPDATE
  ON public.cement_silo_balance_resets
  FOR EACH ROW
  EXECUTE PROCEDURE public.cement_silo_balance_resets_process();

