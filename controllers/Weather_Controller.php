<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once('common/WeatherForeca.php');

class Weather_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			
		$pm = new PublicMethod('get_current');
		
		$this->addPublicMethod($pm);

		
	}	
	

	public static function update_data($dbLink,&$content,&$contentDetails,&$updateDate){
		$w = new WeatherForeca();
		$w->getForcast();
		
		$content = 'NULL';
		FieldSQLString::formatForDb($dbLink,$w->getContent(),$content);
		$contentDetails = 'NULL';
		FieldSQLString::formatForDb($dbLink,$w->getContentDetails(),$contentDetails);
		
		$dbLink->query("BEGIN");
		try{
			$ar = $dbLink->query_first(sprintf(
			"SELECT weather_update(%s,%s)",
			$content,
			$contentDetails
			));
			
			$dbLink->query("COMMIT");
			
			$updateDate = $ar['weather_update'];
		}
		catch (Exception $e) {
			$dbLink->query("ROLLBACK");
			throw $e;
		}
	}

	public static function getCurrentModel($dbLink,$dbLinkMaster){
		$ar = $dbLink->query_first(
		"SELECT
			weather.*,
			(round(date_part('epoch',now()::timestamp-weather.update_dt))>=EXTRACT(epoch FROM const_weather_update_interval_sec_val()::interval)) AS need_update
		FROM weather
		LIMIT 1");
		
		$content = '';
		$content_details = '';
		$update_dt = '';
		if(!is_array($ar) || !count($ar) || $ar['need_update']=='t'){
			self::update_data($dbLinkMaster,$content,$content_details,$update_dt);
		}
		else{
			$content = $ar['content'];
			$content_details = $ar['content_details'];
			$update_dt = $ar['update_dt'];
		}
		
		$fields = array();		
		array_push($fields,new Field('content',DT_STRING,array('value'=>$content)));
		array_push($fields,new Field('content_details',DT_STRING,array('value'=>$content_details)));
		array_push($fields,new Field('update_dt',DT_STRING,array('value'=>$update_dt)));				
		
		return new ModelVars(array('id'=>'Weather_Model','values'=>$fields));		
	}
	
	public function get_current($pm){
		$this->addModel(self::getCurrentModel($this->getDbLink(),$this->getDbLinkMaster()));
	}


}
?>