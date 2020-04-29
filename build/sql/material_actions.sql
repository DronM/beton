-- Function: material_actions(in_date_time_from timestamp without time zone,in_date_time_to timestamp without time zone)

-- DROP FUNCTION material_actions(in_date_time_from timestamp without time zone,in_date_time_to timestamp without time zone);

CREATE OR REPLACE FUNCTION material_actions(in_date_time_from timestamp without time zone,in_date_time_to timestamp without time zone)
  RETURNS TABLE(
  	is_cement bool,
  	material_name text,
  	quant_start numeric(19,4),
  	quant_deb numeric(19,4),
  	quant_kred numeric(19,4),
  	quant_end numeric(19,4)
  
  ) AS
$$
	(
	SELECT
		TRUE AS is_cement,
		sil.name::text AS material_name,
		coalesce(bal_start.quant,0) AS quant_start,	
		coalesce(ra_deb.quant,0) AS quant_deb,
		coalesce(ra_kred.quant,0) AS quant_kred,
		coalesce(bal_start.quant,0)+coalesce(ra_deb.quant,0)-coalesce(ra_kred.quant,0) AS quant_end
	FROM cement_silos AS sil
	LEFT JOIN (SELECT * FROM rg_cement_balance(in_date_time_from,'{}')) AS bal_start ON bal_start.cement_silos_id=sil.id
	LEFT JOIN (
		SELECT
			cement_silos_id,
			sum(quant) AS quant
		FROM ra_cement
		WHERE date_time BETWEEN in_date_time_from AND in_date_time_to AND deb
		GROUP BY cement_silos_id
	) AS ra_deb ON ra_deb.cement_silos_id = sil.id 
	LEFT JOIN (
		SELECT
			cement_silos_id,
			sum(quant) AS quant
		FROM ra_cement
		WHERE date_time BETWEEN in_date_time_from AND in_date_time_to AND NOT deb
		GROUP BY cement_silos_id
	) AS ra_kred ON ra_kred.cement_silos_id = sil.id 
	ORDER BY sil.name
	)
	UNION ALL
	(
	SELECT
		FALSE AS is_cement,
		m.name,
		coalesce(bal_start.quant,0) AS quant_start,
		coalesce(ra_deb.quant,0) AS quant_deb,
		coalesce(ra_kred.quant,0) AS quant_kred,
		coalesce(bal_start.quant,0)+coalesce(ra_deb.quant,0)-coalesce(ra_kred.quant,0) AS quant_end
	
	FROM raw_materials AS m
	LEFT JOIN (SELECT * FROM rg_material_facts_balance(in_date_time_from,'{}')) AS bal_start ON bal_start.material_id=m.id
	LEFT JOIN (
		SELECT
			material_id,
			sum(quant) AS quant
		FROM ra_material_facts
		WHERE date_time BETWEEN in_date_time_from AND in_date_time_to AND deb
		GROUP BY material_id
	) AS ra_deb ON ra_deb.material_id = m.id 
	LEFT JOIN (
		SELECT
			material_id,
			sum(quant) AS quant
		FROM ra_material_facts
		WHERE date_time BETWEEN in_date_time_from AND in_date_time_to AND NOT deb
		GROUP BY material_id
	) AS ra_kred ON ra_kred.material_id = m.id 
	WHERE concrete_part AND NOT is_cement
	ORDER BY ord
	)
	;
$$
  LANGUAGE sql VOLATILE
  COST 100;
ALTER FUNCTION material_actions(in_date_time_from timestamp without time zone,in_date_time_to timestamp without time zone) OWNER TO ;
