<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLDOC.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class DOCMaterialProcurement_Model extends ModelSQLDOC{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("doc_material_procurements");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field number ***
		$f_opts = array();
		
		$f_opts['alias']='Номер';
		$f_opts['length']=11;
		$f_opts['id']="number";
						
		$f_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"number",$f_opts);
		$this->addField($f_number);
		//********************
		
		//*** Field doc_ref ***
		$f_opts = array();
		$f_opts['length']=36;
		$f_opts['id']="doc_ref";
						
		$f_doc_ref=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_ref",$f_opts);
		$this->addField($f_doc_ref);
		//********************
		
		//*** Field processed ***
		$f_opts = array();
		
		$f_opts['alias']='Проведен';
		$f_opts['id']="processed";
						
		$f_processed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"processed",$f_opts);
		$this->addField($f_processed);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		
		$f_opts['alias']='Автор';
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field supplier_id ***
		$f_opts = array();
		
		$f_opts['alias']='Поставщик';
		$f_opts['id']="supplier_id";
						
		$f_supplier_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"supplier_id",$f_opts);
		$this->addField($f_supplier_id);
		//********************
		
		//*** Field carrier_id ***
		$f_opts = array();
		
		$f_opts['alias']='Перевозчик';
		$f_opts['id']="carrier_id";
						
		$f_carrier_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"carrier_id",$f_opts);
		$this->addField($f_carrier_id);
		//********************
		
		//*** Field driver ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['length']=100;
		$f_opts['id']="driver";
						
		$f_driver=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver",$f_opts);
		$this->addField($f_driver);
		//********************
		
		//*** Field vehicle_plate ***
		$f_opts = array();
		
		$f_opts['alias']='гос.номер';
		$f_opts['length']=10;
		$f_opts['id']="vehicle_plate";
						
		$f_vehicle_plate=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_plate",$f_opts);
		$this->addField($f_vehicle_plate);
		//********************
		
		//*** Field material_id ***
		$f_opts = array();
		
		$f_opts['alias']='Материал';
		$f_opts['id']="material_id";
						
		$f_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
		
		//*** Field cement_silos_id ***
		$f_opts = array();
		
		$f_opts['alias']='Силос';
		$f_opts['id']="cement_silos_id";
						
		$f_cement_silos_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cement_silos_id",$f_opts);
		$this->addField($f_cement_silos_id);
		//********************
		
		//*** Field quant_gross ***
		$f_opts = array();
		
		$f_opts['alias']='Брутто';
		$f_opts['length']=19;
		$f_opts['id']="quant_gross";
						
		$f_quant_gross=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_gross",$f_opts);
		$this->addField($f_quant_gross);
		//********************
		
		//*** Field quant_net ***
		$f_opts = array();
		
		$f_opts['alias']='Нетто';
		$f_opts['length']=19;
		$f_opts['id']="quant_net";
						
		$f_quant_net=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_net",$f_opts);
		$this->addField($f_quant_net);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
