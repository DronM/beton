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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class PumpVehicleWorkList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("pump_veh_work_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field phone_cel ***
		$f_opts = array();
		$f_opts['id']="phone_cel";
				
		$f_phone_cel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"phone_cel",$f_opts);
		$this->addField($f_phone_cel);
		//********************
		
		//*** Field pump_prices_ref ***
		$f_opts = array();
		$f_opts['id']="pump_prices_ref";
				
		$f_pump_prices_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_prices_ref",$f_opts);
		$this->addField($f_pump_prices_ref);
		//********************
		
		//*** Field pump_vehicles_ref ***
		$f_opts = array();
		$f_opts['id']="pump_vehicles_ref";
				
		$f_pump_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_vehicles_ref",$f_opts);
		$this->addField($f_pump_vehicles_ref);
		//********************
		
		//*** Field vehicle_owners_ref ***
		$f_opts = array();
		$f_opts['id']="vehicle_owners_ref";
				
		$f_vehicle_owners_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_owners_ref",$f_opts);
		$this->addField($f_vehicle_owners_ref);
		//********************
		
		//*** Field feature ***
		$f_opts = array();
		$f_opts['id']="feature";
				
		$f_feature=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"feature",$f_opts);
		$this->addField($f_feature);
		//********************
		
		//*** Field make ***
		$f_opts = array();
		$f_opts['id']="make";
				
		$f_make=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"make",$f_opts);
		$this->addField($f_make);
		//********************
		
		//*** Field plate ***
		$f_opts = array();
		$f_opts['id']="plate";
				
		$f_plate=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"plate",$f_opts);
		$this->addField($f_plate);
		//********************
		
		//*** Field pump_length ***
		$f_opts = array();
		$f_opts['id']="pump_length";
				
		$f_pump_length=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_length",$f_opts);
		$this->addField($f_pump_length);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
