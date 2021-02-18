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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class Order_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("orders");
			
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
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
		
		//*** Field descr ***
		$f_opts = array();
		
		$f_opts['alias']='Описание';
		$f_opts['id']="descr";
						
		$f_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"descr",$f_opts);
		$this->addField($f_descr);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field date_time_to ***
		$f_opts = array();
		
		$f_opts['alias']='Время до';
		$f_opts['id']="date_time_to";
						
		$f_date_time_to=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time_to",$f_opts);
		$this->addField($f_date_time_to);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['length']=19;
		$f_opts['id']="quant";
						
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field phone_cel ***
		$f_opts = array();
		
		$f_opts['alias']='Сот.телефон';
		$f_opts['length']=15;
		$f_opts['id']="phone_cel";
						
		$f_phone_cel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"phone_cel",$f_opts);
		$this->addField($f_phone_cel);
		//********************
		
		//*** Field unload_speed ***
		$f_opts = array();
		
		$f_opts['alias']='Разгрузка куб/ч';
		$f_opts['length']=19;
		$f_opts['id']="unload_speed";
						
		$f_unload_speed=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unload_speed",$f_opts);
		$this->addField($f_unload_speed);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		
		$f_opts['alias']='Автор';
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field lang_id ***
		$f_opts = array();
		
		$f_opts['alias']='Язык';
		$f_opts['id']="lang_id";
						
		$f_lang_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"lang_id",$f_opts);
		$this->addField($f_lang_id);
		//********************
		
		//*** Field total ***
		$f_opts = array();
		
		$f_opts['alias']='Сумма';
		$f_opts['length']=15;
		$f_opts['id']="total";
						
		$f_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total",$f_opts);
		$this->addField($f_total);
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
		
		//*** Field pump_vehicle_id ***
		$f_opts = array();
		
		$f_opts['alias']='Насос';
		$f_opts['id']="pump_vehicle_id";
						
		$f_pump_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_vehicle_id",$f_opts);
		$this->addField($f_pump_vehicle_id);
		//********************
		
		//*** Field pay_cash ***
		$f_opts = array();
		
		$f_opts['alias']='Оплата на месте';
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="pay_cash";
						
		$f_pay_cash=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pay_cash",$f_opts);
		$this->addField($f_pay_cash);
		//********************
		
		//*** Field total_edit ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="total_edit";
						
		$f_total_edit=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total_edit",$f_opts);
		$this->addField($f_total_edit);
		//********************
		
		//*** Field payed ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="payed";
						
		$f_payed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"payed",$f_opts);
		$this->addField($f_payed);
		//********************
		
		//*** Field under_control ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="under_control";
						
		$f_under_control=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"under_control",$f_opts);
		$this->addField($f_under_control);
		//********************
		
		//*** Field last_modif_user_id ***
		$f_opts = array();
		
		$f_opts['alias']='Кто последний вносил изменения';
		$f_opts['id']="last_modif_user_id";
						
		$f_last_modif_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"last_modif_user_id",$f_opts);
		$this->addField($f_last_modif_user_id);
		//********************
		
		//*** Field last_modif_date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Время последнего изменения';
		$f_opts['id']="last_modif_date_time";
						
		$f_last_modif_date_time=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"last_modif_date_time",$f_opts);
		$this->addField($f_last_modif_date_time);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
