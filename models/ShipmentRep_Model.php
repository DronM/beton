<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelReportSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class ShipmentRep_Model extends ModelReportSQL{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("shipment_report");
			
		//*** Field ship_date_time ***
		$f_opts = array();
		$f_opts['id']="ship_date_time";
				
		$f_ship_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date_time",$f_opts);
		$this->addField($f_ship_date_time);
		//********************
		
		//*** Field shift_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Смена';
		$f_opts['id']="shift_descr";
				
		$f_shift_descr=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shift_descr",$f_opts);
		$this->addField($f_shift_descr);
		//********************
		
		//*** Field concrete_id ***
		$f_opts = array();
		$f_opts['id']="concrete_id";
				
		$f_concrete_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_id",$f_opts);
		$this->addField($f_concrete_id);
		//********************
		
		//*** Field concrete_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Марка бетона';
		$f_opts['id']="concrete_descr";
				
		$f_concrete_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_descr",$f_opts);
		$this->addField($f_concrete_descr);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		$f_opts['id']="client_id";
				
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field client_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Клиент';
		$f_opts['id']="client_descr";
				
		$f_client_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_descr",$f_opts);
		$this->addField($f_client_descr);
		//********************
		
		//*** Field destination_id ***
		$f_opts = array();
		$f_opts['id']="destination_id";
				
		$f_destination_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_id",$f_opts);
		$this->addField($f_destination_id);
		//********************
		
		//*** Field destination_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Объект';
		$f_opts['id']="destination_descr";
				
		$f_destination_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_descr",$f_opts);
		$this->addField($f_destination_descr);
		//********************
		
		//*** Field driver_id ***
		$f_opts = array();
		$f_opts['id']="driver_id";
				
		$f_driver_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_id",$f_opts);
		$this->addField($f_driver_id);
		//********************
		
		//*** Field driver_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['id']="driver_descr";
				
		$f_driver_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_descr",$f_opts);
		$this->addField($f_driver_descr);
		//********************
		
		//*** Field vehicle_id ***
		$f_opts = array();
		$f_opts['id']="vehicle_id";
				
		$f_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_id",$f_opts);
		$this->addField($f_vehicle_id);
		//********************
		
		//*** Field vehicle_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Автомобиль';
		$f_opts['id']="vehicle_descr";
				
		$f_vehicle_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_descr",$f_opts);
		$this->addField($f_vehicle_descr);
		//********************
		
		//*** Field vehicle_feature ***
		$f_opts = array();
		
		$f_opts['alias']='Свойство автом.';
		$f_opts['id']="vehicle_feature";
				
		$f_vehicle_feature=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_feature",$f_opts);
		$this->addField($f_vehicle_feature);
		//********************
		
		//*** Field vehicle_owner ***
		$f_opts = array();
		
		$f_opts['alias']='Владелец автом.';
		$f_opts['id']="vehicle_owner";
				
		$f_vehicle_owner=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_owner",$f_opts);
		$this->addField($f_vehicle_owner);
		//********************
		
		//*** Field quant_shipped ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['id']="quant_shipped";
				
		$f_quant_shipped=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_shipped",$f_opts);
		$this->addField($f_quant_shipped);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
