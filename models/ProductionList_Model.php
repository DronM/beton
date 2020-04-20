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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ProductionList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("productions_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field production_id ***
		$f_opts = array();
		$f_opts['id']="production_id";
						
		$f_production_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_id",$f_opts);
		$this->addField($f_production_id);
		//********************
		
		//*** Field production_site_id ***
		$f_opts = array();
		$f_opts['id']="production_site_id";
						
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
		
		//*** Field production_dt_start ***
		$f_opts = array();
		$f_opts['id']="production_dt_start";
						
		$f_production_dt_start=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_dt_start",$f_opts);
		$this->addField($f_production_dt_start);
		//********************
		
		//*** Field production_dt_end ***
		$f_opts = array();
		$f_opts['id']="production_dt_end";
						
		$f_production_dt_end=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_dt_end",$f_opts);
		$this->addField($f_production_dt_end);
		//********************
		
		//*** Field production_user ***
		$f_opts = array();
		$f_opts['id']="production_user";
						
		$f_production_user=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_user",$f_opts);
		$this->addField($f_production_user);
		//********************
		
		//*** Field production_vehicle_descr ***
		$f_opts = array();
		$f_opts['id']="production_vehicle_descr";
						
		$f_production_vehicle_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_vehicle_descr",$f_opts);
		$this->addField($f_production_vehicle_descr);
		//********************
		
		//*** Field dt_start_set ***
		$f_opts = array();
		$f_opts['id']="dt_start_set";
						
		$f_dt_start_set=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt_start_set",$f_opts);
		$this->addField($f_dt_start_set);
		//********************
		
		//*** Field dt_end_set ***
		$f_opts = array();
		$f_opts['id']="dt_end_set";
						
		$f_dt_end_set=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt_end_set",$f_opts);
		$this->addField($f_dt_end_set);
		//********************
		
		//*** Field production_sites_ref ***
		$f_opts = array();
		$f_opts['id']="production_sites_ref";
						
		$f_production_sites_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_sites_ref",$f_opts);
		$this->addField($f_production_sites_ref);
		//********************
		
		//*** Field shipments_ref ***
		$f_opts = array();
		$f_opts['id']="shipments_ref";
						
		$f_shipments_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipments_ref",$f_opts);
		$this->addField($f_shipments_ref);
		//********************
		
		//*** Field vehicle_schedules_ref ***
		$f_opts = array();
		$f_opts['id']="vehicle_schedules_ref";
						
		$f_vehicle_schedules_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_schedules_ref",$f_opts);
		$this->addField($f_vehicle_schedules_ref);
		//********************
		
		//*** Field orders_ref ***
		$f_opts = array();
		$f_opts['id']="orders_ref";
						
		$f_orders_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"orders_ref",$f_opts);
		$this->addField($f_orders_ref);
		//********************
		
		//*** Field concrete_types_ref ***
		$f_opts = array();
		$f_opts['id']="concrete_types_ref";
						
		$f_concrete_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_types_ref",$f_opts);
		$this->addField($f_concrete_types_ref);
		//********************
		
		//*** Field production_concrete_type_descr ***
		$f_opts = array();
		$f_opts['id']="production_concrete_type_descr";
						
		$f_production_concrete_type_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_concrete_type_descr",$f_opts);
		$this->addField($f_production_concrete_type_descr);
		//********************
		
		//*** Field vehicle_id ***
		$f_opts = array();
		$f_opts['id']="vehicle_id";
						
		$f_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_id",$f_opts);
		$this->addField($f_vehicle_id);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		$f_opts['id']="concrete_type_id";
						
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field order_id ***
		$f_opts = array();
		$f_opts['id']="order_id";
						
		$f_order_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"order_id",$f_opts);
		$this->addField($f_order_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
