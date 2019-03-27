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
 
class SMSPatternList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("sms_patterns_list_view");
			
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
		
		//*** Field sms_type_descr ***
		$f_opts = array();
		$f_opts['id']="sms_type_descr";
				
		$f_sms_type_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sms_type_descr",$f_opts);
		$this->addField($f_sms_type_descr);
		//********************
		
		//*** Field lang_descr ***
		$f_opts = array();
		$f_opts['id']="lang_descr";
				
		$f_lang_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"lang_descr",$f_opts);
		$this->addField($f_lang_descr);
		//********************
		
		//*** Field lang_id ***
		$f_opts = array();
		$f_opts['id']="lang_id";
				
		$f_lang_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"lang_id",$f_opts);
		$this->addField($f_lang_id);
		//********************
		
		//*** Field pattern ***
		$f_opts = array();
		$f_opts['id']="pattern";
				
		$f_pattern=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pattern",$f_opts);
		$this->addField($f_pattern);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
