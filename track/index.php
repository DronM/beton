<?php

require_once('../Config.php');
require_once(FUNC_PATH.'db_con.php');
require_once(FUNC_PATH.'VehicleRoute.php');

//helper functions
function show_not_fond(){
	//echo not found page
	echo '<h4>Неверные параметры запроса.</h4>';
	header("HTTP/1.0 404 Not Found");
}

function add_model($conn,$queryStr,&$resAr){
	$q_id = $conn->query($queryStr);
	while($ar = $conn->fetch_array($q_id)){
		$row = array();
		foreach($ar as $k=>$v){
			$row[$k] = $v;
		}
		array_push($resAr,$row);
	}
}

$sh_id = $_SERVER['QUERY_STRING'];
if(!ctype_digit($sh_id)){
	show_not_fond();
	return;
}

try{
	//check for shipment
	$ar = $dbLink->query_first(sprintf(
		"SELECT
			(now()-sh.ship_date_time)<'24 hours' AS sh_exists
			,sch.vehicle_id
		FROM shipments AS sh
		LEFT JOIN vehicle_schedules AS sch ON sch.id=sh.vehicle_schedule_id
		WHERE sh.id=%d"
		,$sh_id
	));

	if(!$ar || !count($ar) || $ar['sh_exists']!='t'){
		show_not_fond();
		return;
	}

	//response structure
	$res = array(
		'ZoneList_Model' => array()
		,'VehicleLastPos_Model' => array()
		,'Route_Model' => array()
	);
	
	//zones
	$zone_q = VehicleRoute::getZoneListQuery($ar['vehicle_id']);
	add_model($dbLink,$zone_q,$res['ZoneList_Model']);
	
	//last position
	$last_pos_q = VehicleRoute::getLastPosQuery($ar['vehicle_id']);
	add_model($dbLink,$last_pos_q,$res['VehicleLastPos_Model']);

	//route
	/*$route = VehicleRoute::getRoute($vehicleId,$dbLink);
	if($route){
		$res['Route_Model']['route'] = $route;
	}*/
	
	//to client
	header('Content-Type: application/json');
	echo json_encode($res);
}
catch(Exception $e){
	echo '<h4>Внутренняя ошибка на сервере.</h4>';
	header("HTTP/1.0 500 Internal Server Error");
}
?>
