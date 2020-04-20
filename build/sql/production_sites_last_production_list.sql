-- VIEW: production_sites_last_production_list

--DROP VIEW production_sites_last_production_list;

CREATE OR REPLACE VIEW production_sites_last_production_list AS
	SELECT
		p_s.id,
		p_s.name,
		p_s.elkon_connection,
		
		p_s.last_elkon_production_id AS last_production_id,
		
		/*		
		coalesce(
			(SELECT pr.production_dt_end IS NOT NULL FROM productions AS pr WHERE pr.production_id=p_s.last_elkon_production_id
			)
		,FALSE) AS closed,
		*/
		
		(
		SELECT
			array_agg(production_id)
			/*||(
				SELECT CASE
					WHEN (SELECT TRUE FROM productions
						WHERE production_site_id=p_s.id AND production_id=p_s.last_elkon_production_id
					) THEN NULL
					ELSE ARRAY[p_s.last_elkon_production_id]
					END
			)
			
			*/
		FROM productions
		WHERE production_site_id=p_s.id AND production_dt_end IS NULL
		) AS production_ids
		
	FROM production_sites AS p_s
	
	WHERE p_s.active AND p_s.elkon_connection IS NOT NULL AND p_s.last_elkon_production_id IS NOT NULL
	;
	
ALTER VIEW production_sites_last_production_list OWNER TO ;
