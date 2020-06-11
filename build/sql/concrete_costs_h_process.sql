-- Function: concrete_costs_h_process()

-- DROP FUNCTION concrete_costs_h_process();

CREATE OR REPLACE FUNCTION concrete_costs_h_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='BEFORE' AND (TG_OP='INSERT' OR TG_OP='UPDATE') ) THEN		
		
		IF TG_OP='INSERT' OR coalesce(NEW.clients_list::text,'')<>coalesce(OLD.clients_list::text,'') THEN
			SELECT
				array_agg( ((sub.obj->'fields'->>'client')::json->'keys'->>'id')::int )
			INTO NEW.clients_ar
			FROM (
				SELECT jsonb_array_elements(NEW.clients_list->'rows') AS obj
			) AS sub;		
		
		END IF;
		
		IF NEW.clients_ar IS NULL THEN
			NEW.clients_ar = ARRAY[0];
		END IF;
		
		RETURN NEW;
		
	ELSIF (TG_WHEN='AFTER' AND TG_OP='INSERT') THEN		
		INSERT INTO concrete_costs
		(date,concrete_type_id,price,concrete_costs_h_id)
		(SELECT
			NEW.date,
			ctp.id,
			coalesce(coalesce(prices.price,ctp.price),0),
			NEW.id
		FROM concrete_types AS ctp
		LEFT JOIN (
			SELECT
				max(concrete_costs.date) AS date,
				concrete_costs.concrete_type_id
			FROM concrete_costs
			GROUP BY concrete_costs.concrete_type_id
		) AS price_hist ON price_hist.concrete_type_id=ctp.id
		LEFT JOIN concrete_costs AS prices ON prices.date=price_hist.date AND prices.concrete_type_id=price_hist.concrete_type_id
		WHERE ctp.name<>''
		);
		
		RETURN NEW;
		
	/*ELSIF (TG_WHEN='BEFORE' AND TG_OP='DELETE') THEN		
		DELETE FROM concrete_costs WHERE date=OLD.date;
		RETURN OLD;
	*/	
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION concrete_costs_h_process() OWNER TO ;

