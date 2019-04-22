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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class ShipQuantForCostGrade_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("ship_quant_for_cost_grades");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Объем';
		$f_opts['id']="quant";
				
		$f_quant=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field quant_to ***
		$f_opts = array();
		$f_opts['id']="quant_to";
				
		$f_quant_to=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_to",$f_opts);
		$this->addField($f_quant_to);
		//********************
		
		//*** Field distance_from ***
		$f_opts = array();
		$f_opts['length']=12;
		$f_opts['id']="distance_from";
				
		$f_distance_from=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"distance_from",$f_opts);
		$this->addField($f_distance_from);
		//********************
		
		//*** Field distance_to ***
		$f_opts = array();
		$f_opts['length']=12;
		$f_opts['id']="distance_to";
				
		$f_distance_to=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"distance_to",$f_opts);
		$this->addField($f_distance_to);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_quant,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
