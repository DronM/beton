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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class SMSForSending_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("sms_for_sending");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field tel ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="tel";
						
		$f_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel",$f_opts);
		$this->addField($f_tel);
		//********************
		
		//*** Field body ***
		$f_opts = array();
		$f_opts['id']="body";
						
		$f_body=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"body",$f_opts);
		$this->addField($f_body);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['defaultValue']='current_timestamp';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field sent ***
		$f_opts = array();
		$f_opts['defaultValue']='false';
		$f_opts['id']="sent";
						
		$f_sent=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sent",$f_opts);
		$this->addField($f_sent);
		//********************
		
		//*** Field sent_date_time ***
		$f_opts = array();
		$f_opts['id']="sent_date_time";
						
		$f_sent_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sent_date_time",$f_opts);
		$this->addField($f_sent_date_time);
		//********************
		
		//*** Field delivered ***
		$f_opts = array();
		$f_opts['defaultValue']='false';
		$f_opts['id']="delivered";
						
		$f_delivered=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"delivered",$f_opts);
		$this->addField($f_delivered);
		//********************
		
		//*** Field delivered_date_time ***
		$f_opts = array();
		$f_opts['id']="delivered_date_time";
						
		$f_delivered_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"delivered_date_time",$f_opts);
		$this->addField($f_delivered_date_time);
		//********************
		
		//*** Field sms_type ***
		$f_opts = array();
		$f_opts['id']="sms_type";
						
		$f_sms_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sms_type",$f_opts);
		$this->addField($f_sms_type);
		//********************
		
		//*** Field sms_id ***
		$f_opts = array();
		$f_opts['id']="sms_id";
						
		$f_sms_id=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sms_id",$f_opts);
		$this->addField($f_sms_id);
		//********************
		
		//*** Field doc_ref ***
		$f_opts = array();
		$f_opts['id']="doc_ref";
						
		$f_doc_ref=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_ref",$f_opts);
		$this->addField($f_doc_ref);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
