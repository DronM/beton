
-- DROP TRIGGER const_weather_update_interval_sec_trigger_after ON public.const_weather_update_interval_sec;
CREATE TRIGGER const_weather_update_interval_sec_trigger_after AFTER UPDATE
  ON public.const_weather_update_interval_sec
  FOR EACH ROW
  EXECUTE PROCEDURE public.constants_process();

