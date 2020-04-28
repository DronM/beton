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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class RawMaterialMapToProductionList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("raw_material_map_to_production_list");
			
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
						
		$f_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field raw_materials_ref ***
		$f_opts = array();
		$f_opts['id']="raw_materials_ref";
						
		$f_raw_materials_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"raw_materials_ref",$f_opts);
		$this->addField($f_raw_materials_ref);
		//********************
		
		//*** Field production_descr ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="production_descr";
						
		$f_production_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_descr",$f_opts);
		$this->addField($f_production_descr);
		//********************
		
		//*** Field order_id ***
		$f_opts = array();
		$f_opts['id']="order_id";
						
		$f_order_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"order_id",$f_opts);
		$this->addField($f_order_id);
		//********************
		
		//*** Field raw_material_id ***
		$f_opts = array();
		$f_opts['id']="raw_material_id";
						
		$f_raw_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"raw_material_id",$f_opts);
		$this->addField($f_raw_material_id);
		//********************
		
		//*** Field raw_material_ord ***
		$f_opts = array();
		$f_opts['id']="raw_material_ord";
						
		$f_raw_material_ord=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"raw_material_ord",$f_opts);
		$this->addField($f_raw_material_ord);
		//********************
		
		//*** Field production_sites_ref ***
		$f_opts = array();
		$f_opts['id']="production_sites_ref";
						
		$f_production_sites_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_sites_ref",$f_opts);
		$this->addField($f_production_sites_ref);
		//********************
		
		//*** Field production_site_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="production_site_id";
						
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
