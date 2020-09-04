-- Trigger: doc_material_procurements_before

-- DROP TRIGGER doc_material_procurements_before ON public.doc_material_procurements;

CREATE TRIGGER doc_material_procurements_before
    BEFORE INSERT OR DELETE OR UPDATE 
    ON public.doc_material_procurements
    FOR EACH ROW
    EXECUTE PROCEDURE public.doc_material_procurements_process();
    
-- Trigger: doc_material_procurements_after

--DROP TRIGGER doc_material_procurements_after ON public.doc_material_procurements;

CREATE TRIGGER doc_material_procurements_after
    AFTER INSERT OR DELETE OR UPDATE 
    ON public.doc_material_procurements
    FOR EACH ROW
    EXECUTE PROCEDURE public.doc_material_procurements_process();    

