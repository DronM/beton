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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
 
class Offer_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("offer");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		
		$f_opts['alias']='клиент';
		$f_opts['id']="client_id";
						
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field destination_id ***
		$f_opts = array();
		
		$f_opts['alias']='Направление';
		$f_opts['id']="destination_id";
						
		$f_destination_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_id",$f_opts);
		$this->addField($f_destination_id);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		
		$f_opts['alias']='Марка бетона';
		$f_opts['id']="concrete_type_id";
						
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field unload_type ***
		$f_opts = array();
		
		$f_opts['alias']='Прокачка';
		$f_opts['id']="unload_type";
						
		$f_unload_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unload_type",$f_opts);
		$this->addField($f_unload_type);
		//********************
		
		//*** Field concrete_price ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость';
		$f_opts['length']=15;
		$f_opts['id']="concrete_price";
						
		$f_concrete_price=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_price",$f_opts);
		$this->addField($f_concrete_price);
		//********************
		
		//*** Field destination_price ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость дост.';
		$f_opts['length']=15;
		$f_opts['id']="destination_price";
						
		$f_destination_price=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destination_price",$f_opts);
		$this->addField($f_destination_price);
		//********************
		
		//*** Field unload_price ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость прокачки';
		$f_opts['length']=15;
		$f_opts['id']="unload_price";
						
		$f_unload_price=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unload_price",$f_opts);
		$this->addField($f_unload_price);
		//********************
		
		//*** Field total ***
		$f_opts = array();
		
		$f_opts['alias']='Итого';
		$f_opts['length']=15;
		$f_opts['id']="total";
						
		$f_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total",$f_opts);
		$this->addField($f_total);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['length']=19;
		$f_opts['id']="quant";
						
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field offer_result ***
		$f_opts = array();
		
		$f_opts['alias']='Результат';
		$f_opts['id']="offer_result";
						
		$f_offer_result=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"offer_result",$f_opts);
		$this->addField($f_offer_result);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field pump_vehicle_id ***
		$f_opts = array();
		
		$f_opts['alias']='Насос';
		$f_opts['id']="pump_vehicle_id";
						
		$f_pump_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_vehicle_id",$f_opts);
		$this->addField($f_pump_vehicle_id);
		//********************
		
		//*** Field ast_call_unique_id ***
		$f_opts = array();
		$f_opts['id']="ast_call_unique_id";
						
		$f_ast_call_unique_id=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ast_call_unique_id",$f_opts);
		$this->addField($f_ast_call_unique_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
