-- Function: ra_material_consumption_doc_materials_list(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION ra_material_consumption_doc_materials_list(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION ra_material_consumption_doc_materials_list(
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
		|| '(SELECT SUM(consump.material_quant) FROM consump WHERE consump.doc_type=consump_docs.doc_type AND consump.doc_id=consump_docs.doc_id AND consump.material_id='|| materials.id ||'::int) AS mat'|| dyn_col_cnt ||'_quant';

		dyn_cols_tot=dyn_cols_tot || ',' || '(SELECT SUM(material_quant) FROM consump WHERE material_id='|| materials.id ||'::int)';
	END LOOP;	
	
	--RETURN QUERY EXECUTE 
	q=
		'WITH consump AS (
			SELECT
				ra.doc_type,
				ra.doc_id,			
				ra.date_time AS date_time,
				ra.material_id,				
				ra.concrete_type_id,
				concr.name::text AS concrete_type_descr,
				ra.vehicle_id AS vehicle_id,
				vh.plate::text AS vehicle_descr,
				ra.driver_id AS driver_id,
				dr.name::text AS driver_descr,
				
				ROUND(SUM(ra.concrete_quant),2) AS concrete_quant,
				ROUND(SUM(ra.material_quant),3) AS material_quant
				
			FROM ra_material_consumption AS ra
			LEFT JOIN concrete_types AS concr ON concr.id=ra.concrete_type_id
			LEFT JOIN vehicles AS vh ON vh.id=ra.vehicle_id
			LEFT JOIN drivers AS dr ON dr.id=ra.driver_id
			WHERE ra.date_time BETWEEN '''|| in_date_time_from ||'''::timestamp AND '''|| in_date_time_to ||'''::timestamp
			GROUP BY ra.doc_type,ra.doc_id,ra.date_time,ra.material_id,ra.concrete_type_id,concrete_type_descr,ra.vehicle_id,vehicle_descr,ra.driver_id,driver_descr
			ORDER BY date_time
			)
			
		(SELECT
			consump_docs.date_time AS date_time,
			date10_time8_descr(consump_docs.date_time)::text AS date_time_descr,
			consump_docs.concrete_type_id,
			consump_docs.concrete_type_descr,
			consump_docs.vehicle_id,
			consump_docs.vehicle_descr,
			consump_docs.driver_id,
			consump_docs.driver_descr,
			(SELECT SUM(consump.concrete_quant) FROM consump WHERE consump.date_time=consump_docs.date_time) AS concrete_quant
		'|| dyn_cols ||'
		FROM consump AS consump_docs
		GROUP BY consump_docs.doc_type,consump_docs.doc_id,date_time,date_time_descr,concrete_type_id,concrete_type_descr,vehicle_id,vehicle_descr,driver_id,driver_descr
		ORDER BY consump_docs.date_time)
		
		UNION ALL
		
		(SELECT
			null AS date_time,
			''Итого''::text AS date_time_descr,
			null As concrete_type_id,
			null AS concrete_type_descr,
			null AS vehicle_id,
			null vehicle_descr,
			null AS driver_id,
			null As driver_descr,
			(SELECT SUM(concrete_quant) FROM consump) AS concrete_quant
			'|| dyn_cols_tot ||'
		)
		';	
	--RAISE '%',q;
	RETURN QUERY EXECUTE q;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION ra_material_consumption_doc_materials_list(timestamp without time zone, timestamp without time zone)
  OWNER TO beton;

