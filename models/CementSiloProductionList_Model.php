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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class CementSiloProductionList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("cement_silo_productions_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field cement_silos_ref ***
		$f_opts = array();
		$f_opts['id']="cement_silos_ref";
						
		$f_cement_silos_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cement_silos_ref",$f_opts);
		$this->addField($f_cement_silos_ref);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field production_date_time ***
		$f_opts = array();
		$f_opts['id']="production_date_time";
						
		$f_production_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_date_time",$f_opts);
		$this->addField($f_production_date_time);
		//********************
		
		//*** Field production_vehicle_descr ***
		$f_opts = array();
		$f_opts['id']="production_vehicle_descr";
						
		$f_production_vehicle_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_vehicle_descr",$f_opts);
		$this->addField($f_production_vehicle_descr);
		//********************
		
		//*** Field vehicles_ref ***
		$f_opts = array();
		$f_opts['id']="vehicles_ref";
						
		$f_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicles_ref",$f_opts);
		$this->addField($f_vehicles_ref);
		//********************
		
		//*** Field vehicle_state ***
		$f_opts = array();
		$f_opts['id']="vehicle_state";
						
		$f_vehicle_state=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_state",$f_opts);
		$this->addField($f_vehicle_state);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
