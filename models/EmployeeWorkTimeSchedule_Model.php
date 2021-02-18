<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class EmployeeWorkTimeSchedule_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("employee_work_time_schedules");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['id']="employee_id";
						
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
		
		//*** Field day ***
		$f_opts = array();
		$f_opts['id']="day";
						
		$f_day=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"day",$f_opts);
		$this->addField($f_day);
		//********************
		
		//*** Field hours ***
		$f_opts = array();
		$f_opts['defaultValue']='0';
		$f_opts['id']="hours";
						
		$f_hours=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"hours",$f_opts);
		$this->addField($f_hours);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
