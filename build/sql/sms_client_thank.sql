-- View: sms_client_thank

-- DROP VIEW sms_client_thank;

CREATE OR REPLACE VIEW sms_client_thank AS 
	SELECT o.phone_cel,
		get_shift_start(o.date_time) AS shift,
		sms_templates_text(
			ARRAY[
				format('("quant","%s")'::text,
				sum(o.quant)::text)::template_value
			],
			( SELECT t.pattern
			FROM sms_patterns t
			WHERE t.sms_type = 'client_thank'::sms_types AND t.lang_id = 1
			)
		) AS message
	FROM orders o
	WHERE o.phone_cel IS NOT NULL
		AND o.phone_cel::text <> ''::text
		AND o.quant <> 0::double precision
		AND COALESCE(
			(SELECT sum(sh.quant) AS sum
			FROM shipments sh
			WHERE sh.order_id = o.id),0::double precision
		) > 0::double precision
	GROUP BY o.phone_cel, get_shift_start(o.date_time);

ALTER TABLE sms_client_thank
  OWNER TO beton;

