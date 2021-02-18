<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class VehicleScheduleMakeOrderList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field vehicles_count ***
		$f_opts = array();
		$f_opts['id']="vehicles_count";
						
		$f_vehicles_count=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicles_count",$f_opts);
		$this->addField($f_vehicles_count);
		//********************
		
		//*** Field vehicles_ref ***
		$f_opts = array();
		$f_opts['id']="vehicles_ref";
						
		$f_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicles_ref",$f_opts);
		$this->addField($f_vehicles_ref);
		//********************
		
		//*** Field drivers_ref ***
		$f_opts = array();
		$f_opts['id']="drivers_ref";
						
		$f_drivers_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"drivers_ref",$f_opts);
		$this->addField($f_drivers_ref);
		//********************
		
		//*** Field driver_tel ***
		$f_opts = array();
		$f_opts['id']="driver_tel";
						
		$f_driver_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_tel",$f_opts);
		$this->addField($f_driver_tel);
		//********************
		
		//*** Field owner ***
		$f_opts = array();
		$f_opts['id']="owner";
						
		$f_owner=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner",$f_opts);
		$this->addField($f_owner);
		//********************
		
		//*** Field vehicle_owners_ref ***
		$f_opts = array();
		$f_opts['id']="vehicle_owners_ref";
						
		$f_vehicle_owners_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_owners_ref",$f_opts);
		$this->addField($f_vehicle_owners_ref);
		//********************
		
		//*** Field load_capacity ***
		$f_opts = array();
		$f_opts['id']="load_capacity";
						
		$f_load_capacity=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"load_capacity",$f_opts);
		$this->addField($f_load_capacity);
		//********************
		
		//*** Field state ***
		$f_opts = array();
		$f_opts['id']="state";
						
		$f_state=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"state",$f_opts);
		$this->addField($f_state);
		//********************
		
		//*** Field inf_on_return ***
		$f_opts = array();
		$f_opts['id']="inf_on_return";
						
		$f_inf_on_return=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"inf_on_return",$f_opts);
		$this->addField($f_inf_on_return);
		//********************
		
		//*** Field runs ***
		$f_opts = array();
		$f_opts['id']="runs";
						
		$f_runs=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"runs",$f_opts);
		$this->addField($f_runs);
		//********************
		
		//*** Field is_late ***
		$f_opts = array();
		$f_opts['id']="is_late";
						
		$f_is_late=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"is_late",$f_opts);
		$this->addField($f_is_late);
		//********************
		
		//*** Field is_late_at_dest ***
		$f_opts = array();
		$f_opts['id']="is_late_at_dest";
						
		$f_is_late_at_dest=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"is_late_at_dest",$f_opts);
		$this->addField($f_is_late_at_dest);
		//********************
		
		//*** Field inf_on_return ***
		$f_opts = array();
		$f_opts['id']="inf_on_return";
						
		$f_inf_on_return=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"inf_on_return",$f_opts);
		$this->addField($f_inf_on_return);
		//********************
		
		//*** Field tracker_no_data ***
		$f_opts = array();
		$f_opts['id']="tracker_no_data";
						
		$f_tracker_no_data=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tracker_no_data",$f_opts);
		$this->addField($f_tracker_no_data);
		//********************
		
		//*** Field schedule_date ***
		$f_opts = array();
		$f_opts['id']="schedule_date";
						
		$f_schedule_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"schedule_date",$f_opts);
		$this->addField($f_schedule_date);
		//********************
		
		//*** Field no_tracker ***
		$f_opts = array();
		$f_opts['id']="no_tracker";
						
		$f_no_tracker=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"no_tracker",$f_opts);
		$this->addField($f_no_tracker);
		//********************
		
		//*** Field vehicle_schedules_ref ***
		$f_opts = array();
		$f_opts['id']="vehicle_schedules_ref";
						
		$f_vehicle_schedules_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_schedules_ref",$f_opts);
		$this->addField($f_vehicle_schedules_ref);
		//********************
		
		//*** Field tracker_id ***
		$f_opts = array();
		$f_opts['id']="tracker_id";
						
		$f_tracker_id=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tracker_id",$f_opts);
		$this->addField($f_tracker_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
