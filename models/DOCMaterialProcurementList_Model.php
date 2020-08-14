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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class DOCMaterialProcurementList_Model extends ModelSQLDOC{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("doc_material_procurements_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Идентификатор';
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
		
		$f_opts['alias']='Номер 1с';
		$f_opts['id']="number";
						
		$f_number=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"number",$f_opts);
		$this->addField($f_number);
		//********************
		
		//*** Field processed ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="processed";
						
		$f_processed=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"processed",$f_opts);
		$this->addField($f_processed);
		//********************
		
		//*** Field supplier_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="supplier_id";
						
		$f_supplier_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"supplier_id",$f_opts);
		$this->addField($f_supplier_id);
		//********************
		
		//*** Field suppliers_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Поставщик';
		$f_opts['id']="suppliers_ref";
						
		$f_suppliers_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"suppliers_ref",$f_opts);
		$this->addField($f_suppliers_ref);
		//********************
		
		//*** Field carrier_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="carrier_id";
						
		$f_carrier_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"carrier_id",$f_opts);
		$this->addField($f_carrier_id);
		//********************
		
		//*** Field carriers_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Перевозчик';
		$f_opts['id']="carriers_ref";
						
		$f_carriers_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"carriers_ref",$f_opts);
		$this->addField($f_carriers_ref);
		//********************
		
		//*** Field driver ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['id']="driver";
						
		$f_driver=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver",$f_opts);
		$this->addField($f_driver);
		//********************
		
		//*** Field vehicle_plate ***
		$f_opts = array();
		
		$f_opts['alias']='ТС';
		$f_opts['id']="vehicle_plate";
						
		$f_vehicle_plate=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_plate",$f_opts);
		$this->addField($f_vehicle_plate);
		//********************
		
		//*** Field material_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="material_id";
						
		$f_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
		
		//*** Field materials_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Материал';
		$f_opts['id']="materials_ref";
						
		$f_materials_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"materials_ref",$f_opts);
		$this->addField($f_materials_ref);
		//********************
		
		//*** Field cement_silos_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="cement_silos_id";
						
		$f_cement_silos_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cement_silos_id",$f_opts);
		$this->addField($f_cement_silos_id);
		//********************
		
		//*** Field cement_silos_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Силос';
		$f_opts['id']="cement_silos_ref";
						
		$f_cement_silos_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cement_silos_ref",$f_opts);
		$this->addField($f_cement_silos_ref);
		//********************
		
		//*** Field quant_gross ***
		$f_opts = array();
		
		$f_opts['alias']='Вес';
		$f_opts['length']=19;
		$f_opts['id']="quant_gross";
						
		$f_quant_gross=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_gross",$f_opts);
		$this->addField($f_quant_gross);
		//********************
		
		//*** Field quant_net ***
		$f_opts = array();
		
		$f_opts['alias']='Вес чистый';
		$f_opts['length']=19;
		$f_opts['id']="quant_net";
						
		$f_quant_net=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_net",$f_opts);
		$this->addField($f_quant_net);
		//********************
		
		//*** Field store ***
		$f_opts = array();
		
		$f_opts['alias']='Склад';
		$f_opts['id']="store";
						
		$f_store=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"store",$f_opts);
		$this->addField($f_store);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
