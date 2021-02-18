-- View: public.order_sms_remind

-- DROP VIEW public.order_sms_remind;

CREATE OR REPLACE VIEW public.order_sms_remind
 AS
 WITH shift AS (
         SELECT get_shift_bounds.shift_start,
            get_shift_bounds.shift_end
           FROM get_shift_bounds((now() + '1 day'::interval)::timestamp without time zone) get_shift_bounds(shift_start timestamp without time zone, shift_end timestamp without time zone)
        )
 SELECT o.phone_cel,
    replace(replace(replace(replace(replace(( SELECT pt.pattern AS text
           FROM sms_patterns pt
          WHERE pt.lang_id = o.lang_id AND pt.sms_type = 'remind'::sms_types), '[quant]'::text, o.quant::text), '[dest]'::text, d.name::text), '[concrete]'::text, concr.name::text), '[date]'::text, date8_descr((now() + '1 day'::interval)::date)::text), '[day_of_week]'::text, dow_descr((now() + '1 day'::interval)::date)::text) AS text,
    s.id AS sms_serv_id
   FROM sms_service s
     LEFT JOIN orders o ON o.id = s.order_id
     LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
     LEFT JOIN destinations d ON d.id = o.destination_id
  WHERE o.date_time >= (( SELECT shift.shift_start
           FROM shift)) AND o.date_time <= (( SELECT shift.shift_end
           FROM shift)) AND s.sms_id_remind IS NULL;

ALTER TABLE public.order_sms_remind
    OWNER TO beton;

GRANT ALL ON TABLE public.order_sms_remind TO beton;
GRANT SELECT ON TABLE public.order_sms_remind TO premier;


