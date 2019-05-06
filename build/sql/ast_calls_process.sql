-- Function: ast_calls_process()

-- DROP FUNCTION ast_calls_process();

CREATE OR REPLACE FUNCTION ast_calls_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_search text;
BEGIN
	IF (TG_OP='INSERT') THEN
		NEW.dt = now()::timestamp;
		
		--********* Client ********************
		IF NEW.call_type='in'::call_types THEN			
			IF substring(NEW.caller_id_num from 1 for 2)='+7' THEN
				NEW.caller_id_num = substring(NEW.caller_id_num from 3);
			END IF;
			v_search = NEW.caller_id_num;
		ELSE
			v_search = NEW.ext;
			IF (char_length(v_search)>3 AND char_length(v_search)<10) THEN
				v_search = const_city_ext_val()::text||v_search;
			END IF;
			
		END IF;

		IF (char_length(v_search)>3) THEN
			v_search = format_cel_phone(RIGHT(v_search,10));
				
			NEW.client_id = (
				SELECT
					client_tels.client_id
				FROM client_tels
				LEFT JOIN ast_calls ON ast_calls.client_id=client_tels.client_id
				WHERE client_tels.tel=v_search
				ORDER BY ast_calls.dt DESC NULLS LAST
				LIMIT 1			
			);
			NEW.client_tel = v_search;
		END IF;
		--********* Client ********************
		
	ELSIF (TG_OP='UPDATE') THEN
		--****** User ****************
		IF NEW.call_type='in'::call_types THEN
			IF substring(NEW.caller_id_num from 1 for 2)='+7' THEN
				NEW.caller_id_num = substring(NEW.caller_id_num from 3);
			END IF;
		
			IF NEW.client_id IS NULL AND OLD.client_id IS NULL THEN
				v_search = NEW.caller_id_num;
				
				IF (char_length(v_search)>3) THEN
					v_search = format_cel_phone(RIGHT(v_search,10));
				
					NEW.client_id = (
						SELECT
							client_tels.client_id
						FROM client_tels
						LEFT JOIN ast_calls ON ast_calls.client_id=client_tels.client_id
						WHERE client_tels.tel=v_search
						ORDER BY ast_calls.dt DESC NULLS LAST
						LIMIT 1			
					);
				END IF;
			END IF;
		
			v_search = NEW.ext;
		ELSE		
			v_search = NEW.caller_id_num;
		END IF;

		NEW.user_id = (SELECT id
				FROM users
			WHERE tel_ext=v_search
			LIMIT 1
		);
		
		
		--************ USER TO ***************
		/*
		IF NEW.call_type='out'::call_types
		AND char_length(NEW.ext)<=3 THEN
			--Внутренний номер
			NEW.user_id_to = (SELECT id
					FROM users
				WHERE tel_ext=NEW.ext
			);
			
		END IF;
		*/
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION ast_calls_process()
  OWNER TO beton;

