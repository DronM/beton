<?php
require_once("db_con.php");
require_once("common/SMSService.php");

if (SMS_ACTIVE){
	$sms = new SMSService(SMS_LOGIN,SMS_PWD);
	$id = $dbLink->query(
	"SELECT
		id,tel,body
	FROM sms_for_sending
	WHERE sent=FALSE");
	while ($ar=$dbLink->fetch_array($id)){
		try{
			$sms_id = $sms->send($ar['tel'],$ar['body'],SMS_SIGN,SMS_TEST);
			$dbLink->query(sprintf(
			"UPDATE sms_for_sending
				SET sent=TRUE,
					sms_id='%s',
					sent_date_time=now()::timestamp
			WHERE id=%d",
			$sms_id,$ar['id']));			
		}
		catch(Exception $e){
		}
	}
	
	//отметки
	$id = $dbLink->query(
	"SELECT
		id,sms_id
	FROM sms_for_sending
	WHERE sent=TRUE AND delivered=FALSE");
	
	while ($ar=$dbLink->fetch_array($id)){
		try{
			if ($sms->get_delivered($ar['sms_id'])){
				$dbLink->query(sprintf(
				"UPDATE sms_for_sending
					SET delivered=TRUE,
						delivered_date_time=now()::timestamp
				WHERE id=%d",
				$ar['id']));
			}
		}
		catch(Exception $e){
		}
	}
}

?>