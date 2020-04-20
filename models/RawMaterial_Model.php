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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class RawMaterial_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("raw_materials");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		
		$f_opts['alias']='Наименование';
		$f_opts['length']=100;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field planned_procurement ***
		$f_opts = array();
		
		$f_opts['alias']='Плановый приход';
		$f_opts['length']=19;
		$f_opts['id']="planned_procurement";
						
		$f_planned_procurement=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"planned_procurement",$f_opts);
		$this->addField($f_planned_procurement);
		//********************
		
		//*** Field supply_days_count ***
		$f_opts = array();
		
		$f_opts['alias']='Дней завоза';
		$f_opts['id']="supply_days_count";
						
		$f_supply_days_count=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"supply_days_count",$f_opts);
		$this->addField($f_supply_days_count);
		//********************
		
		//*** Field concrete_part ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="concrete_part";
						
		$f_concrete_part=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_part",$f_opts);
		$this->addField($f_concrete_part);
		//********************
		
		//*** Field ord ***
		$f_opts = array();
		$f_opts['id']="ord";
						
		$f_ord=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ord",$f_opts);
		$this->addField($f_ord);
		//********************
		
		//*** Field supply_volume ***
		$f_opts = array();
		
		$f_opts['alias']='Объем ТС завоза';
		$f_opts['id']="supply_volume";
						
		$f_supply_volume=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"supply_volume",$f_opts);
		$this->addField($f_supply_volume);
		//********************
		
		//*** Field store_days ***
		$f_opts = array();
		$f_opts['id']="store_days";
						
		$f_store_days=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"store_days",$f_opts);
		$this->addField($f_store_days);
		//********************
		
		//*** Field min_end_quant ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="min_end_quant";
						
		$f_min_end_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"min_end_quant",$f_opts);
		$this->addField($f_min_end_quant);
		//********************
		
		//*** Field max_required_quant_tolerance_percent ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="max_required_quant_tolerance_percent";
						
		$f_max_required_quant_tolerance_percent=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"max_required_quant_tolerance_percent",$f_opts);
		$this->addField($f_max_required_quant_tolerance_percent);
		//********************
		
		//*** Field max_fact_quant_tolerance_percent ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="max_fact_quant_tolerance_percent";
						
		$f_max_fact_quant_tolerance_percent=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"max_fact_quant_tolerance_percent",$f_opts);
		$this->addField($f_max_fact_quant_tolerance_percent);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_ord,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
