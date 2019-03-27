-- Function: raw_material_procurement_dates(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION raw_material_procurement_dates(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION raw_material_procurement_dates(
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
	dyn_cols_tot = '';
	dyn_col_cnt = 0;
	FOR materials IN 
		SELECT id FROM raw_materials WHERE name <>'' ORDER BY id	
	LOOP
		dyn_col_cnt = dyn_col_cnt + 1;
		dyn_cols = dyn_cols||', ';
		dyn_cols = dyn_cols
		|| '(SELECT SUM(quant) FROM proc WHERE proc.date_time=proc_d.date_time AND proc.material_id='|| materials.id ||'::int) AS mat'|| dyn_col_cnt ||'_quant';

		dyn_cols_tot = dyn_cols_tot ||',' || '(SELECT SUM(quant) FROM proc WHERE proc.material_id='|| materials.id ||'::int) AS mat'|| dyn_col_cnt ||'_quant';
	END LOOP;	

	RETURN QUERY EXECUTE 
		'WITH proc AS (
			SELECT
				get_shift_start(date_time) AS date_time,
				material_id,
				ROUND(SUM(quant_net),0) AS quant
			FROM doc_material_procurements
			WHERE date_time BETWEEN '''|| in_date_time_from ||'''::timestamp AND '''|| in_date_time_to ||'''::timestamp
			GROUP BY date_time,material_id
			ORDER BY date_time
			)
		(SELECT proc_d.date_time AS shift,
			get_shift_descr(proc_d.date_time)::text AS shift_descr,
			date10_time8_descr(proc_d.date_time)::text AS shift_from_descr,
			date10_time8_descr(get_shift_end(proc_d.date_time))::text AS shift_to_descr
		'|| dyn_cols ||'
		FROM proc AS proc_d
		GROUP BY proc_d.date_time
		ORDER BY proc_d.date_time)

		UNION ALL

		SELECT
			null AS shift,
			''Итого'' AS shift_descr,
			'''' AS shift_from_descr,
			'''' AS shift_to_descr
			'|| dyn_cols_tot ||'
		
		';	
	--RAISE '%',q;
	--RETURN QUERY EXECUTE q;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION raw_material_procurement_dates(timestamp without time zone, timestamp without time zone)
  OWNER TO beton;

