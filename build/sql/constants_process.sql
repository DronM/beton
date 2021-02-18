-- Function: public.constants_process()

-- DROP FUNCTION public.constants_process();

CREATE OR REPLACE FUNCTION public.constants_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF (TG_WHEN='AFTER' AND TG_OP='UPDATE') THEN
		IF NEW.val<>OLD.val THEN
			PERFORM pg_notify(
				'Constant.update'
				,json_build_object(
					'params',json_build_object(
						'id',substring(TG_TABLE_NAME from length('const_')+1)
						,'val',NEW.val::text
					)
				)::text
			);
		END IF;
		
		RETURN NEW;
	END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.constants_process() OWNER TO ;

