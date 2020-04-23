-- Function: public.rg_cement_balance(timestamp without time zone, integer[])

-- DROP FUNCTION public.rg_cement_balance(timestamp without time zone, integer[]);

CREATE OR REPLACE FUNCTION public.rg_cement_balance(
    IN in_date_time timestamp without time zone,
    IN in_cement_silos_id_ar integer[])
  RETURNS TABLE(cement_silos_id integer, quant numeric) AS
$BODY$
DECLARE
	v_cur_per timestamp;
	v_act_direct boolean;
	v_act_direct_sgn int;
	v_calc_interval interval;
BEGIN
	v_cur_per = rg_period('cement'::reg_types, in_date_time);
	v_calc_interval = rg_calc_interval('cement'::reg_types);
	v_act_direct = TRUE;--( (rg_calc_period_end('cement'::reg_types,v_cur_per)-in_date_time)>(in_date_time - v_cur_per) );
	v_act_direct_sgn = 1;
	/*
	IF v_act_direct THEN
		v_act_direct_sgn = 1;
	ELSE
		v_act_direct_sgn = -1;
	END IF;
	*/
	--RAISE 'v_act_direct=%, v_cur_per=%, v_calc_interval=%',v_act_direct,v_cur_per,v_calc_interval;
	RETURN QUERY 
	SELECT 
	
	sub.cement_silos_id
	,SUM(sub.quant) AS quant				
	FROM(
		SELECT
		
		b.cement_silos_id
		,b.quant				
		FROM rg_cement AS b
		WHERE (v_act_direct AND b.date_time = (v_cur_per-v_calc_interval)) OR (NOT v_act_direct AND b.date_time = v_cur_per)
		
		AND (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (b.cement_silos_id=ANY(in_cement_silos_id_ar)))
		
		AND (
		b.quant<>0
		)
		
		UNION ALL
		
		(SELECT
		
		act.cement_silos_id
		,CASE act.deb
			WHEN TRUE THEN act.quant*v_act_direct_sgn
			ELSE -act.quant*v_act_direct_sgn
		END AS quant
										
		FROM ra_cement AS act
		WHERE (v_act_direct AND (act.date_time>=v_cur_per AND act.date_time<in_date_time) )
		
		AND (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (act.cement_silos_id=ANY(in_cement_silos_id_ar)))
		
		AND (
		
		act.quant<>0
		)
		--ORDER BY act.date_time,act.id
		)


	) AS sub
	WHERE (ARRAY_LENGTH(in_cement_silos_id_ar,1) IS NULL OR (sub.cement_silos_id=ANY(in_cement_silos_id_ar)))
	
	GROUP BY
		
		sub.cement_silos_id
	HAVING
		
		SUM(sub.quant)<>0
						
	ORDER BY
		
		sub.cement_silos_id;
END;			
$BODY$
  LANGUAGE plpgsql VOLATILE STRICT
  COST 100
  ROWS 1000;
ALTER FUNCTION public.rg_cement_balance(timestamp without time zone, integer[])
  OWNER TO beton;

