-- Function: ast_calls_process()

-- DROP FUNCTION ast_calls_process();

CREATE OR REPLACE FUNCTION ast_calls_process()
  RETURNS trigger AS
$BODY$
DECLARE
	v_search text;
	v_client_repres_name text;
	v_client_repres_post text;
	v_client_name text;
	v_tel_formatted text;
	v_event_id text;
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
			--!!! v_search = format_cel_phone(RIGHT(v_search,10));
				
			v_tel_formatted = format_cel_phone(RIGHT(v_search,10));
			SELECT
				client_tels.client_id,
				client_tels.name,
				client_tels.post,
				cl.name_full
			INTO
				NEW.client_id,
				v_client_repres_name,
				v_client_repres_post,
				v_client_name
			FROM client_tels
			LEFT JOIN ast_calls ON ast_calls.client_id=client_tels.client_id
			LEFT JOIN clients AS cl ON ast_calls.client_id=cl.id
			WHERE client_tels.tel=v_search OR client_tels.tel=v_tel_formatted
			ORDER BY ast_calls.dt DESC NULLS LAST
			LIMIT 1;
			
			NEW.client_tel = v_search;
			
			--In call for all notification
			IF NEW.call_type='in'::call_types
			AND NEW.end_time IS NULL
			THEN
				IF NEW.ext IS NOT NULL AND LENGTH(NEW.ext)>3 THEN
					v_event_id = 'AstCall.in_call';
				ELSIF NEW.ext IS NOT NULL THEN
					--extension exists!
					v_event_id = 'AstCall.in_call.'||NEW.ext;
				END IF;	
				
				IF v_event_id IS NOT NULL THEN
					PERFORM pg_notify(
						v_event_id
						,json_build_object(
							'params',json_build_object(
								'client_id',NEW.client_id
								,'client_name',v_client_name
								,'tel',v_tel_formatted
								,'client_repres_name',v_client_repres_name
								,'client_repres_post',v_client_repres_post
								,'ext',NEW.ext
								,'unique_id',NEW.unique_id
							)
						)::text
					);
				END IF;
			END IF;			
			
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
					v_tel_formatted = format_cel_phone(RIGHT(v_search,10));
				
					SELECT
						client_tels.client_id,
						client_tels.name,
						client_tels.post,
						cl.name_full
					INTO
						NEW.client_id,
						v_client_repres_name,
						v_client_repres_post,
						v_client_name
					FROM client_tels
					LEFT JOIN ast_calls ON ast_calls.client_id=client_tels.client_id
					LEFT JOIN clients AS cl ON ast_calls.client_id=cl.id
					WHERE client_tels.tel=v_search OR client_tels.tel=v_tel_formatted
					ORDER BY ast_calls.dt DESC NULLS LAST
					LIMIT 1;
					
					IF NEW.ext IS NOT NULL AND LENGTH(NEW.ext)>3 THEN
						v_event_id = 'AstCall.in_call';
					ELSIF NEW.ext IS NOT NULL THEN
						--extension exists!
						v_event_id = 'AstCall.in_call.'||NEW.ext;
					END IF;	
					
					IF v_event_id IS NOT NULL THEN
						PERFORM pg_notify(
							v_event_id
							,json_build_object(
								'params',json_build_object(
									'client_id',NEW.client_id
									,'client_name',v_client_name
									,'tel',v_tel_formatted
									,'client_repres_name',v_client_repres_name
									,'client_repres_post',v_client_repres_post
									,'ext',NEW.ext
									,'unique_id',NEW.unique_id
								)
							)::text
						);
					END IF;
					
				END IF;
				
			END IF;
		
			--notifications
			IF NEW.end_time IS NOT NULL AND OLD.end_time IS NULL AND NEW.ext IS NOT NULL AND LENGTH(NEW.ext)=3 THEN
				PERFORM pg_notify(
					'AstCall.hangup.'||NEW.ext
					,NULL
				);
				
			ELSIF NEW.end_time IS NULL AND OLD.start_time IS NULL AND NEW.start_time IS NOT NULL
			 AND NEW.ext IS NOT NULL AND LENGTH(NEW.ext)=3 THEN
				PERFORM pg_notify(
					'AstCall.pickup.'||NEW.ext
					,NULL
				);
				
			END IF;
			
		
			v_search = NEW.ext;
		ELSE		
			v_search = NEW.caller_id_num;
		END IF;

		--setting user from logged in
		SELECT
			u.id
		INTO
			NEW.user_id
		FROM users AS u
		WHERE u.tel_ext=v_search
		AND (
			SELECT TRUE
			FROM logins
			WHERE user_id=u.id and date_time_out IS NULL
			ORDER BY date_time_in desc LIMIT 1
		)
		LIMIT 1;
		
		
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

