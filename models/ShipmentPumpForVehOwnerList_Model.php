<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ShipmentPumpForVehOwnerList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("shipments_pump_for_veh_owner_list");
			
		//*** Field last_ship_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="last_ship_id";
						
		$f_last_ship_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"last_ship_id",$f_opts);
		$this->addField($f_last_ship_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
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
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['id']="quant";
						
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field pump_cost ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость';
		$f_opts['id']="pump_cost";
						
		$f_pump_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_cost",$f_opts);
		$this->addField($f_pump_cost);
		//********************
		
		//*** Field pump_vehicles_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Автомобиль';
		$f_opts['id']="pump_vehicles_ref";
						
		$f_pump_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_vehicles_ref",$f_opts);
		$this->addField($f_pump_vehicles_ref);
		//********************
		
		//*** Field pump_vehicle_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="pump_vehicle_id";
						
		$f_pump_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_vehicle_id",$f_opts);
		$this->addField($f_pump_vehicle_id);
		//********************
		
		//*** Field pump_vehicle_owner_id ***
		$f_opts = array();
		$f_opts['id']="pump_vehicle_owner_id";
						
		$f_pump_vehicle_owner_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_vehicle_owner_id",$f_opts);
		$this->addField($f_pump_vehicle_owner_id);
		//********************
		
		//*** Field pump_vehicle_owners_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Владелец';
		$f_opts['id']="pump_vehicle_owners_ref";
						
		$f_pump_vehicle_owners_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_vehicle_owners_ref",$f_opts);
		$this->addField($f_pump_vehicle_owners_ref);
		//********************
		
		//*** Field acc_comment ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий бухгалетрии';
		$f_opts['id']="acc_comment";
						
		$f_acc_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"acc_comment",$f_opts);
		$this->addField($f_acc_comment);
		//********************
		
		//*** Field owner_pump_agreed ***
		$f_opts = array();
		
		$f_opts['alias']='Согласовано насос';
		$f_opts['id']="owner_pump_agreed";
						
		$f_owner_pump_agreed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner_pump_agreed",$f_opts);
		$this->addField($f_owner_pump_agreed);
		//********************
		
		//*** Field owner_pump_agreed_date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата согласования насос';
		$f_opts['id']="owner_pump_agreed_date_time";
						
		$f_owner_pump_agreed_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner_pump_agreed_date_time",$f_opts);
		$this->addField($f_owner_pump_agreed_date_time);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	$this->setAggFunctions(
		array(array('alias'=>'total_quant','expr'=>'sum(quant)')
,array('alias'=>'total_pump_cost','expr'=>'sum(pump_cost)')
)
	);	

	}

}
?>
