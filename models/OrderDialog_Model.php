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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class OrderDialog_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("orders_dialog");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field number ***
		$f_opts = array();
		$f_opts['id']="number";
				
		$f_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"number",$f_opts);
		$this->addField($f_number);
		//********************
		
		//*** Field clients_ref ***
		$f_opts = array();
		$f_opts['id']="clients_ref";
				
		$f_clients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"clients_ref",$f_opts);
		$this->addField($f_clients_ref);
		//********************
		
		//*** Field users_ref ***
		$f_opts = array();
		$f_opts['id']="users_ref";
				
		$f_users_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"users_ref",$f_opts);
		$this->addField($f_users_ref);
		//********************
		
		//*** Field destinations_ref ***
		$f_opts = array();
		$f_opts['id']="destinations_ref";
				
		$f_destinations_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destinations_ref",$f_opts);
		$this->addField($f_destinations_ref);
		//********************
		
		//*** Field destination_price ***
		$f_opts = array();
		$f_opts['id']="destination_price";
				
		$f_destination_price=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_price",$f_opts);
		$this->addField($f_destination_price);
		//********************
		
		//*** Field destination_cost ***
		$f_opts = array();
		$f_opts['id']="destination_cost";
				
		$f_destination_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_cost",$f_opts);
		$this->addField($f_destination_cost);
		//********************
		
		//*** Field destination_time_rout ***
		$f_opts = array();
		$f_opts['id']="destination_time_rout";
				
		$f_destination_time_rout=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_time_rout",$f_opts);
		$this->addField($f_destination_time_rout);
		//********************
		
		//*** Field destination_distance ***
		$f_opts = array();
		$f_opts['id']="destination_distance";
				
		$f_destination_distance=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_distance",$f_opts);
		$this->addField($f_destination_distance);
		//********************
		
		//*** Field concrete_types_ref ***
		$f_opts = array();
		$f_opts['id']="concrete_types_ref";
				
		$f_concrete_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_types_ref",$f_opts);
		$this->addField($f_concrete_types_ref);
		//********************
		
		//*** Field concrete_price ***
		$f_opts = array();
		$f_opts['id']="concrete_price";
				
		$f_concrete_price=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_price",$f_opts);
		$this->addField($f_concrete_price);
		//********************
		
		//*** Field concrete_cost ***
		$f_opts = array();
		$f_opts['id']="concrete_cost";
				
		$f_concrete_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_cost",$f_opts);
		$this->addField($f_concrete_cost);
		//********************
		
		//*** Field unload_type ***
		$f_opts = array();
		$f_opts['id']="unload_type";
				
		$f_unload_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unload_type",$f_opts);
		$this->addField($f_unload_type);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
				
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field descr ***
		$f_opts = array();
		$f_opts['id']="descr";
				
		$f_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"descr",$f_opts);
		$this->addField($f_descr);
		//********************
		
		//*** Field phone_cel ***
		$f_opts = array();
		$f_opts['id']="phone_cel";
				
		$f_phone_cel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"phone_cel",$f_opts);
		$this->addField($f_phone_cel);
		//********************
		
		//*** Field unload_speed ***
		$f_opts = array();
		$f_opts['id']="unload_speed";
				
		$f_unload_speed=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unload_speed",$f_opts);
		$this->addField($f_unload_speed);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field time_to ***
		$f_opts = array();
		$f_opts['id']="time_to";
				
		$f_time_to=new FieldSQLTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"time_to",$f_opts);
		$this->addField($f_time_to);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		$f_opts['id']="quant";
				
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field langs_ref ***
		$f_opts = array();
		$f_opts['id']="langs_ref";
				
		$f_langs_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"langs_ref",$f_opts);
		$this->addField($f_langs_ref);
		//********************
		
		//*** Field total ***
		$f_opts = array();
		$f_opts['id']="total";
				
		$f_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total",$f_opts);
		$this->addField($f_total);
		//********************
		
		//*** Field total_edit ***
		$f_opts = array();
		$f_opts['id']="total_edit";
				
		$f_total_edit=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total_edit",$f_opts);
		$this->addField($f_total_edit);
		//********************
		
		//*** Field payed ***
		$f_opts = array();
		$f_opts['id']="payed";
				
		$f_payed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"payed",$f_opts);
		$this->addField($f_payed);
		//********************
		
		//*** Field pay_cash ***
		$f_opts = array();
		$f_opts['id']="pay_cash";
				
		$f_pay_cash=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pay_cash",$f_opts);
		$this->addField($f_pay_cash);
		//********************
		
		//*** Field unload_cost ***
		$f_opts = array();
		$f_opts['id']="unload_cost";
				
		$f_unload_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unload_cost",$f_opts);
		$this->addField($f_unload_cost);
		//********************
		
		//*** Field under_control ***
		$f_opts = array();
		$f_opts['id']="under_control";
				
		$f_under_control=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"under_control",$f_opts);
		$this->addField($f_under_control);
		//********************
		
		//*** Field pump_vehicle_phone_cel ***
		$f_opts = array();
		$f_opts['id']="pump_vehicle_phone_cel";
				
		$f_pump_vehicle_phone_cel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_vehicle_phone_cel",$f_opts);
		$this->addField($f_pump_vehicle_phone_cel);
		//********************
		
		//*** Field pump_vehicles_ref ***
		$f_opts = array();
		$f_opts['id']="pump_vehicles_ref";
				
		$f_pump_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_vehicles_ref",$f_opts);
		$this->addField($f_pump_vehicles_ref);
		//********************
		
		//*** Field pump_prices_ref ***
		$f_opts = array();
		$f_opts['id']="pump_prices_ref";
				
		$f_pump_prices_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_prices_ref",$f_opts);
		$this->addField($f_pump_prices_ref);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
