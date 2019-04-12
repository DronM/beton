-- Function: plant_load_charts_update(date, integer,text)

-- DROP FUNCTION plant_load_charts_update(date, integer,text);

CREATE OR REPLACE FUNCTION plant_load_charts_update(
    in_date date,
    in_state integer,
    in_chart_data text
)
  RETURNS void AS
$BODY$
BEGIN
	UPDATE plant_load_charts SET state=in_state,chart_data=in_chart_data WHERE id=in_date;

	IF FOUND THEN
		RETURN;
	END IF;
	
	BEGIN
		INSERT INTO plant_load_charts(id, state,chart_data) VALUES (in_date, in_state,in_chart_data);
	EXCEPTION WHEN OTHERS THEN
		UPDATE plant_load_charts SET state=in_state,chart_data=in_chart_data WHERE id=in_date;
	END;
	
	RETURN;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION plant_load_charts_update(date, integer,text)
  OWNER TO beton;

