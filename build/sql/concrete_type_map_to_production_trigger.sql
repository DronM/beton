-- Trigger: concrete_type_map_to_production_trigger_after on public.concrete_type_map_to_production

-- DROP TRIGGER concrete_type_map_to_production_trigger_after ON public.concrete_type_map_to_production;

CREATE TRIGGER concrete_type_map_to_production_trigger_after
  AFTER INSERT OR UPDATE OR DELETE
  ON public.concrete_type_map_to_production
  FOR EACH ROW
  EXECUTE PROCEDURE public.concrete_type_map_to_production_process();

