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
 
class Production_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("productions");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field production_id ***
		$f_opts = array();
		
		$f_opts['alias']='Elkon production ID';
		$f_opts['id']="production_id";
						
		$f_production_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_id",$f_opts);
		$this->addField($f_production_id);
		//********************
		
		//*** Field production_dt_start ***
		$f_opts = array();
		
		$f_opts['alias']='Начало производства в Elkon';
		$f_opts['id']="production_dt_start";
						
		$f_production_dt_start=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_dt_start",$f_opts);
		$this->addField($f_production_dt_start);
		//********************
		
		//*** Field production_dt_end ***
		$f_opts = array();
		
		$f_opts['alias']='Окончание производства в Elkon';
		$f_opts['id']="production_dt_end";
						
		$f_production_dt_end=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_dt_end",$f_opts);
		$this->addField($f_production_dt_end);
		//********************
		
		//*** Field production_user ***
		$f_opts = array();
		
		$f_opts['alias']='Пользователь Elkon';
		$f_opts['length']=150;
		$f_opts['id']="production_user";
						
		$f_production_user=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_user",$f_opts);
		$this->addField($f_production_user);
		//********************
		
		//*** Field production_vehicle_descr ***
		$f_opts = array();
		
		$f_opts['alias']='ТС в Elkon';
		$f_opts['length']=5;
		$f_opts['id']="production_vehicle_descr";
						
		$f_production_vehicle_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_vehicle_descr",$f_opts);
		$this->addField($f_production_vehicle_descr);
		//********************
		
		//*** Field dt_start_set ***
		$f_opts = array();
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
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
		
		//*** Field production_site_id ***
		$f_opts = array();
		$f_opts['id']="production_site_id";
						
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
		
		//*** Field shipment_id ***
		$f_opts = array();
		$f_opts['id']="shipment_id";
						
		$f_shipment_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipment_id",$f_opts);
		$this->addField($f_shipment_id);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		$f_opts['id']="concrete_type_id";
						
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field vehicle_schedule_state_id ***
		$f_opts = array();
		$f_opts['id']="vehicle_schedule_state_id";
						
		$f_vehicle_schedule_state_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_schedule_state_id",$f_opts);
		$this->addField($f_vehicle_schedule_state_id);
		//********************
		
		//*** Field vehicle_id ***
		$f_opts = array();
		$f_opts['id']="vehicle_id";
						
		$f_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_id",$f_opts);
		$this->addField($f_vehicle_id);
		//********************
		
		//*** Field production_concrete_type_descr ***
		$f_opts = array();
		$f_opts['id']="production_concrete_type_descr";
						
		$f_production_concrete_type_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_concrete_type_descr",$f_opts);
		$this->addField($f_production_concrete_type_descr);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
