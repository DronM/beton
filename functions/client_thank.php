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

/*****  Благодарность клиентам ******* */
$dbLink->query(
	"INSERT INTO sms_for_sending
	(tel, body, sms_type)
	(SELECT
			t.phone_cel,
			t.message,
			'client_thank'::sms_types
		FROM sms_client_thank t
		WHERE t.shift = get_shift_start(now()::timestamp-'1 day'::interval)
	)"
);

?>
