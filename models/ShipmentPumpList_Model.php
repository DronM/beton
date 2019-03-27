<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
 
class ShipmentPumpList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("shipments_pumps_list");
			
		//*** Field ship_date_time ***
		$f_opts = array();
		$f_opts['id']="ship_date_time";
				
		$f_ship_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date_time",$f_opts);
		$this->addField($f_ship_date_time);
		//********************
		
		//*** Field ship_date_time_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Дата отгрузки';
		$f_opts['id']="ship_date_time_descr";
				
		$f_ship_date_time_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date_time_descr",$f_opts);
		$this->addField($f_ship_date_time_descr);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		
		$f_opts['alias']='Код клиента';
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
		
		$f_opts['alias']='Код объекта';
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
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['id']="quant";
				
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field pump_price ***
		$f_opts = array();
		
		$f_opts['alias']='Цена насоса';
		$f_opts['id']="pump_price";
				
		$f_pump_price=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_price",$f_opts);
		$this->addField($f_pump_price);
		//********************
		
		//*** Field owner ***
		$f_opts = array();
		
		$f_opts['alias']='Владелец';
		$f_opts['id']="owner";
				
		$f_owner=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner",$f_opts);
		$this->addField($f_owner);
		//********************
		
		//*** Field plate ***
		$f_opts = array();
		
		$f_opts['alias']='Гос.номер';
		$f_opts['id']="plate";
				
		$f_plate=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"plate",$f_opts);
		$this->addField($f_plate);
		//********************
		
		//*** Field driver_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['id']="driver_descr";
				
		$f_driver_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_descr",$f_opts);
		$this->addField($f_driver_descr);
		//********************
		
		//*** Field demurrage ***
		$f_opts = array();
		
		$f_opts['alias']='Простой';
		$f_opts['id']="demurrage";
				
		$f_demurrage=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"demurrage",$f_opts);
		$this->addField($f_demurrage);
		//********************
		
		//*** Field blanks_exist ***
		$f_opts = array();
		
		$f_opts['alias']='Бланки';
		$f_opts['id']="blanks_exist";
				
		$f_blanks_exist=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"blanks_exist",$f_opts);
		$this->addField($f_blanks_exist);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
