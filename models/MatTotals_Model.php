<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
 
class MatTotals_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("");
			
		//*** Field material_id ***
		$f_opts = array();
		$f_opts['id']="material_id";
						
		$f_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
		
		//*** Field material_descr ***
		$f_opts = array();
		$f_opts['id']="material_descr";
						
		$f_material_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_descr",$f_opts);
		$this->addField($f_material_descr);
		//********************
		
		//*** Field quant_ordered ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="quant_ordered";
						
		$f_quant_ordered=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_ordered",$f_opts);
		$this->addField($f_quant_ordered);
		//********************
		
		//*** Field quant_procured ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="quant_procured";
						
		$f_quant_procured=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_procured",$f_opts);
		$this->addField($f_quant_procured);
		//********************
		
		//*** Field quant_balance ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="quant_balance";
						
		$f_quant_balance=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_balance",$f_opts);
		$this->addField($f_quant_balance);
		//********************
		
		//*** Field quant_morn_balance ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="quant_morn_balance";
						
		$f_quant_morn_balance=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_morn_balance",$f_opts);
		$this->addField($f_quant_morn_balance);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
