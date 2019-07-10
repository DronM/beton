-- Function: shipments_quant_for_cost(in_quant numeric,in_distance numeric)

-- DROP FUNCTION shipments_quant_for_cost(in_quant numeric,in_distance numeric);

CREATE OR REPLACE FUNCTION shipments_quant_for_cost(in_quant numeric,in_distance numeric)
  RETURNS numeric AS
$$
	SELECT
		CASE
			WHEN in_quant>=7 THEN in_quant
			WHEN in_distance<=60 THEN greatest(5,in_quant)
			ELSE 7
		END
	;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION shipments_quant_for_cost(in_quant numeric,in_distance numeric) OWNER TO ;
