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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class RAMaterialConsumption_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("ra_material_consumption");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		
		$f_opts['alias']='Код';
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
		
		//*** Field doc_type ***
		$f_opts = array();
		
		$f_opts['alias']='Вид документа';
		$f_opts['id']="doc_type";
				
		$f_doc_type=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_type",$f_opts);
		$this->addField($f_doc_type);
		//********************
		
		//*** Field doc_id ***
		$f_opts = array();
		$f_opts['id']="doc_id";
				
		$f_doc_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_id",$f_opts);
		$this->addField($f_doc_id);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		
		$f_opts['alias']='Бетон';
		$f_opts['id']="concrete_type_id";
				
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field vehicle_id ***
		$f_opts = array();
		
		$f_opts['alias']='ТС';
		$f_opts['id']="vehicle_id";
				
		$f_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_id",$f_opts);
		$this->addField($f_vehicle_id);
		//********************
		
		//*** Field driver_id ***
		$f_opts = array();
		
		$f_opts['alias']='Водитель';
		$f_opts['id']="driver_id";
				
		$f_driver_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"driver_id",$f_opts);
		$this->addField($f_driver_id);
		//********************
		
		//*** Field material_id ***
		$f_opts = array();
		
		$f_opts['alias']='Материал';
		$f_opts['id']="material_id";
				
		$f_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
		
		//*** Field concrete_quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество бетона';
		$f_opts['length']=19;
		$f_opts['id']="concrete_quant";
				
		$f_concrete_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_quant",$f_opts);
		$this->addField($f_concrete_quant);
		//********************
		
		//*** Field material_quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество материалов';
		$f_opts['length']=19;
		$f_opts['id']="material_quant";
				
		$f_material_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_quant",$f_opts);
		$this->addField($f_material_quant);
		//********************
		
		//*** Field material_quant_norm ***
		$f_opts = array();
		
		$f_opts['alias']='Количество материалов';
		$f_opts['length']=19;
		$f_opts['id']="material_quant_norm";
				
		$f_material_quant_norm=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_quant_norm",$f_opts);
		$this->addField($f_material_quant_norm);
		//********************
		
		//*** Field material_quant_corrected ***
		$f_opts = array();
		
		$f_opts['alias']='Количество материалов';
		$f_opts['length']=19;
		$f_opts['id']="material_quant_corrected";
				
		$f_material_quant_corrected=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_quant_corrected",$f_opts);
		$this->addField($f_material_quant_corrected);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_date_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
