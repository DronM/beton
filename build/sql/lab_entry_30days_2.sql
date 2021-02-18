-- View: public.lab_entry_30days_2

-- DROP VIEW public.lab_entry_30days_2;

CREATE OR REPLACE VIEW public.lab_entry_30days_2 AS 
 WITH start_h AS (
         SELECT date_part('hour'::text, const_first_shift_start_time_val()) AS h
        ), end_h AS (
         SELECT date_part('hour'::text, const_first_shift_start_time_val()) + date_part('hour'::text, const_day_shift_length_val()) AS h
        ), sub AS (
         SELECT det.concrete_type_id,
            ct.name AS concrete_name,
            upper(substr(ct.name::text, 1, 2)) = 'ПБ'::text AS is_pb,
            sum(det.cnt) AS cnt,
            sum(det.day_cnt) AS day_cnt,
            sum(det.selected_cnt) AS selected_cnt,
            round(avg(det.ok)) AS ok,
            round(avg(det.p7)) AS p7,
            round(avg(det.p28)) AS p28
           FROM ( SELECT o.concrete_type_id,
                    1 AS cnt,
                        CASE
                            WHEN date_part('dow'::text, sh.ship_date_time) = 0::double precision OR date_part('dow'::text, sh.ship_date_time) = 6::double precision THEN 0
                            WHEN date_part('hour'::text, sh.ship_date_time) < (( SELECT t.h
                               FROM start_h t)) OR date_part('hour'::text, sh.ship_date_time) >= (( SELECT t.h
                               FROM end_h t)) THEN 0
                            ELSE 1
                        END AS day_cnt,
                        CASE
                            WHEN date_part('dow'::text, sh.ship_date_time) > 0::double precision AND date_part('dow'::text, sh.ship_date_time) < 6::double precision AND lab.id IS NOT NULL AND (date_part('hour'::text, sh.ship_date_time) >= (( SELECT t.h
                               FROM start_h t)) OR date_part('hour'::text, sh.ship_date_time) < (( SELECT t.h
                               FROM end_h t))) THEN 1
                            ELSE 0
                        END AS selected_cnt,
                    lab.p7,
                    lab.p28,
                    lab.ok
                   FROM shipments sh
                     LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
                     LEFT JOIN orders o ON o.id = sh.order_id
                     LEFT JOIN concrete_types ct_1 ON ct_1.id = o.concrete_type_id
                     LEFT JOIN lab_entry_list_view lab ON lab.shipment_id = sh.id
                  WHERE sh.ship_date_time >= (now()::timestamp without time zone - ((const_lab_days_for_avg_val() || ' days'::text)::interval)) AND sh.ship_date_time <= now()::timestamp without time zone AND ct_1.pres_norm > 0::numeric
        ) det
             LEFT JOIN concrete_types ct ON ct.id = det.concrete_type_id
          GROUP BY det.concrete_type_id, ct.name
        ), sub2 AS (
         SELECT det.concrete_type_id,
            ct.name AS concrete_name,
            upper(substr(ct.name::text, 1, 2)) = 'ПБ'::text AS is_pb,
            sum(det.cnt) AS cnt,
            sum(det.day_cnt) AS day_cnt,
            sum(det.selected_cnt) AS selected_cnt,
            round(avg(det.ok)) AS ok,
            round(avg(det.p7)) AS p7,
            round(avg(det.p28)) AS p28
           FROM ( SELECT o.concrete_type_id,
                    1 AS cnt,
                        CASE
                            WHEN date_part('dow'::text, sh.ship_date_time) = 0::double precision OR date_part('dow'::text, sh.ship_date_time) = 6::double precision THEN 0
                            WHEN date_part('hour'::text, sh.ship_date_time) < (( SELECT t.h
                               FROM start_h t)) OR date_part('hour'::text, sh.ship_date_time) >= (( SELECT t.h
                               FROM end_h t)) THEN 0
                            ELSE 1
                        END AS day_cnt,
                        CASE
                            WHEN date_part('dow'::text, sh.ship_date_time) > 0::double precision AND date_part('dow'::text, sh.ship_date_time) < 6::double precision AND lab.id IS NOT NULL AND (date_part('hour'::text, sh.ship_date_time) >= (( SELECT t.h
                               FROM start_h t)) OR date_part('hour'::text, sh.ship_date_time) < (( SELECT t.h
                               FROM end_h t))) THEN 1
                            ELSE 0
                        END AS selected_cnt,
                    lab.p7,
                    lab.p28,
                    lab.ok
                   FROM shipments sh
                     LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
                     LEFT JOIN orders o ON o.id = sh.order_id
                     LEFT JOIN concrete_types ct_1 ON ct_1.id = o.concrete_type_id
                     LEFT JOIN lab_entry_list_view lab ON lab.shipment_id = sh.id
                  WHERE sh.ship_date_time >= (now()::timestamp without time zone - (((const_lab_days_for_avg_val() * 2) || ' days'::text)::interval)) AND sh.ship_date_time <= (now()::timestamp without time zone - ((const_lab_days_for_avg_val() || ' days'::text)::interval)) AND ct_1.pres_norm > 0::numeric) det
             LEFT JOIN concrete_types ct ON ct.id = det.concrete_type_id
          GROUP BY det.concrete_type_id, ct.name
        )
( SELECT subsub.concrete_type_id,
    subsub.concrete_type_descr,
    sum(subsub.cnt) AS cnt,
    sum(subsub.day_cnt) AS day_cnt,
    sum(subsub.selected_cnt) AS selected_cnt,
    sum(subsub.selected_avg_cnt) AS selected_avg_cnt,
    sum(subsub.need_cnt) AS need_cnt,
    sum(subsub.ok) AS ok,
    sum(subsub.p7) AS p7,
    sum(subsub.p28) AS p28,
    sum(subsub.selected_cnt2) AS selected_cnt2,
    sum(subsub.ok2) AS ok2,
    sum(subsub.p72) AS p72,
    sum(subsub.p282) AS p282
   FROM ( SELECT sub.concrete_type_id,
            sub.concrete_name AS concrete_type_descr,
            sub.cnt,
            sub.day_cnt,
            sub.selected_cnt,
            ( SELECT round(avg(t.selected_cnt)) AS round
                   FROM sub t
                  WHERE t.is_pb = false) AS selected_avg_cnt,
                CASE
                    WHEN (( SELECT round(avg(t.selected_cnt)) AS round
                       FROM sub t
                      WHERE t.is_pb = false)) > sub.selected_cnt::numeric THEN (( SELECT round(avg(t.selected_cnt)) AS round
                       FROM sub t
                      WHERE t.is_pb = false)) - sub.selected_cnt::numeric
                    ELSE (( SELECT const_lab_min_sample_count_val() AS const_lab_min_sample_count_val))::numeric
                END AS need_cnt,
            sub.ok,
            sub.p7,
            sub.p28,
            0 AS selected_cnt2,
            0 AS ok2,
            0 AS p72,
            0 AS p282
           FROM sub
        UNION
         SELECT sub2.concrete_type_id,
            sub2.concrete_name AS concrete_type_descr,
            0 AS cnt,
            0 AS day_cnt,
            0 AS selected_cnt,
            0 AS selected_avg_cnt,
            0 AS need_cnt,
            0 AS ok,
            0 AS p7,
            0 AS p28,
            sub2.selected_cnt AS selected_cnt2,
            sub2.ok AS ok2,
            sub2.p7 AS p72,
            sub2.p28 AS p282
           FROM sub2) subsub
  GROUP BY subsub.concrete_type_id, subsub.concrete_type_descr
  ORDER BY subsub.concrete_type_descr)
UNION ALL
 SELECT NULL::integer AS concrete_type_id,
    'ИТОГИ'::character varying AS concrete_type_descr,
    ( SELECT sum(t.cnt) AS sum
           FROM sub t) AS cnt,
    ( SELECT sum(t.day_cnt) AS sum
           FROM sub t) AS day_cnt,
    ( SELECT sum(t.selected_cnt) AS sum
           FROM sub t
          WHERE t.is_pb = false) AS selected_cnt,
    ( SELECT sum(t.selected_cnt) AS sum
           FROM sub t
          WHERE t.is_pb = false) AS selected_avg_cnt,
    0 AS need_cnt,
    ( SELECT round(avg(t.ok)) AS round
           FROM sub t) AS ok,
    ( SELECT round(avg(t.p7)) AS round
           FROM sub t) AS p7,
    ( SELECT round(avg(t.p28)) AS round
           FROM sub t) AS p28,
    ( SELECT sum(t.selected_cnt) AS sum
           FROM sub2 t
          WHERE t.is_pb = false) AS selected_cnt2,
    ( SELECT round(avg(t.ok)) AS round
           FROM sub2 t) AS ok2,
    ( SELECT round(avg(t.p7)) AS round
           FROM sub2 t) AS p72,
    ( SELECT round(avg(t.p28)) AS round
           FROM sub2 t) AS p282;

ALTER TABLE public.lab_entry_30days_2 OWNER TO ;

