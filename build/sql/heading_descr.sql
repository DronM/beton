-- FUNCTION: public.heading_descr(numeric)

-- DROP FUNCTION public.heading_descr(numeric);

CREATE OR REPLACE FUNCTION public.heading_descr(
	numeric)
    RETURNS text
    LANGUAGE 'sql'

    COST 100
    IMMUTABLE 
AS $BODY$
SELECT 
		CASE 
			WHEN $1 >340 OR $1 <20 THEN 'север'
			WHEN $1 >20 AND $1 <110 THEN 'северо-запад'
			WHEN $1 >=110 AND $1 <160 THEN 'юго-запад'
			WHEN $1 >=160 AND $1 <200 THEN 'юг'
			WHEN $1 >=200 AND $1 <250 THEN 'юго-восток'
			WHEN $1 >=250 AND $1 <340 THEN 'северо-восток'
		END;
$BODY$;

ALTER FUNCTION public.heading_descr(numeric) OWNER TO ;

