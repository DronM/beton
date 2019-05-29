-- View: shipment_dates_list

 DROP VIEW shipment_dates_list;

CREATE OR REPLACE VIEW shipment_dates_list AS 
	SELECT
		sh.ship_date_time::date AS ship_date,
		
		sh.concrete_type_id,
		sh.concrete_types_ref::text,
		
		sh.destination_id,
		sh.destinations_ref::text,
		
		sh.client_id,
		sh.clients_ref::text,
		
		sh.production_site_id,
		sh.production_sites_ref::text,
		
		sum(sh.quant) AS quant,
		sum(sh.cost) AS ship_cost,
		
		sum(sh.demurrage) AS demurrage,
		sum(sh.demurrage_cost) AS demurrage_cost
		
	FROM shipments_list sh
	/*LEFT JOIN shipments sh_t ON sh_t.id = sh.id
	LEFT JOIN orders o ON o.id = sh_t.order_id
	LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
	LEFT JOIN clients cl ON cl.id = o.client_id
	LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
	*/
	GROUP BY
		sh.ship_date_time::date,
		sh.concrete_type_id,
		sh.concrete_types_ref::text,
		sh.destination_id,
		sh.destinations_ref::text,
		sh.client_id,
		sh.clients_ref::text,
		sh.production_site_id,
		sh.production_sites_ref::text
		
	ORDER BY sh.ship_date_time::date DESC;

ALTER TABLE shipment_dates_list
  OWNER TO beton;

