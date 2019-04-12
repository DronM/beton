-- Function: weather_update(in_cont text, in_cont_details text)

-- DROP FUNCTION weather_update(in_cont text, in_cont_details text);

CREATE OR REPLACE FUNCTION weather_update(in_cont text, in_cont_details text)
  RETURNS timestamp AS
$$
BEGIN
    UPDATE weather SET content=in_cont,content_details=in_cont_details,update_dt=now()::timestamp;
    IF FOUND THEN
        RETURN now()::timestamp;
    END IF;
    BEGIN
        INSERT INTO weather (content,content_details,update_dt)
        VALUES (in_cont,in_cont_details,now()::timestamp);
    EXCEPTION WHEN OTHERS THEN
        UPDATE weather SET content=in_cont,content_details=in_cont_details,update_dt=now()::timestamp;
    END;
    
    RETURN now()::timestamp;
END;
$$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION weather_update(in_cont text, in_cont_details text) OWNER TO ;
