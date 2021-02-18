<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class SMSPattern_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("sms_patterns");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field lang_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = FALSE;
		$f_opts['autoInc']=FALSE;
		
		$f_opts['alias']='Язык';
		$f_opts['id']="lang_id";
						
		$f_lang_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"lang_id",$f_opts);
		$this->addField($f_lang_id);
		//********************
		
		//*** Field sms_type ***
		$f_opts = array();
		$f_opts['primaryKey'] = FALSE;
		$f_opts['autoInc']=FALSE;
		
		$f_opts['alias']='Тип SMS';
		$f_opts['id']="sms_type";
						
		$f_sms_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sms_type",$f_opts);
		$this->addField($f_sms_type);
		//********************
		
		//*** Field pattern ***
		$f_opts = array();
		
		$f_opts['alias']='Шаблон';
		$f_opts['id']="pattern";
						
		$f_pattern=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pattern",$f_opts);
		$this->addField($f_pattern);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_id,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
