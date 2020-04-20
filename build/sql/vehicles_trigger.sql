-- Trigger: vehicles_before_trigger on vehicles

-- DROP TRIGGER vehicles_before_trigger ON vehicles;

 CREATE TRIGGER vehicles_before_trigger
  BEFORE INSERT OR UPDATE
  ON vehicles
  FOR EACH ROW
  EXECUTE PROCEDURE vehicles_process();
  
