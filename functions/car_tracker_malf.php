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

$sms = new SMSService(SMS_LOGIN,SMS_PWD);

/*****  НЕРАБОТАЮЩИЕ ТРЭКЕРЫ ******* */
$dbLink->query(
	"INSERT INTO sms_for_sending
	(tel, body, sms_type)
	(WITH tracker_list AS (SELECT string_agg(plate,',') AS v FROM car_tracking_malfunctions)
	SELECT
		rows.fields->'fields'->>'tel' AS tel,
		'Нет данных от '||(SELECT v FROM tracker_list) AS body,
		'vehicle_tracker_malfunction'::sms_types
	FROM(
		SELECT json_array_elements(const_tracker_malfunction_tel_list_val()->'rows') AS fields
	) AS rows
	WHERE length((SELECT v FROM tracker_list))>0	
	)"
);

/*****  ЭФФЕКТИВНОСТЬ" ******* */

$dbLink->query(
	"WITH efficiency AS (
		SELECT
			ROUND(quant_shipped_before_now - quant_ordered_before_now,2) AS v
		FROM efficiency_view	
	)
	SELECT
		rows.fields->'fields'->>'tel' AS tel,
		'Состояние: '||(SELECT v FROM efficiency) AS body,
		'efficiency_warn'::sms_types
	FROM(
		SELECT json_array_elements(const_low_efficiency_tel_list_val()->'rows') AS fields
	) AS rows
	WHERE (SELECT v FROM efficiency)<=const_efficiency_warn_k_val()"
);

?>
