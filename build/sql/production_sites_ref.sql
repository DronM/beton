-- Function: public.production_sites_ref(destinations)

-- DROP FUNCTION public.production_sites_ref(production_sites);

CREATE OR REPLACE FUNCTION public.production_sites_ref(production_sites)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','production_sites'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.production_sites_ref(production_sites) OWNER TO beton;

