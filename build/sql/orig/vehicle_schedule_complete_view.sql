-- View: vehicle_schedule_complete_view

-- DROP VIEW vehicle_schedule_complete_view;

CREATE OR REPLACE VIEW vehicle_schedule_complete_view AS 
 SELECT vs.id,
    (v.plate::text || ' '::text) || d.name::text AS vehicle_schedule_descr
   FROM vehicle_schedules vs
     LEFT JOIN drivers d ON d.id = vs.driver_id
     LEFT JOIN vehicles v ON v.id = vs.vehicle_id
     LEFT JOIN vehicle_schedule_states st ON st.schedule_id = vs.id AND st.date_time = (( SELECT max(vehicle_schedule_states.date_time) AS max
           FROM vehicle_schedule_states
          WHERE vehicle_schedule_states.schedule_id = vs.id))
  WHERE st.state = 'free'::vehicle_states AND vs.schedule_date =
        CASE
            WHEN now()::time without time zone < constant_first_shift_start_time() THEN now()::date - 1
            ELSE now()::date
        END;

ALTER TABLE vehicle_schedule_complete_view
  OWNER TO beton;

