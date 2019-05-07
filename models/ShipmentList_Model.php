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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ShipmentList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("shipments_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Номер';
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field ship_date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата отгрузки';
		$f_opts['id']="ship_date_time";
				
		$f_ship_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date_time",$f_opts);
		$this->addField($f_ship_date_time);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['id']="quant";
				
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field cost ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость доставки';
		$f_opts['id']="cost";
				
		$f_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cost",$f_opts);
		$this->addField($f_cost);
		//********************
		
		//*** Field shipped ***
		$f_opts = array();
		
		$f_opts['alias']='Отгружен';
		$f_opts['id']="shipped";
				
		$f_shipped=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipped",$f_opts);
		$this->addField($f_shipped);
		//********************
		
		//*** Field concrete_types_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Марка';
		$f_opts['id']="concrete_types_ref";
				
		$f_concrete_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_types_ref",$f_opts);
		$this->addField($f_concrete_types_ref);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="concrete_type_id";
				
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field owner ***
		$f_opts = array();
		
		$f_opts['alias']='Владелец';
		$f_opts['id']="owner";
				
		$f_owner=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner",$f_opts);
		$this->addField($f_owner);
		//********************
		
		//*** Field vehicles_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Автомобиль';
		$f_opts['id']="vehicles_ref";
				
		$f_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicles_ref",$f_opts);
		$this->addField($f_vehicles_ref);
		//********************
		
		//*** Field vehicle_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="vehicle_id";
				
		$f_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_id",$f_opts);
		$this->addField($f_vehicle_id);
		//********************
		
		//*** Field drivers_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['id']="drivers_ref";
				
		$f_drivers_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"drivers_ref",$f_opts);
		$this->addField($f_drivers_ref);
		//********************
		
		//*** Field driver_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="driver_id";
				
		$f_driver_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_id",$f_opts);
		$this->addField($f_driver_id);
		//********************
		
		//*** Field destinations_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Объект';
		$f_opts['id']="destinations_ref";
				
		$f_destinations_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destinations_ref",$f_opts);
		$this->addField($f_destinations_ref);
		//********************
		
		//*** Field destination_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="destination_id";
				
		$f_destination_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_id",$f_opts);
		$this->addField($f_destination_id);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="client_id";
				
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field clients_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Клиент';
		$f_opts['id']="clients_ref";
				
		$f_clients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"clients_ref",$f_opts);
		$this->addField($f_clients_ref);
		//********************
		
		//*** Field demurrage ***
		$f_opts = array();
		
		$f_opts['alias']='Простой';
		$f_opts['id']="demurrage";
				
		$f_demurrage=new FieldSQLTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"demurrage",$f_opts);
		$this->addField($f_demurrage);
		//********************
		
		//*** Field demurrage_cost ***
		$f_opts = array();
		
		$f_opts['alias']='Стомость простоя';
		$f_opts['id']="demurrage_cost";
				
		$f_demurrage_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"demurrage_cost",$f_opts);
		$this->addField($f_demurrage_cost);
		//********************
		
		//*** Field client_mark ***
		$f_opts = array();
		
		$f_opts['alias']='Оценка';
		$f_opts['id']="client_mark";
				
		$f_client_mark=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_mark",$f_opts);
		$this->addField($f_client_mark);
		//********************
		
		//*** Field blanks_exist ***
		$f_opts = array();
		
		$f_opts['alias']='Наличие бланков';
		$f_opts['id']="blanks_exist";
				
		$f_blanks_exist=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"blanks_exist",$f_opts);
		$this->addField($f_blanks_exist);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="user_id";
				
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field users_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Автор';
		$f_opts['id']="users_ref";
				
		$f_users_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"users_ref",$f_opts);
		$this->addField($f_users_ref);
		//********************
		
		//*** Field production_sites_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Завод';
		$f_opts['id']="production_sites_ref";
				
		$f_production_sites_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_sites_ref",$f_opts);
		$this->addField($f_production_sites_ref);
		//********************
		
		//*** Field production_site_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="production_site_id";
				
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
