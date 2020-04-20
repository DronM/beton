-- Trigger: productions_trigger on productions

 DROP TRIGGER productions_before_trigger ON productions;

CREATE TRIGGER productions_before_trigger
  BEFORE INSERT OR UPDATE OR DELETE
  ON productions
  FOR EACH ROW
  EXECUTE PROCEDURE productions_process();

