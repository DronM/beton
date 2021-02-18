<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
 
class Weather_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("weather");
			
		//*** Field update_dt ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['id']="update_dt";
						
		$f_update_dt=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"update_dt",$f_opts);
		$this->addField($f_update_dt);
		//********************
		
		//*** Field content ***
		$f_opts = array();
		$f_opts['id']="content";
						
		$f_content=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"content",$f_opts);
		$this->addField($f_content);
		//********************
		
		//*** Field content_details ***
		$f_opts = array();
		$f_opts['id']="content_details";
						
		$f_content_details=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"content_details",$f_opts);
		$this->addField($f_content_details);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
