-- Function: pump_vehicle_price_on_date(in_val JSONB,in_dt timestamp)

-- DROP FUNCTION pump_vehicle_price_on_date(in_val JSONB,in_dt timestamp);

CREATE OR REPLACE FUNCTION pump_vehicle_price_on_date(in_val JSONB,in_dt timestamp)
  RETURNS jsonb AS
$$
	SELECT 
		s.r->'fields'->'pump_price'
	FROM
	(SELECT jsonb_array_elements(in_val->'rows') As r) AS s
	WHERE (s.r->'fields'->>'dt_from')::timestamp with time zone<=in_dt
	ORDER BY (s.r->'fields'->>'dt_from')::timestamp with time zone DESC
	LIMIT 1;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION pump_vehicle_price_on_date(in_val JSONB,in_dt timestamp) OWNER TO ;
