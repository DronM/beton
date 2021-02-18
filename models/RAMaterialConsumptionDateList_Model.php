<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
 
class RAMaterialConsumptionDateList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("");
			
		//*** Field shift ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="shift";
						
		$f_shift=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shift",$f_opts);
		$this->addField($f_shift);
		//********************
		
		//*** Field shift_to ***
		$f_opts = array();
		$f_opts['id']="shift_to";
						
		$f_shift_to=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shift_to",$f_opts);
		$this->addField($f_shift_to);
		//********************
		
		//*** Field shift_descr ***
		$f_opts = array();
		$f_opts['id']="shift_descr";
						
		$f_shift_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shift_descr",$f_opts);
		$this->addField($f_shift_descr);
		//********************
		
		//*** Field shift_from_descr ***
		$f_opts = array();
		$f_opts['id']="shift_from_descr";
						
		$f_shift_from_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shift_from_descr",$f_opts);
		$this->addField($f_shift_from_descr);
		//********************
		
		//*** Field shift_to_descr ***
		$f_opts = array();
		$f_opts['id']="shift_to_descr";
						
		$f_shift_to_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shift_to_descr",$f_opts);
		$this->addField($f_shift_to_descr);
		//********************
		
		//*** Field concrete_quant ***
		$f_opts = array();
		$f_opts['id']="concrete_quant";
						
		$f_concrete_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_quant",$f_opts);
		$this->addField($f_concrete_quant);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
