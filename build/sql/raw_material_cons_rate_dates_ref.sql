-- Function: public.raw_material_cons_rate_dates_ref(raw_material_cons_rate_dates)

-- DROP FUNCTION public.raw_material_cons_rate_dates_ref(raw_material_cons_rate_dates);

CREATE OR REPLACE FUNCTION public.raw_material_cons_rate_dates_ref(raw_material_cons_rate_dates)
  RETURNS json AS
$BODY$
	SELECT json_build_object(
		'keys',json_build_object(
			'id',$1.id    
			),	
		'descr',
			CASE
				WHEN length(coalesce($1.code::text,''))>0 THEN
					'№ ' || coalesce($1.code::text,'') || ' '
				ELSE ''
			END
			|| 'от '||to_char($1.dt::date,'DD/MM/YY'),
		'dataType','raw_material_cons_rate_dates'
	);
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION public.raw_material_cons_rate_dates_ref(raw_material_cons_rate_dates) OWNER TO beton;

