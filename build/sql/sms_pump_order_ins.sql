-- View: sms_pump_order_ins

-- DROP VIEW sms_pump_order_ins;

CREATE OR REPLACE VIEW sms_pump_order_ins AS 
 SELECT o.id AS order_id,
    pvh.phone_cel,
    sms_templates_text(
    	ARRAY[
    		format('("quant","%s")'::text, o.quant::text)::template_value,
    		format('("date","%s")'::text, date5_descr(o.date_time::date)::text)::template_value,
    		format('("time","%s")'::text, time5_descr(o.date_time::time without time zone)::text)::template_value,
    		format('("date","%s")'::text, date8_descr(o.date_time::date)::text)::template_value,
    		format('("dest","%s")'::text, dest.name::text)::template_value,
    		format('("concrete","%s")'::text, ct.name::text)::template_value,
    		format('("client","%s")'::text, cl.name::text)::template_value,
    		format('("name","%s")'::text, o.descr)::template_value,
    		format('("tel","%s")'::text,format_cel_phone(o.phone_cel::text))::template_value,
    		format('("car","%s")'::text, vh.plate::text)::template_value
    	],
    	( SELECT t.pattern
           FROM sms_patterns t
          WHERE t.sms_type = 'order_for_pump_ins'::sms_types AND t.lang_id = 1
       )
   ) AS message
   FROM orders o
     LEFT JOIN concrete_types ct ON ct.id = o.concrete_type_id
     LEFT JOIN destinations dest ON dest.id = o.destination_id
     LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
     LEFT JOIN vehicles vh ON vh.id = pvh.vehicle_id
     LEFT JOIN clients cl ON cl.id = o.client_id
  WHERE o.pump_vehicle_id IS NOT NULL AND pvh.phone_cel IS NOT NULL AND pvh.phone_cel::text <> ''::text AND o.quant <> 0::double precision;

ALTER TABLE sms_pump_order_ins
  OWNER TO beton;

