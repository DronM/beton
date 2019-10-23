-- View: ast_calls_current

 DROP VIEW ast_calls_current;

CREATE OR REPLACE VIEW ast_calls_current AS 
	SELECT DISTINCT ON (ast.ext)
		ast.unique_id,
		ast.ext,
				
		CASE
			WHEN clt.tel IS NOT NULL THEN clt.tel
			WHEN substr(ast.caller_id_num,1,1)='+' THEN '8'||substr(ast.caller_id_num,2)			
			ELSE ast.caller_id_num::text
		END AS contact_tel,
		
		--backward compatibility
		CASE
			WHEN clt.tel IS NOT NULL THEN clt.tel
			WHEN substr(ast.caller_id_num,1,1)='+' THEN '8'||substr(ast.caller_id_num,2)			
			ELSE ast.caller_id_num::text
		END AS num,
		
		ast.dt AS ring_time,
		ast.start_time AS answer_time,
		ast.end_time AS hangup_time,
		ast.client_id,
		clients_ref(cl) AS clients_ref,
		cl.name AS client_descr,
		cl.client_kind,
		get_client_kinds_descr(cl.client_kind) AS client_kind_descr,
		ast.manager_comment,
		ast.informed,
		clt.name AS contact_name,
		cld.debt,
		man.name AS client_manager_descr,
		client_types_ref(ctp) AS client_types_ref,
		client_come_from_ref(ccf) AS client_come_from_ref
		
		
   FROM ast_calls ast
     LEFT JOIN clients cl ON cl.id = ast.client_id
     LEFT JOIN users man ON cl.manager_id = man.id
     LEFT JOIN client_tels clt ON clt.client_id = ast.client_id AND (clt.tel=ast.caller_id_num OR clt.tel::text = format_cel_phone("right"(ast.caller_id_num::text, 10)))
     LEFT JOIN client_debts cld ON cld.client_id = ast.client_id
     LEFT JOIN client_types ctp ON ctp.id = cl.client_type_id
     LEFT JOIN client_come_from ccf ON ccf.id = cl.client_come_from_id
  WHERE
  	ast.end_time IS NULL
  	AND char_length(ast.ext::text) <> char_length(ast.caller_id_num::text)
  	AND ast.caller_id_num::text <> ''::text
  	AND ( (ast.start_time IS NULL AND ast.dt::date=now()::date) OR (ast.start_time IS NOT NULL AND ast.start_time::date=now()::date) )
  ORDER BY ast.ext, ast.dt DESC;

ALTER TABLE ast_calls_current
  OWNER TO beton;

