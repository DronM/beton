-- VIEW: cement_silos_for_order_list

--DROP VIEW cement_silos_for_order_list;

CREATE OR REPLACE VIEW cement_silos_for_order_list AS
	SELECT
		t.id,
		t.name,
		production_sites_ref(pst) AS production_sites_ref,
		t.load_capacity,
		bal.quant AS balance
		
	FROM cement_silos AS t	
	LEFT JOIN production_sites AS pst ON pst.id=t.production_site_id
	LEFT JOIN rg_cement_balance(NULL) AS bal ON bal.cement_silos_id=t.id
	WHERE coalesce(t.visible,FALSE)=TRUE
	ORDER BY pst.name,t.name
	;
	
ALTER VIEW cement_silos_for_order_list OWNER TO ;
