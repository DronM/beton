<?php

require_once(dirname(__FILE__).'/../Config.php');
require_once(FRAME_WORK_PATH.'basic_classes/EventSrv.php');

class BetonEventSrv extends EventSrv {
	
	public static function publish($eventId,$eventParams, $appId=NULL, $serverHost=NULL, $serverPort=NULL,$ssl=NULL){
		parent::publish($eventId,$eventParams,APP_NAME,APP_SERVER_HOST,APP_SERVER_PORT,APP_SERVER_SECURED);
	}
	
	public static function publishAsync($eventId,$eventParams, $appId=NULL, $serverHost=NULL, $serverPort=NULL,$ssl=NULL){
		parent::publishAsync($eventId,$eventParams,APP_NAME,APP_SERVER_HOST,APP_SERVER_PORT,APP_SERVER_SECURED);
	}
	
}
