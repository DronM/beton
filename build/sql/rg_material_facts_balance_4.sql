-- FUNCTION: public.rg_material_facts_balance(doc_types, integer, integer[], integer[])

-- DROP FUNCTION public.rg_material_facts_balance(doc_types, integer, integer[], integer[]);

CREATE OR REPLACE FUNCTION public.rg_material_facts_balance(
	in_doc_type doc_types,
	in_doc_id integer,
	in_production_site_id_ar integer[],
	in_material_id_ar integer[])
    RETURNS TABLE(production_site_id integer, material_id integer, quant numeric) 
    LANGUAGE 'sql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$
SELECT * FROM rg_material_facts_balance(
		(SELECT doc_log.date_time FROM doc_log WHERE doc_log.doc_type=in_doc_type AND doc_log.doc_id=in_doc_id),
		in_production_site_id_ar,
		in_material_id_ar
		);
$BODY$;

ALTER FUNCTION public.rg_material_facts_balance(doc_types, integer, integer[], integer[])
    OWNER TO beton;

