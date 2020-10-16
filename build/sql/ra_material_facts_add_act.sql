-- FUNCTION: public.ra_material_facts_add_act(ra_material_facts)

-- DROP FUNCTION public.ra_material_facts_add_act(ra_material_facts);

CREATE OR REPLACE FUNCTION public.ra_material_facts_add_act(
	reg_act ra_material_facts)
    RETURNS void
    LANGUAGE 'sql'

    COST 100
    VOLATILE STRICT 
AS $BODY$
INSERT INTO ra_material_facts
				(date_time,doc_type,doc_id
				,deb
				,material_id
				,production_site_id
				,quant				
				)
				VALUES (
				$1.date_time,$1.doc_type,$1.doc_id
				,$1.deb
				,$1.material_id
				,$1.production_site_id
				,$1.quant				
				);
$BODY$;

ALTER FUNCTION public.ra_material_facts_add_act(ra_material_facts)
    OWNER TO beton;

