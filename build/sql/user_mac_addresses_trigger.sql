-- Trigger: user_mac_addresses_trigger_before on public.user_mac_addresses

-- DROP TRIGGER user_mac_addresses_trigger_before ON public.user_mac_addresses;


CREATE TRIGGER user_mac_addresses_trigger_before
  BEFORE UPDATE OR INSERT
  ON public.user_mac_addresses
  FOR EACH ROW
  EXECUTE PROCEDURE public.user_mac_addresses_process();

