-- Trigger: material_fact_consumptions_trigger_before on public.material_fact_consumptions

DROP TRIGGER material_fact_consumptions_trigger_before ON public.material_fact_consumptions;

CREATE TRIGGER material_fact_consumptions_trigger_before
  BEFORE INSERT OR UPDATE OR DELETE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();


-- Trigger: material_fact_consumptions_trigger_after on public.material_fact_consumptions

-- DROP TRIGGER material_fact_consumptions_trigger_after ON public.material_fact_consumptions;
/*
CREATE TRIGGER material_fact_consumptions_trigger_after
  AFTER INSERT OR UPDATE
  ON public.material_fact_consumptions
  FOR EACH ROW
  EXECUTE PROCEDURE public.material_fact_consumptions_process();
*/
