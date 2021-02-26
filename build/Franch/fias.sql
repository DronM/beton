CREATE OR REPLACE FUNCTION fias.find_address(
	in_search text,
	in_count integer)
    RETURNS TABLE(search_name text, addr_strucs json, house_struc json) 
    LANGUAGE 'plpgsql'

    COST 100
    VOLATILE 
    ROWS 1000
AS $BODY$
DECLARE
	v_data_row RECORD;
	v_count smallint;
BEGIN
	v_count = 0;
	FOR v_data_row IN
	SELECT t.* FROM fias.address_search AS t WHERE t.search_name ilike in_search LIMIT in_count
	LOOP
		search_name = v_data_row.search_name;
		addr_strucs = v_data_row.addr_strucs;
		house_struc = v_data_row.house_struc;
		
		v_count = v_count + 1;
		
		RETURN NEXT;
	END LOOP;
	
	IF v_count<in_count THEN
		--houses
		FOR v_data_row IN
		SELECT t.* FROM fias.house_search AS t WHERE t.search_name ilike in_search LIMIT (in_count-v_count)
		LOOP
			search_name = v_data_row.search_name;
			addr_strucs = v_data_row.addr_strucs;
			house_struc = v_data_row.house_struc;
		
			v_count = v_count + 1;
				
			RETURN NEXT;
		END LOOP;
		
	END IF;	
	
END;
$BODY$;

ALTER FUNCTION fias.find_address(text, integer)
    OWNER TO concrete1;

GRANT EXECUTE ON FUNCTION fias.find_address(text, integer) TO concrete1;

