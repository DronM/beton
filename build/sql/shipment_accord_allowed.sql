-- Function: shipment_accord_allowed(in_ship_date date)

-- DROP FUNCTION shipment_accord_allowed(in_ship_date date);

CREATE OR REPLACE FUNCTION shipment_accord_allowed(in_ship_date date)
  RETURNS table(
  	d_from date,
  	d_to date
  ) AS
$$
	WITH
			mon AS (
				SELECT
					CASE WHEN extract('month' FROM in_ship_date)=12 THEN 1
						ELSE extract('month' FROM in_ship_date)+1
					END AS v
			),
			accord_from_d AS (SELECT const_vehicle_owner_accord_from_day_val() v),
			accord_to_d AS (SELECT const_vehicle_owner_accord_to_day_val() v),
			year_mon AS (
				SELECT
					(CASE
						WHEN (SELECT v FROM mon)=12 THEN extract('year' FROM in_ship_date)+1
						ELSE extract('year' FROM in_ship_date)
					END)::text||
					'-'||
					(CASE
						WHEN (SELECT v FROM mon)<10 THEN '0'
						ELSE ''
					END)||
					(SELECT v FROM mon)::text ||'-'
					AS v				
			)
	SELECT
		(
		(SELECT v FROM year_mon)||
		(CASE WHEN (SELECT v FROM accord_from_d)<10 THEN '0' ELSE '0' END) || (SELECT v FROM accord_from_d)
		)::date AS d_from,
		(
		(SELECT v FROM year_mon)||
		(CASE WHEN (SELECT v FROM accord_to_d)<10 THEN '0' ELSE '0' END) || (SELECT v FROM accord_to_d)
		)::date AS d_to
	;	
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION shipment_accord_allowed(in_ship_date date) OWNER TO ;
