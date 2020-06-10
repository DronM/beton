-- View: doc_material_procurements_list

-- DROP VIEW doc_material_procurements_list;

CREATE OR REPLACE VIEW doc_material_procurements_list AS 
 SELECT
 	doc.id,
	doc.number,
	doc.date_time,
	doc.processed,
	doc.supplier_id,
	suppliers_ref(sup) AS suppliers_ref,
	doc.carrier_id,
	suppliers_ref(car) AS carriers_ref,
	doc.material_id,
	materials_ref(mat) AS materials_ref,
	doc.cement_silos_id,
	cement_silos_ref(silo) AS cement_silos_ref,
	doc.driver,
	doc.vehicle_plate,
	doc.quant_gross,
	doc.quant_net,
	store
   FROM doc_material_procurements doc
     LEFT JOIN suppliers sup ON sup.id = doc.supplier_id
     LEFT JOIN suppliers car ON car.id = doc.carrier_id
     LEFT JOIN raw_materials mat ON mat.id = doc.material_id
     LEFT JOIN cement_silos silo ON silo.id = doc.cement_silos_id
  ORDER BY doc.date_time DESC;

ALTER TABLE doc_material_procurements_list
  OWNER TO beton;

