-- Trigger: production_sites_trigger on production_sites

-- DROP TRIGGER production_sites_before_trigger ON production_sites;

CREATE TRIGGER production_sites_before_trigger
  BEFORE UPDATE
  ON production_sites
  FOR EACH ROW
  EXECUTE PROCEDURE production_sites_process();

