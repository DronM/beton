<?php
require_once(__DIR__.'/../Config.php');
require_once(FRAME_WORK_PATH.'db/db_pgsql.php');
require_once("common/SMSService.php");

define('PHONES_FOR_BALANCE','79123971822,79044909590,79044900909');

$dbLink = new DB_Sql();
$dbLink->appname = APP_NAME;
$dbLink->technicalemail = TECH_EMAIL;
$dbLink->detailedError = defined('DETAILED_ERROR')? DETAILED_ERROR:DEBUG;

/*conneсtion*/
$dbLink->server		= DB_SERVER_MASTER;
$dbLink->user		= DB_USER;
$dbLink->password	= DB_PASSWORD;
$dbLink->database	= DB_NAME;
$dbLink->connect(DB_SERVER_MASTER, DB_USER, DB_PASSWORD);

/*****  ОТПРАВКА SMS С ОСТАТКАМИ МАТЕРИАЛОВ ******* */
$dbLink->query(
	"INSERT INTO sms_for_sending
	(tel, body, sms_type)
	(WITH
	mat_bal AS (SELECT string_agg(mat||'='||quant,',') AS v FROM mat_balance_for_sms)
	SELECT 
		us.phone_cel,
		sms_templates_text(
			ARRAY[
				ROW('materials',(SELECT mat_bal.v::text FROM mat_bal))::template_value
			],
			(SELECT pattern FROM sms_patterns WHERE sms_type='material_balance')
		) AS body,
		'material_balance'

	FROM sms_pattern_user_phones AS u
	LEFT JOIN sms_patterns AS p ON p.id=u.sms_pattern_id
	LEFT JOIN users AS us ON us.id=u.user_id
	WHERE p.sms_type='material_balance'
	)"
);


/*****  ФОРМИРОВАНИЕ ЗАКАЗОВ ПОСТАВЩИКАМ ******* */
$dbLink->query('SELECT sup_make_orders()');


/*****  ОТПРАВКА SMS С ЗАКАЗАМИ ПОСТАВЩИКАМ ******* */
$sms = new SMSService(SMS_LOGIN,SMS_PWD);
$id = $dbLink->query("SELECT * FROM sup_orders_for_sms");
while ($ar=$dbLink->fetch_array($id)){
	/*
	echo 'SMS t='.$ar['mes_text'].' tel='.$ar['tel'].'
	';
	*/
	$sms_id = $sms->send($ar['tel'],
			$ar['mes_text'],
			SMS_SIGN
	);
	
	$sms2_id='';
	if (!$sms_id&&$ar['tel2']){
		$sms2_id = $sms->send($ar['tel2'],
				$ar['mes_text'],
				SMS_SIGN
		);		
	}
	
	$dbLink->query(sprintf(
	"UPDATE supplier_orders
	SET sms_id='%s',sms2_id='%s'
	WHERE date=(now()::date+'1 day'::interval)::date
		AND supplier_id=%d
		AND material_id=%d
	",
	$sms_id,
	$sms2_id,
	$ar['supplier_id'],
	$ar['material_id']
	));
}

/*****  ОТПРАВКА ЕДИНОГО SMS С ЗАКАЗАМИ МАТЕРИАЛОВ ******* */
$dbLink->query(
	"INSERT INTO sms_for_sending
	(tel, body, sms_type)
	(WITH
	mat_totals AS (
		SELECT string_agg(q.mat||'='||q.quant,',') AS v
		FROM
		(SELECT
			concrete_short_name(material_descr::text) AS mat,
			sum(quant) AS quant
		FROM sup_orders_for_sms
		GROUP BY material_descr
		) AS q		
	)
	SELECT 
		us.phone_cel,
		(SELECT mat_totals.v FROM mat_totals) AS body,
		'material_balance'

	FROM sms_pattern_user_phones AS u
	LEFT JOIN sms_patterns AS p ON p.id=u.sms_pattern_id
	LEFT JOIN users AS us ON us.id=u.user_id
	WHERE p.sms_type='material_balance' AND (SELECT mat_totals.v FROM mat_totals) IS NOT NULL
	)"
);

?>
