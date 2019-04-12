<?php
require_once(dirname(__FILE__).'/../Config.php');
require_once(FRAME_WORK_PATH.'db/db_pgsql.php');

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

/*****  НАПОМИНАНИЕ О СЕГОДНЯШНИХ ЗАКАЗАХ ДЛЯ НАСОСОВ******* */
$dbLink->query(
	"INSERT INTO sms_for_sending
	(tel, body, sms_type)
	(SELECT
		t.phone_cel,
		string_agg(t.message,',') AS message,
		'remind_for_pump'::sms_types
	FROM sms_pump_remind t
	WHERE
		t.date_time BETWEEN get_shift_start(now()::timestamp) AND get_shift_end(get_shift_start(now()::timestamp))
	GROUP BY t.phone_cel	
	)"
);

?>
