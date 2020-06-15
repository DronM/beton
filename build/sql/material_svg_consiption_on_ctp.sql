-- Function: public.material_avg_consumption_on_ctp(in_date_time_from timestamp, in_date_time_to timestamp)

-- DROP FUNCTION public.material_avg_consumption_on_ctp(in_date_time_from timestamp, in_date_time_to timestamp);

CREATE OR REPLACE FUNCTION material_avg_consumption_on_ctp(in_date_time_from timestamp, in_date_time_to timestamp)
  RETURNS table(
  	concrete_type_name text
  	,concrete_type_id int
  	,material_name text
  	,material_id int
  	,material_ord int
  	,concrete_quant numeric(19,4)
  	,norm_quant numeric(19,4)
  	,norm_cost numeric(19,2)
  	,norm_quant_per_m3 numeric(19,2)
  	,norm_cost_per_m3 numeric(19,2)
  	,material_quant numeric(19,4)
  	,material_cost numeric(19,2)
  	,material_quant_per_m3 numeric(19,2)
  	,material_cost_per_m3 numeric(19,2)  	
  ) AS
$BODY$
	SELECT		
		ct.name AS concrete_type_name
		,ct.id AS concrete_type_id
		,t.materials_ref->>'descr' AS material_name
		,(t.materials_ref->'keys'->>'id')::int AS material_id
		,t.material_ord AS material_ord
		,sum(pr.concrete_quant)::numeric(19,4) AS concrete_quant
		,sum(t.quant_consuption)::numeric(19,4) AS norm_quant
		,round( coalesce(m_price.price,0) / 1000 * sum(t.quant_consuption)::numeric(19,4) ,2) AS norm_cost
		,CASE WHEN sum(pr.concrete_quant)=0 THEN 0 ELSE round( (sum(t.quant_consuption)/sum(pr.concrete_quant))::numeric(19,4), 4) END AS norm_quant_per_m3
		,CASE WHEN sum(pr.concrete_quant)=0 THEN 0 ELSE round( (coalesce(m_price.price,0) / 1000 * sum(t.quant_consuption) / sum(pr.concrete_quant))::numeric ,2) END AS norm_cost_per_m3
		,sum(t.material_quant) AS material_quant
		,round( coalesce(m_price.price,0) / 1000 * sum(t.material_quant)::numeric(19,4), 2) AS material_cost
		,CASE WHEN sum(pr.concrete_quant)=0 THEN 0 ELSE round( (sum(t.material_quant) / sum(pr.concrete_quant))::numeric(19,4), 4) END AS material_quant_per_m3
		,CASE WHEN sum(pr.concrete_quant)=0 THEN 0 ELSE round( coalesce(m_price.price,0) / 1000 * sum(t.material_quant) / sum(pr.concrete_quant) ,2) END AS material_cost_per_m3
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
$BODY$
  LANGUAGE sql VOLATILE
  COST 100;
	
ALTER FUNCTION material_avg_consumption_on_ctp(in_date_time_from timestamp, in_date_time_to timestamp) OWNER TO ;

