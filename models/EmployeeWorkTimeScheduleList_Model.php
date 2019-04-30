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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class EmployeeWorkTimeScheduleList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("employee_work_time_schedules_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field employee_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="employee_id";
				
		$f_employee_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_id",$f_opts);
		$this->addField($f_employee_id);
		//********************
		
		//*** Field employee_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Сотрудник';
		$f_opts['id']="employee_descr";
				
		$f_employee_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"employee_descr",$f_opts);
		$this->addField($f_employee_descr);
		//********************
		
		//*** Field day ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="day";
				
		$f_day=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"day",$f_opts);
		$this->addField($f_day);
		//********************
		
		//*** Field day_off ***
		$f_opts = array();
		$f_opts['id']="day_off";
				
		$f_day_off=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"day_off",$f_opts);
		$this->addField($f_day_off);
		//********************
		
		//*** Field hours ***
		$f_opts = array();
		
		$f_opts['alias']='Часы';
		$f_opts['id']="hours";
				
		$f_hours=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"hours",$f_opts);
		$this->addField($f_hours);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
