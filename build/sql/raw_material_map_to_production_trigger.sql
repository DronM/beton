-- Trigger: raw_material_map_to_production_trigger_after on public.raw_material_map_to_production

-- DROP TRIGGER raw_material_map_to_production_trigger_after ON public.raw_material_map_to_production;

CREATE TRIGGER raw_material_map_to_production_trigger_after
  AFTER INSERT OR UPDATE OR DELETE
  ON public.raw_material_map_to_production
  FOR EACH ROW
  EXECUTE PROCEDURE public.raw_material_map_to_production_process();

