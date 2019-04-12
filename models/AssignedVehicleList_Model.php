<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class AssignedVehicleList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("assigned_vehicles_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Назначен';
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field destinations_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Объект';
		$f_opts['id']="destinations_ref";
				
		$f_destinations_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destinations_ref",$f_opts);
		$this->addField($f_destinations_ref);
		//********************
		
		//*** Field drivers_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['id']="drivers_ref";
				
		$f_drivers_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"drivers_ref",$f_opts);
		$this->addField($f_drivers_ref);
		//********************
		
		//*** Field vehicles_ref ***
		$f_opts = array();
		
		$f_opts['alias']='ТС';
		$f_opts['id']="vehicles_ref";
				
		$f_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicles_ref",$f_opts);
		$this->addField($f_vehicles_ref);
		//********************
		
		//*** Field production_sites_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Завод';
		$f_opts['id']="production_sites_ref";
				
		$f_production_sites_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_sites_ref",$f_opts);
		$this->addField($f_production_sites_ref);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['id']="quant";
				
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
