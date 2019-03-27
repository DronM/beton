-- Function: public.suppliers_ref(suppliers)

-- DROP FUNCTION public.suppliers_ref(suppliers);

CREATE OR REPLACE FUNCTION public.suppliers_ref(suppliers)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','suppliers'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.suppliers_ref(suppliers) OWNER TO beton;

