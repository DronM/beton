-- View: stone_quarry_vals_list

-- DROP VIEW stone_quarry_vals_list;

CREATE OR REPLACE VIEW stone_quarry_vals_list AS 
	SELECT
		l.id,
		l.day,
		l.quarry_id,
		l.v_nasip,
		l.v_istin,
		l.v_dust,
		l.v_humid,
		l.v_comment,
		l.v_void,
		q.name AS quarry_descr,
		date8_descr(l.day) AS day_descr
	FROM stone_quarry_vals l
	LEFT JOIN quarries q ON q.id = l.quarry_id
	ORDER BY l.day DESC;

ALTER TABLE stone_quarry_vals_list
  OWNER TO beton;

