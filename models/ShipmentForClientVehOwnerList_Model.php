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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ShipmentForClientVehOwnerList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("shipments_for_client_veh_owner_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Номер';
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field ship_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата отгрузки';
		$f_opts['id']="ship_date";
						
		$f_ship_date=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date",$f_opts);
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
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['id']="quant";
						
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="client_id";
						
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field cost_shipment ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость доставки';
		$f_opts['id']="cost_shipment";
						
		$f_cost_shipment=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cost_shipment",$f_opts);
		$this->addField($f_cost_shipment);
		//********************
		
		//*** Field cost_concrete ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость бетон';
		$f_opts['id']="cost_concrete";
						
		$f_cost_concrete=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cost_concrete",$f_opts);
		$this->addField($f_cost_concrete);
		//********************
		
		//*** Field cost_other_owner_pump ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость чужего насоса';
		$f_opts['id']="cost_other_owner_pump";
						
		$f_cost_other_owner_pump=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cost_other_owner_pump",$f_opts);
		$this->addField($f_cost_other_owner_pump);
		//********************
		
		//*** Field cost_total ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость итого';
		$f_opts['id']="cost_total";
						
		$f_cost_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cost_total",$f_opts);
		$this->addField($f_cost_total);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	$this->setAggFunctions(
		array(array('alias'=>'total_quant','expr'=>'sum(quant)')
,array('alias'=>'total_cost_shipment','expr'=>'sum(cost_shipment)')
,array('alias'=>'total_cost_concrete','expr'=>'sum(cost_concrete)')
,array('alias'=>'total_cost_other_owner_pump','expr'=>'sum(cost_other_owner_pump)')
,array('alias'=>'total_cost_total','expr'=>'sum(cost_total)')
)
	);	

	}

}
?>
