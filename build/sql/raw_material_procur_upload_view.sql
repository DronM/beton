-- View: public.raw_material_procur_upload_view

-- DROP VIEW public.raw_material_procur_upload_view;

CREATE OR REPLACE VIEW public.raw_material_procur_upload_view AS 
 SELECT
 	raw_material_procur_uploads.date_time,
	date8_time5_descr(raw_material_procur_uploads.date_time) AS date_time_descr,
	raw_material_procur_uploads.result,
	raw_material_procur_uploads.doc_count,
	raw_material_procur_uploads.descr
FROM raw_material_procur_uploads;

ALTER TABLE public.raw_material_procur_upload_view OWNER TO beton;

