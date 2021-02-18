<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
 
class RawMaterialProcurRate_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("raw_material_procur_rates");
			
		//*** Field material_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['id']="material_id";
						
		$f_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
		
		//*** Field supplier_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['id']="supplier_id";
						
		$f_supplier_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"supplier_id",$f_opts);
		$this->addField($f_supplier_id);
		//********************
		
		//*** Field rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="rate";
						
		$f_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"rate",$f_opts);
		$this->addField($f_rate);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
