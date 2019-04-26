<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class VehicleDriverForSchedGen_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field vehicle ***
		$f_opts = array();
		$f_opts['id']="vehicle";
				
		$f_vehicle=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle",$f_opts);
		$this->addField($f_vehicle);
		//********************
		
		//*** Field driver ***
		$f_opts = array();
		$f_opts['id']="driver";
				
		$f_driver=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver",$f_opts);
		$this->addField($f_driver);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
