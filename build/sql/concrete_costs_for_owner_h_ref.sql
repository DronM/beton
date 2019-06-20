-- Function: public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h)

-- DROP FUNCTION public.concrete_costs_for_owner_h(concrete_costs_for_owner_h);

CREATE OR REPLACE FUNCTION public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',$1.comment_text||' ('||to_char($1.create_date,'DD/MM/YY')||')',
		'dataType','concrete_costs_for_owner_h'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.concrete_costs_for_owner_h_ref(concrete_costs_for_owner_h) OWNER TO beton;
