-- FUNCTION: public.rg_material_facts_balance(integer[])

-- DROP FUNCTION public.rg_material_facts_balance(integer[]);

CREATE OR REPLACE FUNCTION public.rg_material_facts_balance(
	in_production_site_id_ar integer[],in_material_id_ar integer[])
    RETURNS TABLE(production_site_id integer, material_id integer, quant numeric) 
    LANGUAGE 'sql'
CALLED ON NULL INPUT
    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$
SELECT
		b.production_site_id
		,b.material_id
		,b.quant AS quant				
	FROM rg_material_facts AS b
	WHERE b.date_time=reg_current_balance_time()
		AND (in_production_site_id_ar IS NULL OR ARRAY_LENGTH(in_production_site_id_ar,1) IS NULL OR (b.production_site_id=ANY(in_production_site_id_ar)))
		AND (in_material_id_ar IS NULL OR ARRAY_LENGTH(in_material_id_ar,1) IS NULL OR (b.material_id=ANY(in_material_id_ar)))
		AND(
		b.quant<>0
		)
	ORDER BY
		b.material_id;
$BODY$;

ALTER FUNCTION public.rg_material_facts_balance(integer[],integer[])
    OWNER TO beton;

