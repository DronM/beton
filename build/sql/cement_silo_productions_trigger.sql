-- Trigger: cement_silo_productions_trigger on cement_silo_productions

-- DROP TRIGGER cement_silo_productions_before_trigger ON cement_silo_productions;

CREATE TRIGGER cement_silo_productions_before_trigger
  BEFORE INSERT
  ON cement_silo_productions
  FOR EACH ROW
  EXECUTE PROCEDURE cement_silo_productions_process();

