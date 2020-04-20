-- Trigger: material_fact_balance_corrections_trigger_before on public.material_fact_balance_corrections

-- DROP TRIGGER material_fact_balance_corrections_trigger_before ON public.material_fact_balance_corrections;

/*
CREATE TRIGGER material_fact_balance_corrections_trigger_before
  BEFORE INSERT OR UPDATE OR DELETE
  ON public.material_fact_balance_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_balance_corrections_process();
*/

-- DROP TRIGGER material_fact_balance_corrections_trigger_after ON public.material_fact_balance_corrections;

CREATE TRIGGER material_fact_balance_corrections_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_balance_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_balance_corrections_process();

