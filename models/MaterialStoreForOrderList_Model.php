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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class MaterialStoreForOrderList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("material_store_for_order_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field production_sites_ref ***
		$f_opts = array();
		$f_opts['id']="production_sites_ref";
						
		$f_production_sites_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_sites_ref",$f_opts);
		$this->addField($f_production_sites_ref);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field load_capacity ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="load_capacity";
						
		$f_load_capacity=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"load_capacity",$f_opts);
		$this->addField($f_load_capacity);
		//********************
		
		//*** Field balance ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="balance";
						
		$f_balance=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"balance",$f_opts);
		$this->addField($f_balance);
		//********************
		
		//*** Field material_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="material_id";
						
		$f_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
