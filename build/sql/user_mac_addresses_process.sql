-- Function: user_mac_addresses_process()

-- DROP FUNCTION user_mac_addresses_process();

CREATE OR REPLACE FUNCTION user_mac_addresses_process()
  RETURNS trigger AS
$BODY$
BEGIN
	IF 
		(TG_OP='UPDATE' AND OLD.mac_address<>NEW.mac_address)
		OR (TG_OP='INSERT')
	THEN
		NEW.mac_address_hash = md5(NEW.mac_address);
				
	END IF;
	
	RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION user_mac_addresses_process()
  OWNER TO ;

