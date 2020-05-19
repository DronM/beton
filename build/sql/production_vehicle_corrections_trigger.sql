-- Trigger: production_vehicle_corrections_trigger on productions

-- DROP TRIGGER production_vehicle_corrections_after_trigger ON production_vehicle_corrections;

CREATE TRIGGER production_vehicle_corrections_after_trigger
  AFTER INSERT OR UPDATE OR DELETE
  ON production_vehicle_corrections
  FOR EACH ROW
  EXECUTE PROCEDURE production_vehicle_corrections_process();

