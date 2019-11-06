-- Function: vehicle_owner_on_date(in_val JSONB,in_dt timestamp)

-- DROP FUNCTION vehicle_owner_on_date(in_val JSONB,in_dt timestamp);

CREATE OR REPLACE FUNCTION vehicle_owner_on_date(in_val JSONB,in_dt timestamp)
  RETURNS jsonb AS
$$
	SELECT 
		s.r->'fields'->'owner'
	FROM
	(SELECT jsonb_array_elements(in_val->'rows') As r) AS s
	WHERE (s.r->'fields'->>'dt_from')::timestamp with time zone<=in_dt
	ORDER BY (s.r->'fields'->>'dt_from')::timestamp with time zone DESC
	LIMIT 1;
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION vehicle_owner_on_date(in_val JSONB,in_dt timestamp) OWNER TO ;
