<?php

require_once(FRAME_WORK_PATH.'basic_classes/EventSrv.php');

class BetonEventSrv extends EventSrv {
	
	public static function publish($eventId,&$eventParams){
		parent::publish($eventId,$eventParams,'Beton',EVENT_SERVER_URL);
	}
}
