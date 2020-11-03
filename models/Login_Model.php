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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class Login_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("logins");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date_time_in ***
		$f_opts = array();
		$f_opts['id']="date_time_in";
						
		$f_date_time_in=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time_in",$f_opts);
		$this->addField($f_date_time_in);
		//********************
		
		//*** Field date_time_out ***
		$f_opts = array();
		$f_opts['id']="date_time_out";
						
		$f_date_time_out=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time_out",$f_opts);
		$this->addField($f_date_time_out);
		//********************
		
		//*** Field ip ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="ip";
						
		$f_ip=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ip",$f_opts);
		$this->addField($f_ip);
		//********************
		
		//*** Field session_id ***
		$f_opts = array();
		$f_opts['length']=128;
		$f_opts['id']="session_id";
						
		$f_session_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"session_id",$f_opts);
		$this->addField($f_session_id);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field pub_key ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="pub_key";
						
		$f_pub_key=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pub_key",$f_opts);
		$this->addField($f_pub_key);
		//********************
		
		//*** Field set_date_time ***
		$f_opts = array();
		$f_opts['id']="set_date_time";
						
		$f_set_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"set_date_time",$f_opts);
		$this->addField($f_set_date_time);
		//********************
		
		//*** Field headers ***
		$f_opts = array();
		$f_opts['id']="headers";
						
		$f_headers=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"headers",$f_opts);
		$this->addField($f_headers);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
