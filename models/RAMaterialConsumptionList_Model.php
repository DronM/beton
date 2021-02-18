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
 
class RAMaterialConsumptionList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("ra_material_consumption_list_view");
			
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
						
		$f_date_time=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field date_time_descr ***
		$f_opts = array();
		$f_opts['id']="date_time_descr";
						
		$f_date_time_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time_descr",$f_opts);
		$this->addField($f_date_time_descr);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		$f_opts['id']="concrete_type_id";
						
		$f_concrete_type_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field concrete_type_descr ***
		$f_opts = array();
		$f_opts['id']="concrete_type_descr";
						
		$f_concrete_type_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_descr",$f_opts);
		$this->addField($f_concrete_type_descr);
		//********************
		
		//*** Field vehicle_id ***
		$f_opts = array();
		$f_opts['id']="vehicle_id";
						
		$f_vehicle_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_id",$f_opts);
		$this->addField($f_vehicle_id);
		//********************
		
		//*** Field vehicle_descr ***
		$f_opts = array();
		$f_opts['id']="vehicle_descr";
						
		$f_vehicle_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_descr",$f_opts);
		$this->addField($f_vehicle_descr);
		//********************
		
		//*** Field driver_id ***
		$f_opts = array();
		$f_opts['id']="driver_id";
						
		$f_driver_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_id",$f_opts);
		$this->addField($f_driver_id);
		//********************
		
		//*** Field driver_descr ***
		$f_opts = array();
		$f_opts['id']="driver_descr";
						
		$f_driver_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_descr",$f_opts);
		$this->addField($f_driver_descr);
		//********************
		
		//*** Field material_id ***
		$f_opts = array();
		$f_opts['id']="material_id";
						
		$f_material_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
		
		//*** Field material_descr ***
		$f_opts = array();
		$f_opts['id']="material_descr";
						
		$f_material_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_descr",$f_opts);
		$this->addField($f_material_descr);
		//********************
		
		//*** Field material_quant ***
		$f_opts = array();
		$f_opts['id']="material_quant";
						
		$f_material_quant=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_quant",$f_opts);
		$this->addField($f_material_quant);
		//********************
		
		//*** Field concrete_quant ***
		$f_opts = array();
		$f_opts['id']="concrete_quant";
						
		$f_concrete_quant=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_quant",$f_opts);
		$this->addField($f_concrete_quant);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
