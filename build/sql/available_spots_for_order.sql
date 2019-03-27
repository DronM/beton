-- Function: public.available_spots_for_order(date, numeric, numeric)

-- DROP FUNCTION public.available_spots_for_order(date, numeric, numeric);

CREATE OR REPLACE FUNCTION public.available_spots_for_order(
    IN in_date date,
    IN in_quant numeric,
    IN in_speed_per_hour numeric)
  RETURNS TABLE(
  	avail_date_time timestamp without time zone,
  	avail_time_descr text
  ) AS
$BODY$
DECLARE
	o orders%rowtype;
	order_min_step int;
	shift_start timestamp;
	shift_end timestamp;
	norm_on_step numeric;
	tolerance numeric;
	shift_orders_curs refcursor;
	quant_spread_ar numeric[];
	quant_spread_ar_len int;
	quant_spread_ar_ind int;
	not_done boolean;
	shift_orders_r RECORD;
	shift_orders_ind int;
	record_fit boolean;
BEGIN
	order_min_step = const_order_step_min_val();
	shift_start = in_date + const_first_shift_start_time_val();
	shift_end = shift_start + const_shift_for_orders_length_time_val() - '00:00:01'::time;
	norm_on_step = const_max_hour_load_val()::numeric / 60 * order_min_step;
	tolerance = const_order_auto_place_tolerance_val()/60 * order_min_step;

	CREATE TEMP TABLE IF NOT EXISTS shift_orders_with_spread_quant
	(date_time timestamp, quant_ordered numeric)
	ON COMMIT DROP;
	
	
	FOR o IN 
		SELECT *
		FROM orders WHERE orders.date_time BETWEEN shift_start AND shift_end
	LOOP
		INSERT INTO shift_orders_with_spread_quant
		(SELECT d_start, quant_spread FROM spread_order_quant(o.date_time, o.date_time_to, o.quant::numeric,o.unload_speed::numeric, order_min_step));
	END LOOP;
	
	INSERT INTO shift_orders_with_spread_quant (date_time,quant_ordered)
	SELECT dt, 0 FROM generate_series(shift_start,shift_end,(order_min_step || ' minutes')::interval) AS dt;
	--shift_start

	quant_spread_ar = ARRAY(SELECT quant_spread FROM spread_order_quant(shift_start, get_order_date_time_to(shift_start,in_quant,in_speed_per_hour,order_min_step), 

in_quant, in_speed_per_hour, order_min_step));
	quant_spread_ar_len = array_upper(quant_spread_ar,1);
	--RAISE EXCEPTION '%',quant_spread_ar[2];

	OPEN shift_orders_curs SCROLL FOR SELECT
		norm_on_step + tolerance - SUM(shift_orders_with_spread_quant.quant_ordered) AS rest,
		shift_orders_with_spread_quant.date_time AS date_time
		FROM shift_orders_with_spread_quant
		WHERE ( (in_date=CURRENT_DATE) AND (shift_orders_with_spread_quant.date_time >= round_minutes(CURRENT_TIMESTAMP::timestamp without time zone,order_min_step)) )
		OR (in_date<>CURRENT_DATE)
		GROUP BY shift_orders_with_spread_quant.date_time
		ORDER BY shift_orders_with_spread_quant.date_time;
	
	not_done = true;
	shift_orders_ind = 0;
	LOOP
		MOVE ABSOLUTE shift_orders_ind FROM shift_orders_curs;
		
		record_fit = true;
		quant_spread_ar_ind = 1;
		WHILE quant_spread_ar_ind <= quant_spread_ar_len LOOP
			FETCH shift_orders_curs INTO shift_orders_r;

			IF quant_spread_ar_ind = 1 THEN
				avail_date_time = shift_orders_r.date_time;
				avail_time_descr = time5_descr(shift_orders_r.date_time::time);
			END IF;
			
			IF  FOUND=false THEN
				--no more rows
				not_done = false;
				EXIT;
			END IF;
			IF quant_spread_ar[quant_spread_ar_ind] > shift_orders_r.rest THEN
				record_fit = false;
				EXIT;
			END IF;
			quant_spread_ar_ind = quant_spread_ar_ind + 1;
		END LOOP;

		IF not_done = false THEN
			EXIT;
		END IF;	
		
		--fit record
		IF record_fit THEN
			RETURN NEXT;
		END IF;	
		
		shift_orders_ind = shift_orders_ind + 1;
	END LOOP;

	CLOSE shift_orders_curs;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
ALTER FUNCTION public.available_spots_for_order(date, numeric, numeric)
  OWNER TO beton;

