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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInterval.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class Shipment_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("shipments");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field order_id ***
		$f_opts = array();
		
		$f_opts['alias']='Заявка';
		$f_opts['id']="order_id";
				
		$f_order_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"order_id",$f_opts);
		$this->addField($f_order_id);
		//********************
		
		//*** Field vehicle_schedule_id ***
		$f_opts = array();
		
		$f_opts['alias']='Экипаж';
		$f_opts['id']="vehicle_schedule_id";
				
		$f_vehicle_schedule_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_schedule_id",$f_opts);
		$this->addField($f_vehicle_schedule_id);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['length']=19;
		$f_opts['id']="quant";
				
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		
		$f_opts['alias']='Автор';
		$f_opts['id']="user_id";
				
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field production_site_id ***
		$f_opts = array();
		
		$f_opts['alias']='Завод';
		$f_opts['id']="production_site_id";
				
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
		
		//*** Field client_mark ***
		$f_opts = array();
		
		$f_opts['alias']='Баллы';
		$f_opts['id']="client_mark";
				
		$f_client_mark=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_mark",$f_opts);
		$this->addField($f_client_mark);
		//********************
		
		//*** Field demurrage ***
		$f_opts = array();
		
		$f_opts['alias']='Простой';
		$f_opts['id']="demurrage";
				
		$f_demurrage=new FieldSQLInterval($this->getDbLink(),$this->getDbName(),$this->getTableName(),"demurrage",$f_opts);
		$this->addField($f_demurrage);
		//********************
		
		//*** Field blanks_exist ***
		$f_opts = array();
		
		$f_opts['alias']='Наличие бланков';
		$f_opts['id']="blanks_exist";
				
		$f_blanks_exist=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"blanks_exist",$f_opts);
		$this->addField($f_blanks_exist);
		//********************
		
		//*** Field owner_agreed ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="owner_agreed";
				
		$f_owner_agreed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner_agreed",$f_opts);
		$this->addField($f_owner_agreed);
		//********************
		
		//*** Field owner_agreed_date_time ***
		$f_opts = array();
		$f_opts['id']="owner_agreed_date_time";
				
		$f_owner_agreed_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner_agreed_date_time",$f_opts);
		$this->addField($f_owner_agreed_date_time);
		//********************
		
		//*** Field acc_comment ***
		$f_opts = array();
		$f_opts['id']="acc_comment";
				
		$f_acc_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"acc_comment",$f_opts);
		$this->addField($f_acc_comment);
		//********************
		
		//*** Field owner_pump_agreed ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="owner_pump_agreed";
				
		$f_owner_pump_agreed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner_pump_agreed",$f_opts);
		$this->addField($f_owner_pump_agreed);
		//********************
		
		//*** Field owner_pump_agreed_date_time ***
		$f_opts = array();
		$f_opts['id']="owner_pump_agreed_date_time";
				
		$f_owner_pump_agreed_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"owner_pump_agreed_date_time",$f_opts);
		$this->addField($f_owner_pump_agreed_date_time);
		//********************
		
		//*** Field pump_cost ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="pump_cost";
				
		$f_pump_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_cost",$f_opts);
		$this->addField($f_pump_cost);
		//********************
		
		//*** Field pump_cost_edit ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="pump_cost_edit";
				
		$f_pump_cost_edit=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_cost_edit",$f_opts);
		$this->addField($f_pump_cost_edit);
		//********************
		
		//*** Field ship_cost ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="ship_cost";
				
		$f_ship_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_cost",$f_opts);
		$this->addField($f_ship_cost);
		//********************
		
		//*** Field ship_cost_edit ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="ship_cost_edit";
				
		$f_ship_cost_edit=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_cost_edit",$f_opts);
		$this->addField($f_ship_cost_edit);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
