-- Function: public.cement_silos_ref(cement_silos)

-- DROP FUNCTION public.cement_silos_ref(cement_silos);

CREATE OR REPLACE FUNCTION public.cement_silos_ref(cement_silos)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','cement_silos'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.cement_silos_ref(cement_silos)
  OWNER TO beton;

