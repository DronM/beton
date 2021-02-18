<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class SupplierOrder_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("supplier_orders");
			
		//*** Field date ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="date";
						
		$f_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date",$f_opts);
		$this->addField($f_date);
		//********************
		
		//*** Field supplier_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="supplier_id";
						
		$f_supplier_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"supplier_id",$f_opts);
		$this->addField($f_supplier_id);
		//********************
		
		//*** Field material_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="material_id";
						
		$f_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="quant";
						
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field vehicles ***
		$f_opts = array();
		$f_opts['id']="vehicles";
						
		$f_vehicles=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicles",$f_opts);
		$this->addField($f_vehicles);
		//********************
		
		//*** Field sms_id ***
		$f_opts = array();
		$f_opts['id']="sms_id";
						
		$f_sms_id=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sms_id",$f_opts);
		$this->addField($f_sms_id);
		//********************
		
		//*** Field sms_confirmed ***
		$f_opts = array();
		$f_opts['id']="sms_confirmed";
						
		$f_sms_confirmed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"sms_confirmed",$f_opts);
		$this->addField($f_sms_confirmed);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
