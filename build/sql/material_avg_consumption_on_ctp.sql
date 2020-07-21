-- Function: public.material_avg_consumption_on_ctp(timestamp without time zone, timestamp without time zone)

-- DROP FUNCTION public.material_avg_consumption_on_ctp(timestamp without time zone, timestamp without time zone);

CREATE OR REPLACE FUNCTION public.material_avg_consumption_on_ctp(
    IN in_date_time_from timestamp without time zone,
    IN in_date_time_to timestamp without time zone)
  RETURNS TABLE(
  	concrete_type_name text,
  	concrete_type_id integer,
  	material_name text,
  	material_id integer,
  	material_ord integer,
  	concrete_quant numeric,
  	norm_quant numeric,
  	norm_cost numeric,
  	norm_quant_per_m3 numeric,
  	norm_cost_per_m3 numeric,
  	material_quant numeric,
  	material_cost numeric,
  	material_quant_per_m3 numeric,
  	material_cost_per_m3 numeric
  ) AS
$BODY$
/*
	SELECT		
		ct.name AS concrete_type_name
		,ct.id AS concrete_type_id
		,t.materials_ref->>'descr' AS material_name
		,(t.materials_ref->'keys'->>'id')::int AS material_id
		,t.material_ord AS material_ord
		,sum(pr.concrete_quant)::numeric(19,4) AS concrete_quant
		,sum(t.quant_consuption)::numeric(19,4) AS norm_quant
		,round( coalesce(m_price.price,0) * sum(t.quant_consuption)::numeric(19,4) ,2) AS norm_cost
		,CASE WHEN sum(pr.concrete_quant)=0 THEN 0 ELSE round( (sum(t.quant_consuption)/sum(pr.concrete_quant))::numeric(19,4), 4) END AS norm_quant_per_m3
		,CASE WHEN sum(pr.concrete_quant)=0 THEN 0 ELSE round( (coalesce(m_price.price,0) * sum(t.quant_consuption) / sum(pr.concrete_quant))::numeric ,2) END AS norm_cost_per_m3
		,sum(t.material_quant) AS material_quant
		,round( coalesce(m_price.price,0) * sum(t.material_quant)::numeric(19,4), 2) AS material_cost
		,CASE WHEN sum(pr.concrete_quant)=0 THEN 0 ELSE round( (sum(t.material_quant) / sum(pr.concrete_quant))::numeric(19,4), 4) END AS material_quant_per_m3
		,CASE WHEN sum(pr.concrete_quant)=0 THEN 0 ELSE round( coalesce(m_price.price,0) * sum(t.material_quant) / sum(pr.concrete_quant) ,2) END AS material_cost_per_m3
	FROM production_material_list AS t
	LEFT JOIN productions AS pr ON pr.production_site_id=t.production_site_id AND pr.production_id=t.production_id
	LEFT JOIN concrete_types AS ct ON ct.id=pr.concrete_type_id
	LEFT JOIN (
		SELECT
			pr.raw_material_id
			,max(pr.date_time) AS date_time
		FROM raw_material_prices AS pr
		GROUP BY pr.raw_material_id
	) AS m_pr ON m_pr.raw_material_id=t.material_id
	LEFT JOIN raw_material_prices AS m_price ON m_price.date_time=m_pr.date_time AND m_price.raw_material_id=m_pr.raw_material_id
	WHERE t.date_time BETWEEN in_date_time_from AND in_date_time_to
	GROUP BY ct.id,ct.name,t.material_ord,t.materials_ref->>'descr',t.materials_ref->'keys'->>'id',m_price.price
	ORDER BY ct.name,t.material_ord
	;
*/	
--////////////////////////////	
/*
	WITH 
	prod_tot AS (
		SELECT		
			pr.concrete_type_id
			,sum(pr.concrete_quant) AS quant
		FROM productions AS pr
		WHERE pr.id IN (
			SELECT prod.id
			FROM material_fact_consumptions AS t
			LEFT JOIN productions AS prod ON prod.production_site_id=t.production_site_id AND prod.production_id=t.production_id
			WHERE t.date_time BETWEEN in_date_time_from AND in_date_time_to
		)
		GROUP BY pr.concrete_type_id
	)
	SELECT
		sub.concrete_type_name
		,sub.concrete_type_id
		,sub.material_name
		,sub.material_id
		,mat.ord AS material_ord
		,prod_tot.quant AS concrete_quant
		,sum(sub.norm_quant)::numeric(19,4) AS norm_quant
		,sum(sub.norm_cost)::numeric(15,5) AS norm_cost
		,CASE WHEN prod_tot.quant=0 THEN 0 ELSE round( (sum(sub.norm_quant)/prod_tot.quant)::numeric(19,4), 4) END AS norm_quant_per_m3
		,CASE WHEN prod_tot.quant=0 THEN 0 ELSE round( sum(sub.norm_cost) / prod_tot.quant ,2) END AS norm_cost_per_m3
		,sum(sub.material_quant) AS material_quant
		,sum(sub.material_cost) AS material_cost
		,CASE WHEN prod_tot.quant=0 THEN 0 ELSE round( (sum(sub.material_quant) / prod_tot.quant)::numeric(19,4), 4) END AS material_quant_per_m3
		,CASE WHEN prod_tot.quant=0 THEN 0 ELSE round( (sum(sub.material_cost) / prod_tot.quant)::numeric(19,4) ,2) END AS material_cost_per_m3
	FROM
	(SELECT
		t.concrete_types_ref->>'descr' AS concrete_type_name
		,(t.concrete_types_ref->'keys'->>'id')::int AS concrete_type_id
		,t.raw_materials_ref->>'descr' AS material_name
		,(t.raw_materials_ref->'keys'->>'id')::int AS material_id
		,t.material_quant_shipped AS norm_quant
		,round(
			coalesce((SELECT m_pr.price
			FROM raw_material_prices AS m_pr
			WHERE m_pr.raw_material_id=(t.raw_materials_ref->'keys'->>'id')::int AND m_pr.date_time<t.date_time
			ORDER BY m_pr.date_time DESC LIMIT 1
			),0) * t.material_quant_shipped::numeric(19,4)
		,2) AS norm_cost
		,t.material_quant AS material_quant
		,round(
			coalesce(
			(SELECT m_pr.price
			FROM raw_material_prices AS m_pr
			WHERE m_pr.raw_material_id=(t.raw_materials_ref->'keys'->>'id')::int AND m_pr.date_time<t.date_time
			ORDER BY m_pr.date_time DESC LIMIT 1)		
			,0) * t.material_quant
		, 2) AS material_cost
	
	FROM material_fact_consumptions_list AS t
	WHERE t.date_time::date BETWEEN in_date_time_from AND in_date_time_to
	) AS sub
	LEFT JOIN raw_materials AS mat ON mat.id=sub.material_id
	LEFT JOIN prod_tot ON prod_tot.concrete_type_id=sub.concrete_type_id	
	GROUP BY 
		sub.concrete_type_name
		,sub.concrete_type_id
		,sub.material_name
		,sub.material_id
		,mat.ord
		,prod_tot.quant
	ORDER BY sub.concrete_type_name,mat.ord
	;
*/


--**********************************************************************
	SELECT
		ct.name AS concrete_type_name
		,sub.concrete_type_id	
		,mat.name
		,sub.material_id
		,mat.ord	
	
		,sum(sub.concrete_quant)::numeric(19,4) AS concrete_quant
		,sum(sub.norm_quant)::numeric(19,4) AS norm_quant
		,sum(sub.norm_cost)::numeric(15,2) AS norm_cost
		,CASE WHEN sum(sub.concrete_quant) =0 THEN 0 ELSE round( (sum(sub.norm_quant)/sum(sub.concrete_quant) )::numeric(19,4), 4) END AS norm_quant_per_m3
		,CASE WHEN sum(sub.concrete_quant)=0 THEN 0 ELSE round( sum(sub.norm_cost) / sum(sub.concrete_quant) ,2) END AS norm_cost_per_m3

		,sum(sub.material_quant) AS material_quant
		,sum(sub.material_cost) AS material_cost
		,CASE WHEN sum(sub.concrete_quant)=0 THEN 0 ELSE round( (sum(sub.material_quant) / sum(sub.concrete_quant))::numeric(19,4), 4) END AS material_quant_per_m3
		,CASE WHEN sum(sub.concrete_quant)=0 THEN 0 ELSE round( (sum(sub.material_cost) / sum(sub.concrete_quant))::numeric(19,4) ,2) END AS material_cost_per_m3
	
	FROM
	(
	SELECT
		--sh.id
		prod.production_id
		,t.raw_material_id AS material_id
		,t.concrete_type_id
		,coalesce(t.concrete_quant,0) AS concrete_quant
		,sum(coalesce(t.material_quant,0)) AS material_quant
		,sum(round(
			coalesce(
				(SELECT m_pr.price
				FROM raw_material_prices AS m_pr
				WHERE m_pr.raw_material_id=t.raw_material_id AND m_pr.date_time<t.date_time
				ORDER BY m_pr.date_time DESC LIMIT 1
				)
			,0) * 
			coalesce(t.material_quant,0)	
		,2)) AS material_cost	
	
		,CASE
			WHEN coalesce(sh.quant,0)=0 OR coalesce(t.concrete_quant,0)=0 THEN 0
			ELSE coalesce(ra_mat.quant,0)/coalesce(sh.quant,0) * coalesce(t.concrete_quant,0)
		END AS norm_quant			
		,round(
			coalesce(
				(SELECT m_pr.price
				FROM raw_material_prices AS m_pr
				WHERE m_pr.raw_material_id=t.raw_material_id AND m_pr.date_time<t.date_time
				ORDER BY m_pr.date_time DESC LIMIT 1
				)
			,0) * 
			CASE
				WHEN coalesce(sh.quant,0)=0 OR coalesce(t.concrete_quant,0)=0 THEN 0
				ELSE coalesce(ra_mat.quant,0)/coalesce(sh.quant,0) * coalesce(t.concrete_quant,0)
			END::numeric(19,4)		
		,2) AS norm_cost	
	FROM material_fact_consumptions AS t
	LEFT JOIN productions AS prod ON prod.production_site_id=t.production_site_id AND prod.production_id=t.production_id
	LEFT JOIN shipments AS sh ON sh.id=prod.shipment_id
	LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=sh.id AND ra_mat.material_id=t.raw_material_id
	WHERE t.date_time BETWEEN in_date_time_from AND in_date_time_to
	--'2020-07-19 06:00' AND '2020-07-20 06:00'
	--AND t.raw_material_id=7
	GROUP BY 
		--sh.id
		prod.production_id
		,t.concrete_type_id	
		,t.raw_material_id
		,t.concrete_quant
		,norm_quant
		,norm_cost
	) AS sub
	LEFT JOIN concrete_types AS ct ON ct.id=sub.concrete_type_id
	LEFT JOIN raw_materials AS mat ON mat.id=sub.material_id
	GROUP BY
		ct.name
		,sub.concrete_type_id	
		,mat.name
		,sub.material_id
		,mat.ord	
	ORDER BY ct.name,mat.ord
	;



$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.material_avg_consumption_on_ctp(timestamp without time zone, timestamp without time zone)
  OWNER TO beton;

