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
 
class ShipmentTimeList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("shipment_times_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='№';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
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
		
		//*** Field production_site_id ***
		$f_opts = array();
		
		$f_opts['alias']='Код завода';
		$f_opts['id']="production_site_id";
						
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
		
		//*** Field production_site_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Завод';
		$f_opts['id']="production_site_descr";
						
		$f_production_site_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_descr",$f_opts);
		$this->addField($f_production_site_descr);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Объем';
		$f_opts['id']="quant";
						
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field vehicle_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Номер ТС';
		$f_opts['id']="vehicle_descr";
						
		$f_vehicle_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_descr",$f_opts);
		$this->addField($f_vehicle_descr);
		//********************
		
		//*** Field vehicle_id ***
		$f_opts = array();
		
		$f_opts['alias']='ТС';
		$f_opts['id']="vehicle_id";
						
		$f_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_id",$f_opts);
		$this->addField($f_vehicle_id);
		//********************
		
		//*** Field driver_id ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель код';
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
		
		//*** Field assign_date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Назначение';
		$f_opts['id']="assign_date_time";
						
		$f_assign_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"assign_date_time",$f_opts);
		$this->addField($f_assign_date_time);
		//********************
		
		//*** Field assign_date_time_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Назначение';
		$f_opts['id']="assign_date_time_descr";
						
		$f_assign_date_time_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"assign_date_time_descr",$f_opts);
		$this->addField($f_assign_date_time_descr);
		//********************
		
		//*** Field ship_date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Отгрузка';
		$f_opts['id']="ship_date_time";
						
		$f_ship_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date_time",$f_opts);
		$this->addField($f_ship_date_time);
		//********************
		
		//*** Field ship_date_time_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Отгрузка';
		$f_opts['id']="ship_date_time_descr";
						
		$f_ship_date_time_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date_time_descr",$f_opts);
		$this->addField($f_ship_date_time_descr);
		//********************
		
		//*** Field dispatcher_fail_min ***
		$f_opts = array();
		
		$f_opts['alias']='Опоздание диспетчара (мин)';
		$f_opts['id']="dispatcher_fail_min";
						
		$f_dispatcher_fail_min=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dispatcher_fail_min",$f_opts);
		$this->addField($f_dispatcher_fail_min);
		//********************
		
		//*** Field ship_time_norm ***
		$f_opts = array();
		
		$f_opts['alias']='Норма погрузки (мин)';
		$f_opts['id']="ship_time_norm";
						
		$f_ship_time_norm=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_time_norm",$f_opts);
		$this->addField($f_ship_time_norm);
		//********************
		
		//*** Field operator_fail_min ***
		$f_opts = array();
		
		$f_opts['alias']='Опоздание оператора (мин)';
		$f_opts['id']="operator_fail_min";
						
		$f_operator_fail_min=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"operator_fail_min",$f_opts);
		$this->addField($f_operator_fail_min);
		//********************
		
		//*** Field total_fail_min ***
		$f_opts = array();
		
		$f_opts['alias']='Опоздание общее (мин)';
		$f_opts['id']="total_fail_min";
						
		$f_total_fail_min=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total_fail_min",$f_opts);
		$this->addField($f_total_fail_min);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
