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


require_once 'common/Caller.php';
require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');

class Caller_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			
		$pm = new PublicMethod('call');
		
				
	$opts=array();
	
		$opts['length']=15;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('tel',$opts));
	
				
	$opts=array();
	
		$opts['length']=5;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('ext',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public function call($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
		$ext = str_replace("'","",$params->getParamById('ext'));
		$tel = str_replace("'","",$params->getParamById('tel'));
		$caller = new Caller(AST_SERVER,AST_PORT,AST_USER,AST_PASSWORD);
		$caller->call($ext,$tel);	
	}

}
?>