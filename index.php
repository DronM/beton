<?php
header('Access-Control-Allow-Origin: *');
require_once('Config.php');
if (isset($_REQUEST['sid'])){
	session_id($_REQUEST['sid']);
}
require_once(FRAME_WORK_PATH.'cmd.php');
?>
