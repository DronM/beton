-- View: sms_pump_remind

--DROP VIEW sms_pump_remind;

CREATE OR REPLACE VIEW sms_pump_remind AS 
	SELECT
		pvh.phone_cel,
		o.date_time,		
		sms_templates_text(
			ARRAY[
			format('("quant","%s")',
				o.quant::text)::template_value,
			format('("time","%s")',
				time5_descr(o.date_time::time)::text)::template_value,
			format('("dest","%s")',
				dest.name::text)::template_value,				
			format('("concrete","%s")',
				ct.name::text)::template_value
			],
			(SELECT t.pattern FROM sms_patterns t
			WHERE t.sms_type='remind_for_pump'::sms_types
			AND t.lang_id=1)
		) AS message		
	FROM orders o	
	LEFT JOIN concrete_types ct ON ct.id=o.concrete_type_id	
	LEFT JOIN destinations dest ON
		dest.id=o.destination_id		
	LEFT JOIN pump_vehicles pvh ON pvh.id=o.pump_vehicle_id
	LEFT JOIN vehicles vh ON vh.id=pvh.vehicle_id
	WHERE o.pump_vehicle_id IS NOT NULL
		AND pvh.phone_cel IS NOT NULL
		AND pvh.phone_cel<>''
		AND o.quant<>0
	;
ALTER TABLE sms_pump_remind OWNER TO beton;