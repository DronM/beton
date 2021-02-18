<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class SMSPatternUserPhoneList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("sms_pattern_user_phones_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field sms_pattern_id ***
		$f_opts = array();
		$f_opts['id']="sms_pattern_id";
						
		$f_sms_pattern_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sms_pattern_id",$f_opts);
		$this->addField($f_sms_pattern_id);
		//********************
		
		//*** Field users_ref ***
		$f_opts = array();
		$f_opts['id']="users_ref";
						
		$f_users_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"users_ref",$f_opts);
		$this->addField($f_users_ref);
		//********************
		
		//*** Field user_tel ***
		$f_opts = array();
		$f_opts['id']="user_tel";
						
		$f_user_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_tel",$f_opts);
		$this->addField($f_user_tel);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
