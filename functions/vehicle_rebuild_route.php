<?php

//require_once(dirname(__FILE__).'/../Config.php');
require_once(dirname(__FILE__).'/db_con.php');
require_once(dirname(__FILE__).'/VehicleRoute.php');

if (count($argv)<3){
	die("Arguments: tracker_id, shipment_id, vehicle_state");
}
$tracker_id = $argv[1];
$shipment_id = $argv[2];
$vehicle_state = $argv[3]; 

file_put_contents(
	OUTPUT_PATH.'veh_reb_route.txt'
	,sprintf(
		date('d/m/y H:i:s').' tracker_id=%s, shipment_id=%d, vehicle_state=%s'.PHP_EOL
		,$tracker_id,$shipment_id,$vehicle_state
	)
	,FILE_APPEND
);

VehicleRoute::rebuildRoute($tracker_id,$shipment_id,$vehicle_state,$dbLink);
//event for browser redrawing
$dbLink->query(sprintf(
	"SELECT
		pg_notify('Vehicle.route_redraw.".$tracker_id."'
			,json_build_object(
				'params',json_build_object(								
					'tracker_id', '%s'
					,'shipment_id', %d
					,'vehicle_state', '%s'
				)
			)::text
		
		)"
	,$tracker_id,$shipment_id,$vehicle_state
));

?>
