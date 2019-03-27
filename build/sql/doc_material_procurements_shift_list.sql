-- VIEW: doc_material_procurements_shift_list

DROP VIEW doc_material_procurements_shift_list;

CREATE OR REPLACE VIEW doc_material_procurements_shift_list AS
	SELECT
		get_shift_start(proc.date_time) AS shift_date_time,
		get_shift_end(get_shift_start(proc.date_time)) AS shift_date_time_end,
		proc.material_id,
		ROUND(
			SUM(proc.quant_net),
		0) AS quant
	FROM doc_material_procurements AS proc
	GROUP BY get_shift_start(proc.date_time),proc.material_id
	ORDER BY get_shift_start(proc.date_time) DESC
	;
	
ALTER VIEW doc_material_procurements_shift_list OWNER TO ;
