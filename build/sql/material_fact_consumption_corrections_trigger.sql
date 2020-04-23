-- Trigger: material_fact_consumption_corrections_trigger_before on public.material_fact_consumption_corrections

-- DROP TRIGGER material_fact_consumption_corrections_trigger_before ON public.material_fact_consumption_corrections;


CREATE TRIGGER material_fact_consumption_corrections_trigger_before
  BEFORE UPDATE OR DELETE
  ON public.material_fact_consumption_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumption_corrections_process();

/*
-- DROP TRIGGER material_fact_consumption_corrections_trigger_after ON public.material_fact_consumption_corrections;

CREATE TRIGGER material_fact_consumption_corrections_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_consumption_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumption_corrections_process();
*/
