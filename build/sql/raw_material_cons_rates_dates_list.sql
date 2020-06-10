-- View: raw_material_cons_rates_dates_list

-- DROP VIEW raw_material_cons_rates_dates_list;

CREATE OR REPLACE VIEW raw_material_cons_rates_dates_list AS 
	SELECT
		d_from.id,
		d_from.dt,
		date8_descr(d_from.dt) AS dt_descr,
		(date8_descr(d_from.dt)::text || ' - '::text) || COALESCE(
			( SELECT date8_descr((d_to.dt - '1 day'::interval)::date)::text AS date
			FROM raw_material_cons_rate_dates d_to
			WHERE d_to.dt > d_from.dt
			ORDER BY d_to.dt
			LIMIT 1
			),
			CASE
				WHEN now()::date < d_from.dt THEN '---'::text
				ELSE date8_descr(now()::date)::text
			END
		) AS period,
		d_from.name
		
	FROM raw_material_cons_rate_dates d_from
	ORDER BY d_from.dt DESC;

ALTER TABLE raw_material_cons_rates_dates_list
  OWNER TO beton;

