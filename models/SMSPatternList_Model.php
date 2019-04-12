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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class SMSPatternList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("sms_patterns_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field sms_type ***
		$f_opts = array();
		$f_opts['id']="sms_type";
				
		$f_sms_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sms_type",$f_opts);
		$this->addField($f_sms_type);
		//********************
		
		//*** Field langs_ref ***
		$f_opts = array();
		$f_opts['id']="langs_ref";
				
		$f_langs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"langs_ref",$f_opts);
		$this->addField($f_langs_ref);
		//********************
		
		//*** Field pattern ***
		$f_opts = array();
		$f_opts['id']="pattern";
				
		$f_pattern=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pattern",$f_opts);
		$this->addField($f_pattern);
		//********************
		
		//*** Field user_list ***
		$f_opts = array();
		$f_opts['id']="user_list";
				
		$f_user_list=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_list",$f_opts);
		$this->addField($f_user_list);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
