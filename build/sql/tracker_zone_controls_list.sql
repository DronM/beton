-- VIEW: tracker_zone_controls_list

--DROP VIEW tracker_zone_controls_list;

CREATE OR REPLACE VIEW tracker_zone_controls_list AS
	SELECT
		t.*,
		destinations_ref(d) As destinations_ref
	FROM tracker_zone_controls AS t
	LEFT JOIN destinations As d ON d.id=t.destination_id
	ORDER BY d.name
	;
	
ALTER VIEW tracker_zone_controls_list OWNER TO ;
