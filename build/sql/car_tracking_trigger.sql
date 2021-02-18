-- Trigger: car_tracking_after_insert

-- DROP TRIGGER car_tracking_after_insert ON public.car_tracking;

CREATE TRIGGER car_tracking_after_insert
    AFTER INSERT
    ON public.car_tracking
    FOR EACH ROW
    EXECUTE PROCEDURE public.geo_zone_check(\x);
