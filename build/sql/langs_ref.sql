-- Function: public.langs_ref(langs)

-- DROP FUNCTION public.langs_ref(langs);

CREATE OR REPLACE FUNCTION public.langs_ref(langs)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.name,
		'dataType','langs'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.langs_ref(langs) OWNER TO beton;

