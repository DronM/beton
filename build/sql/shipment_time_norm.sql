-- Function: shipment_time_norm(numeric)

-- DROP FUNCTION shipment_time_norm(numeric);

CREATE OR REPLACE FUNCTION shipment_time_norm(numeric)
  RETURNS integer AS
$BODY$
	SELECT t.norm_min
	FROM shipment_time_norms AS t
	WHERE t.id=ROUND($1,0);
$BODY$
  LANGUAGE sql STABLE
  COST 100;
ALTER FUNCTION shipment_time_norm(numeric)
  OWNER TO beton;

