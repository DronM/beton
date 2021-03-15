<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLDOC.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
 
class DOCMaterialProcurementStoreList_Model extends ModelSQLDOC{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("doc_material_procurements_store_list");
			
		//*** Field store ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Склад';
		$f_opts['id']="store";
						
		$f_store=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"store",$f_opts);
		$this->addField($f_store);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
