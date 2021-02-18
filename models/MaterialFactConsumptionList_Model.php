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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class MaterialFactConsumptionList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("material_fact_consumptions_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field production_dt_end ***
		$f_opts = array();
		$f_opts['id']="production_dt_end";
						
		$f_production_dt_end=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_dt_end",$f_opts);
		$this->addField($f_production_dt_end);
		//********************
		
		//*** Field upload_date_time ***
		$f_opts = array();
		$f_opts['id']="upload_date_time";
						
		$f_upload_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"upload_date_time",$f_opts);
		$this->addField($f_upload_date_time);
		//********************
		
		//*** Field upload_users_ref ***
		$f_opts = array();
		$f_opts['id']="upload_users_ref";
						
		$f_upload_users_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"upload_users_ref",$f_opts);
		$this->addField($f_upload_users_ref);
		//********************
		
		//*** Field production_site_id ***
		$f_opts = array();
		$f_opts['id']="production_site_id";
						
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
		
		//*** Field production_sites_ref ***
		$f_opts = array();
		$f_opts['id']="production_sites_ref";
						
		$f_production_sites_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_sites_ref",$f_opts);
		$this->addField($f_production_sites_ref);
		//********************
		
		//*** Field orders_ref ***
		$f_opts = array();
		$f_opts['id']="orders_ref";
						
		$f_orders_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"orders_ref",$f_opts);
		$this->addField($f_orders_ref);
		//********************
		
		//*** Field shipments_inf ***
		$f_opts = array();
		$f_opts['id']="shipments_inf";
						
		$f_shipments_inf=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipments_inf",$f_opts);
		$this->addField($f_shipments_inf);
		//********************
		
		//*** Field concrete_types_ref ***
		$f_opts = array();
		$f_opts['id']="concrete_types_ref";
						
		$f_concrete_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_types_ref",$f_opts);
		$this->addField($f_concrete_types_ref);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="concrete_type_id";
						
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field concrete_type_production_descr ***
		$f_opts = array();
		$f_opts['id']="concrete_type_production_descr";
						
		$f_concrete_type_production_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_production_descr",$f_opts);
		$this->addField($f_concrete_type_production_descr);
		//********************
		
		//*** Field raw_materials_ref ***
		$f_opts = array();
		$f_opts['id']="raw_materials_ref";
						
		$f_raw_materials_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"raw_materials_ref",$f_opts);
		$this->addField($f_raw_materials_ref);
		//********************
		
		//*** Field raw_material_production_descr ***
		$f_opts = array();
		$f_opts['id']="raw_material_production_descr";
						
		$f_raw_material_production_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"raw_material_production_descr",$f_opts);
		$this->addField($f_raw_material_production_descr);
		//********************
		
		//*** Field vehicles_ref ***
		$f_opts = array();
		$f_opts['id']="vehicles_ref";
						
		$f_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicles_ref",$f_opts);
		$this->addField($f_vehicles_ref);
		//********************
		
		//*** Field vehicle_production_descr ***
		$f_opts = array();
		$f_opts['id']="vehicle_production_descr";
						
		$f_vehicle_production_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_production_descr",$f_opts);
		$this->addField($f_vehicle_production_descr);
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
		
		//*** Field material_quant_shipped ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="material_quant_shipped";
						
		$f_material_quant_shipped=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_quant_shipped",$f_opts);
		$this->addField($f_material_quant_shipped);
		//********************
		
		//*** Field material_quant_tolerance_exceeded ***
		$f_opts = array();
		$f_opts['id']="material_quant_tolerance_exceeded";
						
		$f_material_quant_tolerance_exceeded=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_quant_tolerance_exceeded",$f_opts);
		$this->addField($f_material_quant_tolerance_exceeded);
		//********************
		
		//*** Field err_concrete_type ***
		$f_opts = array();
		$f_opts['id']="err_concrete_type";
						
		$f_err_concrete_type=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"err_concrete_type",$f_opts);
		$this->addField($f_err_concrete_type);
		//********************
		
		//*** Field order_concrete_types_ref ***
		$f_opts = array();
		$f_opts['id']="order_concrete_types_ref";
						
		$f_order_concrete_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"order_concrete_types_ref",$f_opts);
		$this->addField($f_order_concrete_types_ref);
		//********************
		
		//*** Field production_id ***
		$f_opts = array();
		$f_opts['id']="production_id";
						
		$f_production_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_id",$f_opts);
		$this->addField($f_production_id);
		//********************
		
		//*** Field shipments_ref ***
		$f_opts = array();
		$f_opts['id']="shipments_ref";
						
		$f_shipments_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipments_ref",$f_opts);
		$this->addField($f_shipments_ref);
		//********************
		
		//*** Field production_key ***
		$f_opts = array();
		$f_opts['id']="production_key";
						
		$f_production_key=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_key",$f_opts);
		$this->addField($f_production_key);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
