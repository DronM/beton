-- Trigger: concrete_costs_h_after_trigger on concrete_costs_h

-- DROP TRIGGER concrete_costs_h_after_trigger ON concrete_costs_h;
/*
 CREATE TRIGGER concrete_costs_h_after_trigger
  AFTER INSERT
  ON concrete_costs_h
  FOR EACH ROW
  EXECUTE PROCEDURE concrete_costs_h_process();
*/  
  
-- Trigger: concrete_costs_h_before_trigger on concrete_costs_h

-- DROP TRIGGER concrete_costs_h_before_trigger ON concrete_costs_h;

 CREATE TRIGGER concrete_costs_h_before_trigger
  BEFORE INSERT OR UPDATE
  ON concrete_costs_h
  FOR EACH ROW
  EXECUTE PROCEDURE concrete_costs_h_process();
    
