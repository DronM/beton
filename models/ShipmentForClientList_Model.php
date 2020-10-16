<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ShipmentForClientList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("shipments_for_client_list");
			
		//*** Field order_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Номер заявки';
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="order_id";
						
		$f_order_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"order_id",$f_opts);
		$this->addField($f_order_id);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		
		$f_opts['alias']='Идентификатор клиента';
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
		
		//*** Field ship_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата отгрузки';
		$f_opts['id']="ship_date";
						
		$f_ship_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date",$f_opts);
		$this->addField($f_ship_date);
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
		
		//*** Field pump_exists ***
		$f_opts = array();
		
		$f_opts['alias']='Есть насос';
		$f_opts['id']="pump_exists";
						
		$f_pump_exists=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_exists",$f_opts);
		$this->addField($f_pump_exists);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество,м3';
		$f_opts['id']="quant";
						
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field concrete_cost ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость бетона,руб';
		$f_opts['id']="concrete_cost";
						
		$f_concrete_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_cost",$f_opts);
		$this->addField($f_concrete_cost);
		//********************
		
		//*** Field deliv_cost ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость доставки,руб';
		$f_opts['id']="deliv_cost";
						
		$f_deliv_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"deliv_cost",$f_opts);
		$this->addField($f_deliv_cost);
		//********************
		
		//*** Field pump_cost ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость насоса,руб';
		$f_opts['id']="pump_cost";
						
		$f_pump_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump_cost",$f_opts);
		$this->addField($f_pump_cost);
		//********************
		
		//*** Field total_cost ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость всего,руб';
		$f_opts['id']="total_cost";
						
		$f_total_cost=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total_cost",$f_opts);
		$this->addField($f_total_cost);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_ship_date,$direct);
$this->setLimitConstant('doc_per_page_count');
	$this->setAggFunctions(
		array(array('alias'=>'total_quant','expr'=>'sum(quant)')
,array('alias'=>'total_concrete_cost','expr'=>'sum(concrete_cost)')
,array('alias'=>'total_deliv_cost','expr'=>'sum(deliv_cost)')
,array('alias'=>'total_pump_cost','expr'=>'sum(pump_cost)')
,array('alias'=>'total_total_cost','expr'=>'sum(total_cost)')
)
	);	

	}

}
?>
