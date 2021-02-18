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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class AstCallCurrent_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("ast_calls_current");
			
		//*** Field unique_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="unique_id";
						
		$f_unique_id=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unique_id",$f_opts);
		$this->addField($f_unique_id);
		//********************
		
		//*** Field ext ***
		$f_opts = array();
		$f_opts['id']="ext";
						
		$f_ext=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ext",$f_opts);
		$this->addField($f_ext);
		//********************
		
		//*** Field contact_tel ***
		$f_opts = array();
		$f_opts['id']="contact_tel";
						
		$f_contact_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contact_tel",$f_opts);
		$this->addField($f_contact_tel);
		//********************
		
		//*** Field ring_time ***
		$f_opts = array();
		$f_opts['id']="ring_time";
						
		$f_ring_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ring_time",$f_opts);
		$this->addField($f_ring_time);
		//********************
		
		//*** Field answer_time ***
		$f_opts = array();
		$f_opts['id']="answer_time";
						
		$f_answer_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"answer_time",$f_opts);
		$this->addField($f_answer_time);
		//********************
		
		//*** Field hangup_time ***
		$f_opts = array();
		$f_opts['id']="hangup_time";
						
		$f_hangup_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"hangup_time",$f_opts);
		$this->addField($f_hangup_time);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		$f_opts['id']="client_id";
						
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field clients_ref ***
		$f_opts = array();
		$f_opts['id']="clients_ref";
						
		$f_clients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"clients_ref",$f_opts);
		$this->addField($f_clients_ref);
		//********************
		
		//*** Field client_kind ***
		$f_opts = array();
		$f_opts['id']="client_kind";
						
		$f_client_kind=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_kind",$f_opts);
		$this->addField($f_client_kind);
		//********************
		
		//*** Field manager_comment ***
		$f_opts = array();
		$f_opts['id']="manager_comment";
						
		$f_manager_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"manager_comment",$f_opts);
		$this->addField($f_manager_comment);
		//********************
		
		//*** Field informed ***
		$f_opts = array();
		$f_opts['id']="informed";
						
		$f_informed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"informed",$f_opts);
		$this->addField($f_informed);
		//********************
		
		//*** Field contact_name ***
		$f_opts = array();
		$f_opts['id']="contact_name";
						
		$f_contact_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"contact_name",$f_opts);
		$this->addField($f_contact_name);
		//********************
		
		//*** Field debt ***
		$f_opts = array();
		$f_opts['id']="debt";
						
		$f_debt=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"debt",$f_opts);
		$this->addField($f_debt);
		//********************
		
		//*** Field client_manager_descr ***
		$f_opts = array();
		$f_opts['id']="client_manager_descr";
						
		$f_client_manager_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_manager_descr",$f_opts);
		$this->addField($f_client_manager_descr);
		//********************
		
		//*** Field client_types_ref ***
		$f_opts = array();
		$f_opts['id']="client_types_ref";
						
		$f_client_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_types_ref",$f_opts);
		$this->addField($f_client_types_ref);
		//********************
		
		//*** Field client_come_from_ref ***
		$f_opts = array();
		$f_opts['id']="client_come_from_ref";
						
		$f_client_come_from_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_come_from_ref",$f_opts);
		$this->addField($f_client_come_from_ref);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
