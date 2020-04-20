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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class MaterialFactConsumption_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("material_fact_consumptions");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field production_site_id ***
		$f_opts = array();
		$f_opts['id']="production_site_id";
						
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
		
		//*** Field upload_date_time ***
		$f_opts = array();
		$f_opts['id']="upload_date_time";
						
		$f_upload_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"upload_date_time",$f_opts);
		$this->addField($f_upload_date_time);
		//********************
		
		//*** Field upload_user_id ***
		$f_opts = array();
		$f_opts['id']="upload_user_id";
						
		$f_upload_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"upload_user_id",$f_opts);
		$this->addField($f_upload_user_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field concrete_type_production_descr ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="concrete_type_production_descr";
						
		$f_concrete_type_production_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_production_descr",$f_opts);
		$this->addField($f_concrete_type_production_descr);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		$f_opts['id']="concrete_type_id";
						
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field raw_material_production_descr ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="raw_material_production_descr";
						
		$f_raw_material_production_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"raw_material_production_descr",$f_opts);
		$this->addField($f_raw_material_production_descr);
		//********************
		
		//*** Field raw_material_id ***
		$f_opts = array();
		$f_opts['id']="raw_material_id";
						
		$f_raw_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"raw_material_id",$f_opts);
		$this->addField($f_raw_material_id);
		//********************
		
		//*** Field vehicle_production_descr ***
		$f_opts = array();
		$f_opts['length']=5;
		$f_opts['id']="vehicle_production_descr";
						
		$f_vehicle_production_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_production_descr",$f_opts);
		$this->addField($f_vehicle_production_descr);
		//********************
		
		//*** Field vehicle_id ***
		$f_opts = array();
		$f_opts['id']="vehicle_id";
						
		$f_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_id",$f_opts);
		$this->addField($f_vehicle_id);
		//********************
		
		//*** Field vehicle_schedule_state_id ***
		$f_opts = array();
		$f_opts['id']="vehicle_schedule_state_id";
						
		$f_vehicle_schedule_state_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_schedule_state_id",$f_opts);
		$this->addField($f_vehicle_schedule_state_id);
		//********************
		
		//*** Field concrete_quant ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="concrete_quant";
						
		$f_concrete_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_quant",$f_opts);
		$this->addField($f_concrete_quant);
		//********************
		
		//*** Field material_quant ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="material_quant";
						
		$f_material_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_quant",$f_opts);
		$this->addField($f_material_quant);
		//********************
		
		//*** Field material_quant_req ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="material_quant_req";
						
		$f_material_quant_req=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_quant_req",$f_opts);
		$this->addField($f_material_quant_req);
		//********************
		
		//*** Field cement_silo_id ***
		$f_opts = array();
		$f_opts['id']="cement_silo_id";
						
		$f_cement_silo_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cement_silo_id",$f_opts);
		$this->addField($f_cement_silo_id);
		//********************
		
		//*** Field production_id ***
		$f_opts = array();
		$f_opts['id']="production_id";
						
		$f_production_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_id",$f_opts);
		$this->addField($f_production_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
