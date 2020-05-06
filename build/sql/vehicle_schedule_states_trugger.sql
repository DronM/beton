-- Trigger: vehicle_schedule_states_before_trigger on public.vehicle_schedule_states

-- DROP TRIGGER vehicle_schedule_states_before_trigger ON public.vehicle_schedule_states;

CREATE TRIGGER vehicle_schedule_states_before_trigger
  BEFORE INSERT OR DELETE
  ON public.vehicle_schedule_states
  FOR EACH ROW
  EXECUTE PROCEDURE public.vehicle_schedule_states_process();


