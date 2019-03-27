-- Function: ra_material_consumption_dates_list(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION ra_material_consumption_dates_list(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION ra_material_consumption_dates_list(
    in_date_time_from timestamp without time zone,
    in_date_time_to timestamp without time zone)
  RETURNS SETOF record AS
$BODY$
DECLARE
	materials raw_materials%rowtype;
	dyn_cols text;
	dyn_cols_tot text;
	q text;
	dyn_col_cnt int;
BEGIN
	dyn_cols = '';
	dyn_cols_tot='';
	dyn_col_cnt = 0;
	FOR materials IN 
		SELECT id FROM raw_materials WHERE name<>'' ORDER BY id	
	LOOP
		dyn_col_cnt = dyn_col_cnt + 1;
		dyn_cols = dyn_cols||', ';
		dyn_cols = dyn_cols
		|| '(SELECT SUM(consump.material_quant) FROM consump WHERE consump.date_time=consump_d.date_time AND consump.material_id='|| materials.id ||'::int) AS mat'|| dyn_col_cnt ||'_quant';
		dyn_cols_tot = dyn_cols_tot||','|| '(SELECT SUM(consump.material_quant) FROM consump WHERE consump.material_id='|| materials.id ||'::int) AS mat'|| dyn_col_cnt ||'_quant';
	END LOOP;	

	RETURN QUERY EXECUTE 
	--q=
		'WITH consump AS (
			SELECT
				get_shift_start(date_time) AS date_time,
				material_id,
				ROUND(SUM(concrete_quant),2) AS concrete_quant,
				ROUND(SUM(material_quant),3) AS material_quant
			FROM ra_material_consumption
			WHERE date_time BETWEEN '''|| in_date_time_from ||'''::timestamp AND '''|| in_date_time_to ||'''::timestamp
			GROUP BY get_shift_start(date_time),material_id
			ORDER BY date_time)
		(SELECT
			consump_d.date_time AS shift,
			get_shift_descr(consump_d.date_time)::text AS shift_descr,
			date10_time8_descr(consump_d.date_time)::text AS shift_from_descr,
			date10_time8_descr(get_shift_end(consump_d.date_time))::text AS shift_to_descr,
			(SELECT SUM(concrete_quant) FROM consump WHERE consump.date_time=consump_d.date_time) AS concrete_quant
		'|| dyn_cols ||'
		FROM consump AS consump_d
		GROUP BY shift
		ORDER BY shift)

		';	
	--RAISE '%',q;
	--RETURN QUERY EXECUTE q;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION ra_material_consumption_dates_list(timestamp without time zone, timestamp without time zone)
  OWNER TO beton;

