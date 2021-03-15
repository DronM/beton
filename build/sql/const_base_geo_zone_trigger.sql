-- Trigger: const_base_geo_zone_trigger_after on public.const_base_geo_zone

-- DROP TRIGGER const_base_geo_zone_trigger_after ON public.const_base_geo_zone;


CREATE TRIGGER const_base_geo_zone_trigger_after
  AFTER UPDATE
  ON public.const_base_geo_zone
  FOR EACH ROW
  EXECUTE PROCEDURE public.const_base_geo_zone_process();

