<?php

require_once('common/decodePolylineToArray.php');
require_once('common/OSRMV5.php');

class VehicleRoute {
	
	const ER_OSRM_ROUTE_QUERY = 'Ошибка получения данных с сервера OSRM!';
	
	public static function getSessCond(){
		$cond = '';
		if (isset($_SESSION) && isset($_SESSION['role_id']) && isset($_SESSION['global_vehicle_owner_id'])){
			$cond = ($_SESSION['role_id']=='vehicle_owner')? sprintf(' AND vs.vehicle_id IN (SELECT vv.id FROM vehicles vv WHERE vv.id=%d)',$_SESSION['global_vehicle_owner_id']):'';
		}
		return $cond;
	}

	public static function getZoneListQuery($vehicleId){
			
		$cond = self::getSessCond();
			
		return sprintf("SELECT 
				(SELECT replace(replace(st_astext(d.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text)
				FROM destinations AS d
				WHERE d.id=constant_base_geo_zone_id()
				) AS base_zone,	
				
				CASE 		
				WHEN st.state IN ('at_dest'::vehicle_states,'left_for_base'::vehicle_states) THEN
				(SELECT replace(replace(st_astext(d.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text)
					FROM destinations AS d
					WHERE d.id=st.destination_id
				)	
				
				WHEN st.state ='busy'::vehicle_states THEN
				(SELECT replace(replace(st_astext(d.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text)
					FROM destinations AS d
					LEFT JOIN shipments AS sh ON sh.id=st.shipment_id
					LEFT JOIN orders AS o ON o.id=sh.order_id
					WHERE d.id=o.destination_id
				)
				ELSE null
				END AS dest_zone
				
				FROM vehicle_schedule_states AS st
				LEFT JOIN vehicle_schedules AS vs ON vs.id=st.schedule_id
				WHERE vs.vehicle_id=%d AND st.date_time < now()".$cond."
				ORDER BY st.date_time DESC
				LIMIT 1"
			,$vehicleId		
		);
	
	}
	
	public static function getLastPosQuery($vehicleId){
		return sprintf(
			"SELECT * FROM vehicles_last_pos
			WHERE id=%d",
			$vehicleId
		);
	}
	
	public static function getRoute($vehicleId,$dbLink){
		/** Если текущий статус assigned/busy/left_for_dest - нужно вернуть предполагаемый маршрут до объекта
		 * Если текущий статус at_dest/left_for_base - нужно вернуть предполагаемый маршрут до базы
		 * Сначала проверить в кэше, проверить последние Х точек на соответствие маршруту, если надо - перестроить
		 * если нет маршрута в кэше- построить
		 * Ну и вернуть клиенту маршрут
		 *
		 *  const_deviation_for_reroute_val() points,distance_m
		 */
		
		$cond = self::getSessCond();
		 
		//Исходные данные, не только кэш... 
		$cashe_ar = $dbLink->query_first(sprintf(
			"WITH			
			--current vehicle state
			vh_st AS (
				SELECT
					st.state
					,st.shipment_id
					,CASE WHEN st.destination_id IS NOT NULL THEN st.destination_id ELSE
						(SELECT
							o.destination_id
						FROM orders AS o
						WHERE o.id=(SELECT sh.order_id FROM shipments AS sh WHERE sh.id=st.shipment_id)
						)
					END AS destination_id
					,vh.tracker_id
				FROM vehicle_schedule_states AS st
				LEFT JOIN vehicle_schedules AS vs ON vs.id=st.schedule_id
				LEFT JOIN vehicles AS vh ON vh.id=vs.vehicle_id
				WHERE vs.vehicle_id=%d AND st.date_time < now()".$cond."
				ORDER BY st.date_time DESC
				LIMIT 1				
			)
			
			--cashe data on current shipment
			,cashe_data AS (
				SELECT
					t.route
					,t.tracker_id
					,CASE
						WHEN route->'routes' IS NOT NULL AND jsonb_array_length(route->'routes')>=1 THEN route->'routes'->0->>'geometry'
						ELSE NULL
					END AS route_geom
				FROM vehicle_route_cashe AS t
				WHERE
					t.shipment_id=(SELECT shipment_id FROM vh_st)
					AND (
						(t.vehicle_state = 'left_for_dest' AND (SELECT state FROM vh_st) IN ('assigned','busy','left_for_dest') )
						OR 
						(t.vehicle_state = 'left_for_base' AND (SELECT state FROM vh_st) IN ('at_dest','left_for_base') )
					)
					AND t.tracker_id=(SELECT tracker_id FROM vh_st)			
			)
			
			--zone data: base or client destination zone based on state, near route coords if any, zone center
			,zone_data AS (
				SELECT
					dest.id
					,dest.near_road_lon
					,dest.near_road_lat
					,replace(replace(st_astext(st_centroid(dest.zone)), 'POINT('::text, ''::text), ')'::text, ''::text) AS zone_center_str
				FROM destinations AS dest
				WHERE dest.id=
					(CASE
						WHEN (SELECT state FROM vh_st) = 'left_for_base' THEN
							(SELECT const_base_geo_zone_id_val())
						ELSE (SELECT destination_id FROM vh_st) 	
					END	
					)					
			)

			--last X vehicle positions
			,veh_last_points AS (
				SELECT
					tr.lon
					,tr.lat
					,CASE
						WHEN (SELECT route FROM cashe_data) IS NULL THEN NULL
						ELSE
							ST_Buffer(
								ST_GeomFromText('POINT('||tr.lon::text||' '||tr.lat::text||')', 4326)
								,(SELECT (const_deviation_for_reroute_val()->>'distance_m')::int)
							)
					END AS pt_geom
				FROM car_tracking AS tr
				WHERE tr.car_id=(SELECT tracker_id FROM vh_st) AND tr.gps_valid = 1
				ORDER BY tr.period DESC
				LIMIT (const_deviation_for_reroute_val()->>'points_cnt')::int
			)
			
			SELECT
				CASE
					WHEN (SELECT route FROM cashe_data) IS NOT NULL
						AND (SELECT route_geom FROM cashe_data) IS NOT NULL THEN
						--last X points belongs to route?
						(SELECT
							bool_and(sub.pt_on_route) AS veh_on_route
						FROM (
							SELECT 
								st_contains(
									ST_LineFromEncodedPolyline((SELECT route_geom FROM cashe_data))
									,veh_last_points.pt_geom
								) AS pt_on_route
							FROM veh_last_points
						) AS sub
						)
					ELSE NULL
				END AS route_violated
				,(SELECT shipment_id FROM vh_st) AS shipment_id
				,(SELECT tracker_id FROM vh_st) AS tracker_id
				,(SELECT route FROM cashe_data) AS cashe_route
				,(SELECT state FROM vh_st) AS cur_state
				,(SELECT id FROM zone_data) AS zone_id
				,(SELECT near_road_lon FROM zone_data) AS zone_near_road_lon
				,(SELECT near_road_lat FROM zone_data) AS zone_near_road_lat
				,(SELECT zone_center_str FROM zone_data) AS zone_center_str
				,(SELECT 
					json_agg(
						json_build_object(
							'lon',veh_last_points.lon
							,'lat',veh_last_points.lat
						)
					) AS pos
				FROM veh_last_points	
				) AS cur_pos"
			,$vehicleId
		));
		
		$route = NULL;
		if(is_array($cashe_ar) && count($cashe_ar) && (!isset($cashe_ar['route']) || $cashe_ar['route_violated']=='t') ){
			//reroute 
			$osrm = new OSRMV5(OSRM_PROTOCOLE,OSRM_HOST,OSRM_PORT);
			
			//get near road coords
			if(!isset($cashe_ar['zone_near_road_lon']) || !isset($cashe_ar['zone_near_road_lat'])){
				//no near road, make it from szone center
				$z_coords = explode(' ',$cashe_ar['zone_center_str']);
				if(count($z_coords)==2){
					$lat_pos = $z_coords[1];
					$lon_pos = $z_coords[0];
					
					$cashe_ar['zone_near_road_lon'] = NULL;
					$cashe_ar['zone_near_road_lat'] = NULL;
					$osrm->getNearestRoadCoord(
						$lat_pos, $lon_pos,
						$cashe_ar['zone_near_road_lat'], $cashe_ar['zone_near_road_lon']
					);
					$dbLink->query(sprintf(
						"UPDATE destinations
						SET
							near_road_lon=%f
							,near_road_lat=%f
						WHERE id=%d"
						,$cashe_ar['zone_near_road_lon']
						,$cashe_ar['zone_near_road_lat']
						,$cashe_ar['zone_id']
					));
				}
			}
			$cur_pos = json_decode($cashe_ar['cur_pos']);
			if(is_array($cur_pos) && count($cur_pos)
			 &&isset($cashe_ar['zone_near_road_lon'])  && isset($cashe_ar['zone_near_road_lat'])
			){
				//routing
				$osrm_route = $osrm->getRoute(
					array(
						$cur_pos[0]->lon.','.$cur_pos[0]->lat
						,$cashe_ar['zone_near_road_lon'].','.$cashe_ar['zone_near_road_lat']					
					)
					,'json'
					,NULL
					,array("geometries=polyline")									
				);
				if (!$osrm_route->routes || !count($osrm_route->routes) || !$osrm_route->routes[0]->geometry){
					throw new Exception(self::ER_OSRM_ROUTE_QUERY);
				}
				
				//Convert to db geometry
				/*
				$q_points = '';
				$points = decodePolylineToArray($osrm_route->routes[0]->geometry);
				foreach($points as $p){
					$q_points.=($q_points=='')? '':',';
					$q_points.=sprintf("ST_PointFromText('POINT(%s %s)',4326)",$p[1],$p[0]);
				}
				*/
				$route = $osrm_route->routes[0]->geometry;
				$route_for_db = "'".json_encode($osrm_route)."'";
				
				//route to cashe
				$dbLink->query(sprintf(
					"INSERT INTO vehicle_route_cashe
					(tracker_id, shipment_id,vehicle_state,update_dt,route)
					values ('%s',%d,'%s',now(),%s)
					ON CONFLICT (tracker_id, shipment_id,vehicle_state) DO UPDATE SET
						update_dt = now()
						,route = %s"
					,$cashe_ar['tracker_id']
					,$cashe_ar['shipment_id']
					,($cashe_ar['cur_state']=='at_dest'||$cashe_ar['cur_state']=='left_for_base')? 'left_for_base':'left_for_dest'
					,$route_for_db
					,$route_for_db
				));
			}
		}
		else if (is_array($cashe_ar) && count($cashe_ar)){
			$route = $cashe_ar['route'];
		}
		
		return $route;
	}
}

?>
