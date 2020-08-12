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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class OperatorList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("shipment_for_orders_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Номер';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Назначен';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field ship_date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Отгружен';
		$f_opts['id']="ship_date_time";
						
		$f_ship_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date_time",$f_opts);
		$this->addField($f_ship_date_time);
		//********************
		
		//*** Field clients_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Клиент';
		$f_opts['id']="clients_ref";
						
		$f_clients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"clients_ref",$f_opts);
		$this->addField($f_clients_ref);
		//********************
		
		//*** Field production_sites_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Завод';
		$f_opts['id']="production_sites_ref";
						
		$f_production_sites_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_sites_ref",$f_opts);
		$this->addField($f_production_sites_ref);
		//********************
		
		//*** Field destinations_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Объект';
		$f_opts['id']="destinations_ref";
						
		$f_destinations_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destinations_ref",$f_opts);
		$this->addField($f_destinations_ref);
		//********************
		
		//*** Field operators_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Опреатор';
		$f_opts['id']="operators_ref";
						
		$f_operators_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"operators_ref",$f_opts);
		$this->addField($f_operators_ref);
		//********************
		
		//*** Field drivers_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['id']="drivers_ref";
						
		$f_drivers_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"drivers_ref",$f_opts);
		$this->addField($f_drivers_ref);
		//********************
		
		//*** Field vehicles_ref ***
		$f_opts = array();
		
		$f_opts['alias']='ТС';
		$f_opts['id']="vehicles_ref";
						
		$f_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicles_ref",$f_opts);
		$this->addField($f_vehicles_ref);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field concrete_types_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Марка';
		$f_opts['id']="concrete_types_ref";
						
		$f_concrete_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_types_ref",$f_opts);
		$this->addField($f_concrete_types_ref);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['id']="quant";
						
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field shipped ***
		$f_opts = array();
		
		$f_opts['alias']='Отгружен';
		$f_opts['id']="shipped";
						
		$f_shipped=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipped",$f_opts);
		$this->addField($f_shipped);
		//********************
		
		//*** Field ship_norm_min ***
		$f_opts = array();
		
		$f_opts['alias']='Норма отгр.';
		$f_opts['id']="ship_norm_min";
						
		$f_ship_norm_min=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_norm_min",$f_opts);
		$this->addField($f_ship_norm_min);
		//********************
		
		//*** Field ship_fact_min ***
		$f_opts = array();
		
		$f_opts['alias']='Норма факт.';
		$f_opts['id']="ship_fact_min";
						
		$f_ship_fact_min=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_fact_min",$f_opts);
		$this->addField($f_ship_fact_min);
		//********************
		
		//*** Field ship_bal_min ***
		$f_opts = array();
		
		$f_opts['alias']='Остаток';
		$f_opts['id']="ship_bal_min";
						
		$f_ship_bal_min=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_bal_min",$f_opts);
		$this->addField($f_ship_bal_min);
		//********************
		
		//*** Field production_site_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="production_site_id";
						
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
		
		//*** Field production_list ***
		$f_opts = array();
		
		$f_opts['alias']='Список производств elkon';
		$f_opts['id']="production_list";
						
		$f_production_list=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_list",$f_opts);
		$this->addField($f_production_list);
		//********************
		
		//*** Field production_quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество по данным всех производств';
		$f_opts['id']="production_quant";
						
		$f_production_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_quant",$f_opts);
		$this->addField($f_production_quant);
		//********************
		
		//*** Field tolerance_exceeded ***
		$f_opts = array();
		$f_opts['id']="tolerance_exceeded";
						
		$f_tolerance_exceeded=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tolerance_exceeded",$f_opts);
		$this->addField($f_tolerance_exceeded);
		//********************
	$this->setLimitConstant('doc_per_page_count');
		$this->setCalcHash(TRUE);
	}

}
?>
