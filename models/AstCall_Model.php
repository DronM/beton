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
 
class AstCall_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("ast_calls");
			
		//*** Field unique_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="unique_id";
						
		$f_unique_id=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unique_id",$f_opts);
		$this->addField($f_unique_id);
		//********************
		
		//*** Field caller_id_num ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="caller_id_num";
						
		$f_caller_id_num=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"caller_id_num",$f_opts);
		$this->addField($f_caller_id_num);
		//********************
		
		//*** Field ext ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="ext";
						
		$f_ext=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ext",$f_opts);
		$this->addField($f_ext);
		//********************
		
		//*** Field start_time ***
		$f_opts = array();
		$f_opts['id']="start_time";
						
		$f_start_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"start_time",$f_opts);
		$this->addField($f_start_time);
		//********************
		
		//*** Field end_time ***
		$f_opts = array();
		$f_opts['id']="end_time";
						
		$f_end_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"end_time",$f_opts);
		$this->addField($f_end_time);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		$f_opts['id']="client_id";
						
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field call_type ***
		$f_opts = array();
		$f_opts['id']="call_type";
						
		$f_call_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"call_type",$f_opts);
		$this->addField($f_call_type);
		//********************
		
		//*** Field user_id_to ***
		$f_opts = array();
		$f_opts['id']="user_id_to";
						
		$f_user_id_to=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id_to",$f_opts);
		$this->addField($f_user_id_to);
		//********************
		
		//*** Field answer_unique_id ***
		$f_opts = array();
		$f_opts['id']="answer_unique_id";
						
		$f_answer_unique_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"answer_unique_id",$f_opts);
		$this->addField($f_answer_unique_id);
		//********************
		
		//*** Field dt ***
		$f_opts = array();
		$f_opts['id']="dt";
						
		$f_dt=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt",$f_opts);
		$this->addField($f_dt);
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
		
		//*** Field create_date ***
		$f_opts = array();
		$f_opts['id']="create_date";
						
		$f_create_date=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"create_date",$f_opts);
		$this->addField($f_create_date);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
