-- View: shipment_dates_list

 DROP VIEW shipment_dates_list;

CREATE OR REPLACE VIEW shipment_dates_list AS 
	SELECT
		sh.ship_date_time::date AS ship_date,
		
		concr.id AS concrete_type_id,
		concrete_types_ref(concr) AS concrete_types_ref,
		
		dest.id AS destination_id,
		destinations_ref(dest) AS destinations_ref,
		
		cl.id AS client_id,
		clients_ref(cl) AS clients_ref,
		
		sh.production_site_id,
		production_sites_ref(psites) AS production_sites_ref,
		
		sum(sh.quant) AS quant,
		sum(calc_ship_coast(sh.*, dest.*, true)) AS ship_cost,
		sum(sh.demurrage::interval)::time without time zone AS demurrage,
		sum(calc_demurrage_coast(sh.demurrage::interval)) AS demurrage_cost
		
	FROM shipments sh
	LEFT JOIN orders o ON o.id = sh.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN destinations dest ON dest.id = o.destination_id
	LEFT JOIN production_sites psites ON psites.id = sh.production_site_id
	GROUP BY
		sh.ship_date_time::date,
		concr.id,
		dest.id,		
		cl.id,
		sh.production_site_id,
		psites.*
	ORDER BY sh.ship_date_time::date DESC;

ALTER TABLE shipment_dates_list
  OWNER TO beton;

