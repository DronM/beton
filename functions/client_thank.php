<?php
require_once('db_con.php');

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
		AND NOT EXISTS (
			SELECT old_sms.tel
			FROM sms_for_sending AS old_sms
			WHERE old_sms.tel=t.phone_cel
				AND old_sms.sms_type='client_thank'::sms_types
				AND old_sms.date_time>=now()-'1 month'::interval
				AND old_sms.sent
			)
	)"
);

?>
