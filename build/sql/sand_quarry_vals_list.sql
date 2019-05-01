-- View: sand_quarry_vals_list

-- DROP VIEW sand_quarry_vals_list;

CREATE OR REPLACE VIEW sand_quarry_vals_list AS 
	SELECT
		l.id,
		l.day,
		l.quarry_id,
		l.v_mkr,
		l.v_nasip,
		l.v_istin,
		l.v_humid,
		l.v_comment,
		l.v_void,
		l.v_dust,
		l.v_2_5,
		l.v_1_25,
		l.v_0_16,
		l.v_0_05,
		l.v_0_63,
		l.v_dno,
		l.v_0_315,
		l.v_0_63_2,
		q.name AS quarry_descr,
		date8_descr(l.day) AS day_descr
	FROM sand_quarry_vals l
	LEFT JOIN quarries q ON q.id = l.quarry_id
	ORDER BY l.day DESC;

ALTER TABLE sand_quarry_vals_list
  OWNER TO beton;

