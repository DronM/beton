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
 
class RawMaterialConsRate_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("raw_material_cons_rates");
			
		//*** Field rate_date_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="rate_date_id";
						
		$f_rate_date_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"rate_date_id",$f_opts);
		$this->addField($f_rate_date_id);
		//********************
		
		//*** Field concrete_type_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Марка бетона';
		$f_opts['id']="concrete_type_id";
						
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field raw_material_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Материал';
		$f_opts['id']="raw_material_id";
						
		$f_raw_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"raw_material_id",$f_opts);
		$this->addField($f_raw_material_id);
		//********************
		
		//*** Field rate ***
		$f_opts = array();
		
		$f_opts['alias']='Расход';
		$f_opts['length']=19;
		$f_opts['id']="rate";
						
		$f_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"rate",$f_opts);
		$this->addField($f_rate);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
