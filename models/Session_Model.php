<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class Session_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("sessions");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['length']=128;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field set_time ***
		$f_opts = array();
		$f_opts['id']="set_time";
						
		$f_set_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"set_time",$f_opts);
		$this->addField($f_set_time);
		//********************
		
		//*** Field data ***
		$f_opts = array();
		$f_opts['id']="data";
						
		$f_data=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"data",$f_opts);
		$this->addField($f_data);
		//********************
		
		//*** Field session_key ***
		$f_opts = array();
		$f_opts['length']=128;
		$f_opts['id']="session_key";
						
		$f_session_key=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"session_key",$f_opts);
		$this->addField($f_session_key);
		//********************
		
		//*** Field pub_key ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="pub_key";
						
		$f_pub_key=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pub_key",$f_opts);
		$this->addField($f_pub_key);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
