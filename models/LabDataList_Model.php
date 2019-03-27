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
 
class LabDataList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("lab_data_list_view");
			
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
		
		//*** Field concrete_type_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Марка';
		$f_opts['id']="concrete_type_descr";
				
		$f_concrete_type_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_descr",$f_opts);
		$this->addField($f_concrete_type_descr);
		//********************
		
		//*** Field quant_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Кол-во';
		$f_opts['id']="quant_descr";
				
		$f_quant_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_descr",$f_opts);
		$this->addField($f_quant_descr);
		//********************
		
		//*** Field num ***
		$f_opts = array();
		
		$f_opts['alias']='№';
		$f_opts['id']="num";
				
		$f_num=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"num",$f_opts);
		$this->addField($f_num);
		//********************
		
		//*** Field driver_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['id']="driver_descr";
				
		$f_driver_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_descr",$f_opts);
		$this->addField($f_driver_descr);
		//********************
		
		//*** Field ok_sm ***
		$f_opts = array();
		
		$f_opts['alias']='ОК см';
		$f_opts['id']="ok_sm";
				
		$f_ok_sm=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ok_sm",$f_opts);
		$this->addField($f_ok_sm);
		//********************
		
		//*** Field weight ***
		$f_opts = array();
		
		$f_opts['alias']='масса';
		$f_opts['id']="weight";
				
		$f_weight=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"weight",$f_opts);
		$this->addField($f_weight);
		//********************
		
		//*** Field weight_norm ***
		$f_opts = array();
		
		$f_opts['alias']='масса норм';
		$f_opts['id']="weight_norm";
				
		$f_weight_norm=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"weight_norm",$f_opts);
		$this->addField($f_weight_norm);
		//********************
		
		//*** Field percent_1 ***
		$f_opts = array();
		
		$f_opts['alias']='%';
		$f_opts['id']="percent_1";
				
		$f_percent_1=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"percent_1",$f_opts);
		$this->addField($f_percent_1);
		//********************
		
		//*** Field p_1 ***
		$f_opts = array();
		
		$f_opts['alias']='p1';
		$f_opts['id']="p_1";
				
		$f_p_1=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_1",$f_opts);
		$this->addField($f_p_1);
		//********************
		
		//*** Field p_2 ***
		$f_opts = array();
		
		$f_opts['alias']='p2';
		$f_opts['id']="p_2";
				
		$f_p_2=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_2",$f_opts);
		$this->addField($f_p_2);
		//********************
		
		//*** Field p_3 ***
		$f_opts = array();
		
		$f_opts['alias']='p3';
		$f_opts['id']="p_3";
				
		$f_p_3=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_3",$f_opts);
		$this->addField($f_p_3);
		//********************
		
		//*** Field p_4 ***
		$f_opts = array();
		
		$f_opts['alias']='p4';
		$f_opts['id']="p_4";
				
		$f_p_4=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_4",$f_opts);
		$this->addField($f_p_4);
		//********************
		
		//*** Field p_7 ***
		$f_opts = array();
		
		$f_opts['alias']='p7';
		$f_opts['id']="p_7";
				
		$f_p_7=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_7",$f_opts);
		$this->addField($f_p_7);
		//********************
		
		//*** Field p_norm ***
		$f_opts = array();
		
		$f_opts['alias']='p_norm';
		$f_opts['id']="p_norm";
				
		$f_p_norm=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_norm",$f_opts);
		$this->addField($f_p_norm);
		//********************
		
		//*** Field percent_2 ***
		$f_opts = array();
		
		$f_opts['alias']='percent_2';
		$f_opts['id']="percent_2";
				
		$f_percent_2=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"percent_2",$f_opts);
		$this->addField($f_percent_2);
		//********************
		
		//*** Field lab_comment ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="lab_comment";
				
		$f_lab_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"lab_comment",$f_opts);
		$this->addField($f_lab_comment);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
