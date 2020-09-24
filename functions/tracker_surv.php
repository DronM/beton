<?php
require_once(dirname(__FILE__).'/../Config.php');
require_once(FRAME_WORK_PATH.'db/db_pgsql.php');
require_once("common/SMSService.php");

$dbLink = new DB_Sql();
$dbLink->appname = APP_NAME;
$dbLink->technicalemail = TECH_EMAIL;
$dbLink->reporterror = DEBUG;

/*conneсtion*/
$dbLink->server		= DB_SERVER_MASTER;
$dbLink->user		= DB_USER;
$dbLink->password	= DB_PASSWORD;
$dbLink->database	= DB_NAME;
$dbLink->connect(DB_SERVER_MASTER, DB_USER, DB_PASSWORD);

/*****  НЕРАБОТАЮЩИЕ ТРЭКЕРЫ ******* */
$ar = $dbLink->query_first(
	"SELECT (now()-(recieved_dt+'5 hours'::interval)) > '10 minutes' AS no_data
	FROM car_tracking
	ORDER BY recieved_dt DESC
	LIMIT 1"
);
if(is_array($ar) && count($ar) && $ar['no_data']!='f'){
	//no data!!!
	exec('/home/andrey/tracking_pg/gpsmon_beton_master stop');
	sleep(3);
	exec('/home/andrey/tracking_pg/gpsmon_beton_master start');
	sleep(3);
	exec('/home/andrey/tracking_pg/gpsmon_master start');
	file_put_contents('/home/andrey/tracker_surv.log',date('y-m-d H:i:s').'No data.. restarted!'.PHP_EOL,FILE_APPEND);
}
?>
