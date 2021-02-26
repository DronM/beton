-- Function: login_devices_uniq(user_agent jsonb)

-- DROP FUNCTION login_devices_uniq(user_agent jsonb);

CREATE OR REPLACE FUNCTION login_devices_uniq(user_agent jsonb)
  RETURNS text AS
$$
	SELECT 'Устройство: '||(user_agent->>'device')||', ОС: '||(user_agent->'osInfo'->>'name');
$$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION login_devices_uniq(user_agent jsonb) OWNER TO ;

