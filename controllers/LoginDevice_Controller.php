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
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtArray.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



require_once(USER_CONTROLLERS_PATH.'User_Controller.php');

class LoginDevice_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			
		/* get_list */
		$pm = new PublicMethod('get_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);
		
		$this->setListModelId('LoginDeviceList_Model');
		
			
		$pm = new PublicMethod('switch_banned');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtBool('banned',$opts));
	
				
	$opts=array();
	
		$opts['length']=32;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('hash',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('user_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public function switch_banned($pm){
		$conn = $this->getDbLinkMaster();
		if ($pm->getParamValue('banned')=='1'){
			try{
				$ar = $conn->query_first(sprintf(
					"SELECT
						session_id
						,pub_key
					FROM logins
					WHERE user_id=%d
					AND md5(headers_j->>'User-Agent')=%s
					AND date_time_out IS NULL"
					,$this->getExtDbVal($pm,'user_id')
					,$this->getExtDbVal($pm,'hash')
				));
				
				if(is_array($ar) && count($ar) && isset($ar['session_id'])){
					$conn->query('BEGIN');
					//kill session
					$conn->query(sprintf(
						"DELETE FROM sessions WHERE id='%s'"
						,$ar['session_id']
					));
					
					$conn->query(sprintf(
						"INSERT INTO login_device_bans (user_id,hash) VALUES (%d,%s)"
						,$this->getExtDbVal($pm,'user_id')
						,$this->getExtDbVal($pm,'hash')
					));
					
					$conn->query('COMMIT');
					
					//Send event!!!
					//deleted from logins after delete!!!
					//User_Controller::closeConnection($conn,trim($ar['pub_key']));
				}
			}
			catch(Exception $e){
				$conn->query('ROLLBACK');
				throw new Exception($e);
			}			
		}
		else{
			$conn->query(sprintf(
				"DELETE FROM login_device_bans
				WHERE user_id=%d AND hash=%s"
				,$this->getExtDbVal($pm,'user_id')
				,$this->getExtDbVal($pm,'hash')
			));
		}
	}


}
?>