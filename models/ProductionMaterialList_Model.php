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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ProductionMaterialList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("production_material_list");
			
		//*** Field production_site_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="production_site_id";
						
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
		
		//*** Field production_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Номер производства Elkon';
		$f_opts['id']="production_id";
						
		$f_production_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_id",$f_opts);
		$this->addField($f_production_id);
		//********************
		
		//*** Field production_sites_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Завод';
		$f_opts['id']="production_sites_ref";
						
		$f_production_sites_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_sites_ref",$f_opts);
		$this->addField($f_production_sites_ref);
		//********************
		
		//*** Field shipment_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="shipment_id";
						
		$f_shipment_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipment_id",$f_opts);
		$this->addField($f_shipment_id);
		//********************
		
		//*** Field shipments_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Отгрузка';
		$f_opts['id']="shipments_ref";
						
		$f_shipments_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipments_ref",$f_opts);
		$this->addField($f_shipments_ref);
		//********************
		
		//*** Field materials_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Материал';
		$f_opts['id']="materials_ref";
						
		$f_materials_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"materials_ref",$f_opts);
		$this->addField($f_materials_ref);
		//********************
		
		//*** Field material_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="material_id";
						
		$f_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
		
		//*** Field cement_silos_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Силос';
		$f_opts['id']="cement_silos_ref";
						
		$f_cement_silos_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cement_silos_ref",$f_opts);
		$this->addField($f_cement_silos_ref);
		//********************
		
		//*** Field cement_silo_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="cement_silo_id";
						
		$f_cement_silo_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cement_silo_id",$f_opts);
		$this->addField($f_cement_silo_id);
		//********************
		
		//*** Field quant_consuption ***
		$f_opts = array();
		
		$f_opts['alias']='Количество по подбору';
		$f_opts['id']="quant_consuption";
						
		$f_quant_consuption=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_consuption",$f_opts);
		$this->addField($f_quant_consuption);
		//********************
		
		//*** Field quant_fact ***
		$f_opts = array();
		
		$f_opts['alias']='Количество факт';
		$f_opts['id']="quant_fact";
						
		$f_quant_fact=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_fact",$f_opts);
		$this->addField($f_quant_fact);
		//********************
		
		//*** Field quant_fact_req ***
		$f_opts = array();
		
		$f_opts['alias']='Количество факт треб.';
		$f_opts['id']="quant_fact_req";
						
		$f_quant_fact_req=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_fact_req",$f_opts);
		$this->addField($f_quant_fact_req);
		//********************
		
		//*** Field quant_corrected ***
		$f_opts = array();
		
		$f_opts['alias']='Количество испр.вручную';
		$f_opts['id']="quant_corrected";
						
		$f_quant_corrected=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_corrected",$f_opts);
		$this->addField($f_quant_corrected);
		//********************
		
		//*** Field elkon_correction_id ***
		$f_opts = array();
		
		$f_opts['alias']='Идентификатор исправления Elkon';
		$f_opts['id']="elkon_correction_id";
						
		$f_elkon_correction_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"elkon_correction_id",$f_opts);
		$this->addField($f_elkon_correction_id);
		//********************
		
		//*** Field correction_users_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Кто исправил';
		$f_opts['id']="correction_users_ref";
						
		$f_correction_users_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"correction_users_ref",$f_opts);
		$this->addField($f_correction_users_ref);
		//********************
		
		//*** Field correction_date_time_set ***
		$f_opts = array();
		
		$f_opts['alias']='Когда исправил';
		$f_opts['id']="correction_date_time_set";
						
		$f_correction_date_time_set=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"correction_date_time_set",$f_opts);
		$this->addField($f_correction_date_time_set);
		//********************
		
		//*** Field quant_dif ***
		$f_opts = array();
		
		$f_opts['alias']='Разница';
		$f_opts['id']="quant_dif";
						
		$f_quant_dif=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_dif",$f_opts);
		$this->addField($f_quant_dif);
		//********************
		
		//*** Field material_quant ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="material_quant";
						
		$f_material_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_quant",$f_opts);
		$this->addField($f_material_quant);
		//********************
		
		//*** Field dif_violation ***
		$f_opts = array();
		
		$f_opts['alias']='Превышение';
		$f_opts['id']="dif_violation";
						
		$f_dif_violation=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dif_violation",$f_opts);
		$this->addField($f_dif_violation);
		//********************
		
		//*** Field material_fact_consumption_id ***
		$f_opts = array();
		
		$f_opts['alias']='Идентификатор строки фактического расхода';
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="material_fact_consumption_id";
						
		$f_material_fact_consumption_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_fact_consumption_id",$f_opts);
		$this->addField($f_material_fact_consumption_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
