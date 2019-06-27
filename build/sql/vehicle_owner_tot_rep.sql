
WITH
	--миксеры,водители,простой
	ships AS (
		SELECT
			sum(cost) AS cost,
			sum(cost_for_driver) AS cost_for_driver,
			sum(demurrage_cost) AS demurrage_cost
		FROM shipments_for_veh_owner_list AS t
		WHERE
			t.vehicle_owner_id = 156
			AND t.ship_date_time BETWEEN '2019-05-01 06:00' AND '2019-06-01 05:59:59'
	)
	
	--насосы
	,pumps AS (
		SELECT
			sum(t.pump_cost) AS cost
		FROM shipments_pump_list t
		WHERE
			t.pump_vehicle_owner_id = 156
			AND t.date_time BETWEEN '2019-05-01 06:00' AND '2019-06-01 05:59:59'
	)
	,
	client_ships AS (
		SELECT
			sum(t.cost_concrete) AS cost_concrete,
			sum(t.cost_shipment) AS cost_shipment
		FROM shipments_for_client_veh_owner_list t
		WHERE	
			t.vehicle_owner_id = 156
			AND t.ship_date BETWEEN '2019-05-01 06:00' AND '2019-06-01 05:59:59'
	)
SELECT
	(SELECT coalesce(cost,0) FROM ships) AS ship_cost,
	(SELECT coalesce(cost_for_driver,0) FROM ships) AS ship_for_driver_cost,
	(SELECT coalesce(demurrage_cost,0) FROM ships) AS ship_demurrage_cost,
	(SELECT coalesce(cost,0) FROM pumps) AS pumps_cost,
	(SELECT coalesce(cost_concrete,0) FROM client_ships) AS client_ships_concrete_cost,
	(SELECT coalesce(cost_shipment,0) FROM client_ships) AS client_ships_shipment_cost
