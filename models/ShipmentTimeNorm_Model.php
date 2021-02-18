<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
 
class ShipmentTimeNorm_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("shipment_time_norms");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Объем';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field norm_min ***
		$f_opts = array();
		
		$f_opts['alias']='Норма минут';
		$f_opts['id']="norm_min";
						
		$f_norm_min=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"norm_min",$f_opts);
		$this->addField($f_norm_min);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
