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
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInterval.php');
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
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	public function call($pm){
		if(!defined('AST_SERVER')||!defined('AST_PORT')||!defined('AST_USER')||!defined('AST_PASSWORD') ){
			throw new Exception('Нет настроек телефонии!');
		}
	
		$ext = $_SESSION['tel_ext'];
		$tel = $this->getExtVal($pm,'tel');
		
		$caller = new Caller(AST_SERVER,AST_PORT,AST_USER,AST_PASSWORD);
		$caller->call($ext,$tel);	
	}

}
?>