-- VIEW: rep_forming

--DROP VIEW rep_forming;

CREATE OR REPLACE VIEW rep_forming AS
	SELECT
		f_op.date_time::date AS form_date
		,work_shifts_ref(sh) AS work_shifts_ref
		,count(*) AS tot_cnt
		,sum(weight) AS tot_weight
		,sum(volume) AS tot_volume
		
	FROM form_operations AS f_op
	LEFT JOIN work_shifts AS sh ON sh.id=f_op.work_shift_id
	GROUP BY
		f_op.date_time::date
		,sh.*
		,work_shifts_ref(sh)::text
	;
	
ALTER VIEW rep_forming OWNER TO beton;
