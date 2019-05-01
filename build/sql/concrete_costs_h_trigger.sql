-- Trigger: concrete_costs_h_after_trigger on concrete_costs_h

-- DROP TRIGGER concrete_costs_h_after_trigger ON concrete_costs_h;

 CREATE TRIGGER concrete_costs_h_after_trigger
  AFTER INSERT
  ON concrete_costs_h
  FOR EACH ROW
  EXECUTE PROCEDURE concrete_costs_h_process();
  
