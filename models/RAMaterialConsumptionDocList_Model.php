<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
 
class RAMaterialConsumptionDocList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("");
			
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Дата';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field date_descr ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="date_descr";
						
		$f_date_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_descr",$f_opts);
		$this->addField($f_date_descr);
		//********************
		
		//*** Field concrete_type_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Марка';
		$f_opts['id']="concrete_type_descr";
						
		$f_concrete_type_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_descr",$f_opts);
		$this->addField($f_concrete_type_descr);
		//********************
		
		//*** Field vehicle_descr ***
		$f_opts = array();
		
		$f_opts['alias']='ТС';
		$f_opts['id']="vehicle_descr";
						
		$f_vehicle_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_descr",$f_opts);
		$this->addField($f_vehicle_descr);
		//********************
		
		//*** Field driver_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['id']="driver_descr";
						
		$f_driver_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_descr",$f_opts);
		$this->addField($f_driver_descr);
		//********************
		
		//*** Field concrete_quant ***
		$f_opts = array();
		
		$f_opts['alias']='Объем';
		$f_opts['id']="concrete_quant";
						
		$f_concrete_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_quant",$f_opts);
		$this->addField($f_concrete_quant);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
