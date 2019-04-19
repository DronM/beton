<?php
header('Access-Control-Allow-Origin: *');
require_once('Config.php');

if (isset($_REQUEST['sid'])){
	session_id($_REQUEST['sid']);
}
else if (strlen($_SERVER['QUERY_STRING'])&&substr($_SERVER['QUERY_STRING'],0,3)=='sid'){	
	session_id(substr($_SERVER['QUERY_STRING'],3));
}
require_once(FRAME_WORK_PATH.'cmd.php');
?>
