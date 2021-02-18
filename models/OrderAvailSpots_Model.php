<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
 
class OrderAvailSpots_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("");
			
		//*** Field avail_date_time ***
		$f_opts = array();
		$f_opts['id']="avail_date_time";
						
		$f_avail_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"avail_date_time",$f_opts);
		$this->addField($f_avail_date_time);
		//********************
		
		//*** Field avail_speed ***
		$f_opts = array();
		$f_opts['id']="avail_speed";
						
		$f_avail_speed=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"avail_speed",$f_opts);
		$this->addField($f_avail_speed);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
