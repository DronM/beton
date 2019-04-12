-- View: ast_calls_client_call_history_list

-- DROP VIEW ast_calls_client_call_hist_list;

CREATE OR REPLACE VIEW ast_calls_client_call_history_list AS 
	SELECT
		ast.unique_id,
		ast.client_id,
		ast.dt,
		ast.manager_comment
	FROM ast_calls ast
	ORDER BY ast.dt;

ALTER TABLE ast_calls_client_call_history_list
  OWNER TO beton;

