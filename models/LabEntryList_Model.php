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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
 
class LabEntryList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("lab_entry_list_view");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field shipment_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="shipment_id";
				
		$f_shipment_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipment_id",$f_opts);
		$this->addField($f_shipment_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['id']="date_time";
				
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field ship_date_time_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['id']="ship_date_time_descr";
				
		$f_ship_date_time_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date_time_descr",$f_opts);
		$this->addField($f_ship_date_time_descr);
		//********************
		
		//*** Field concrete_type_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Марка';
		$f_opts['id']="concrete_type_descr";
				
		$f_concrete_type_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_descr",$f_opts);
		$this->addField($f_concrete_type_descr);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		$f_opts['id']="concrete_type_id";
				
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field ok ***
		$f_opts = array();
		$f_opts['id']="ok";
				
		$f_ok=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ok",$f_opts);
		$this->addField($f_ok);
		//********************
		
		//*** Field weight ***
		$f_opts = array();
		$f_opts['id']="weight";
				
		$f_weight=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"weight",$f_opts);
		$this->addField($f_weight);
		//********************
		
		//*** Field p7 ***
		$f_opts = array();
		$f_opts['id']="p7";
				
		$f_p7=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p7",$f_opts);
		$this->addField($f_p7);
		//********************
		
		//*** Field p28 ***
		$f_opts = array();
		$f_opts['id']="p28";
				
		$f_p28=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p28",$f_opts);
		$this->addField($f_p28);
		//********************
		
		//*** Field samples ***
		$f_opts = array();
		
		$f_opts['alias']='Подборы';
		$f_opts['id']="samples";
				
		$f_samples=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"samples",$f_opts);
		$this->addField($f_samples);
		//********************
		
		//*** Field materials ***
		$f_opts = array();
		
		$f_opts['alias']='Материалы';
		$f_opts['id']="materials";
				
		$f_materials=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"materials",$f_opts);
		$this->addField($f_materials);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		$f_opts['id']="client_id";
				
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field client_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Заказчик';
		$f_opts['id']="client_descr";
				
		$f_client_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_descr",$f_opts);
		$this->addField($f_client_descr);
		//********************
		
		//*** Field client_phone ***
		$f_opts = array();
		
		$f_opts['alias']='Телефон';
		$f_opts['id']="client_phone";
				
		$f_client_phone=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_phone",$f_opts);
		$this->addField($f_client_phone);
		//********************
		
		//*** Field destination_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Объект';
		$f_opts['id']="destination_descr";
				
		$f_destination_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_descr",$f_opts);
		$this->addField($f_destination_descr);
		//********************
		
		//*** Field ok2 ***
		$f_opts = array();
		
		$f_opts['alias']='ОК2';
		$f_opts['id']="ok2";
				
		$f_ok2=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ok2",$f_opts);
		$this->addField($f_ok2);
		//********************
		
		//*** Field time ***
		$f_opts = array();
		
		$f_opts['alias']='Время';
		$f_opts['id']="time";
				
		$f_time=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"time",$f_opts);
		$this->addField($f_time);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
