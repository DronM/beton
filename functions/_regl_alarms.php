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

/*****  НЕРАБОТАЮЩИЕ ТРЕКЕРЫ ******* */
$dbLink->query(
	"INSERT INTO sms_for_sending
	(tel, body, sms_type)
	(WITH
	v_list AS (SELECT
		plates.v	
		FROM
		(SELECT
		
			string_agg(t.plate,',') v
		FROM car_tracking_malfunctions t
		) AS plates
		WHERE plates.v IS NOT NULL
	)
	SELECT 
		us.phone_cel,
		sms_templates_text(
			ARRAY[
				ROW('vehicles',(SELECT v_list.v::text FROM v_list))::template_value
			],
			(SELECT pattern FROM sms_patterns WHERE sms_type='vehicle_tracker_malfunction')
		) AS body,
		'vehicle_tracker_malfunction'	
	FROM sms_pattern_user_phones AS u
	LEFT JOIN sms_patterns AS p ON p.id=u.sms_pattern_id
	LEFT JOIN users AS us ON us.id=u.user_id
	WHERE p.sms_type='vehicle_tracker_malfunction' AND (SELECT v_list.v FROM v_list) IS NOT NULL
	)"
);


/*****  Низкая эффективность ******* */
$dbLink->query(
	"INSERT INTO sms_for_sending
	(tel, body, sms_type)
	(WITH
	effic_alarm AS (SELECT ROUND(quant_shipped_before_now - quant_ordered_before_now,2) AS v FROM efficiency_view)
	SELECT 
		us.phone_cel,
		sms_templates_text(
			ARRAY[
				ROW('efficiency',(SELECT effic_alarm.v::text FROM effic_alarm))::template_value
			],
			(SELECT pattern FROM sms_patterns WHERE sms_type='efficiency_warn')
		) AS body,
		'efficiency_warn'
	FROM sms_pattern_user_phones AS u
	LEFT JOIN sms_patterns AS p ON p.id=u.sms_pattern_id
	LEFT JOIN users AS us ON us.id=u.user_id
	WHERE p.sms_type='efficiency_warn' AND (SELECT effic_alarm.v FROM effic_alarm)<=const_efficiency_warn_k_val()
	)"
);

?>
