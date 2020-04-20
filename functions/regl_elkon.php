<?php
require_once('db_con.php');
require_once(USER_CONTROLLERS_PATH.'Production_Controller.php');

//При ошибке все залогится куда надо...
$dbLink->reportError = TRUE;
$contr = new Production_Controller($dbLink);
$contr->check_data(NULL);

?>
