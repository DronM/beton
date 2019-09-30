-- Trigger: vehicle_map_to_production_trigger_after on public.vehicle_map_to_production

-- DROP TRIGGER vehicle_map_to_production_trigger_after ON public.vehicle_map_to_production;

CREATE TRIGGER vehicle_map_to_production_trigger_after
  AFTER INSERT OR UPDATE OR DELETE
  ON public.vehicle_map_to_production
  FOR EACH ROW
  EXECUTE PROCEDURE public.vehicle_map_to_production_process();

