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
 
class RawMaterialConsRateList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("raw_material_cons_rates_list");
			
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
		$f_opts['id']="concrete_type_id";
						
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field concrete_type_descr ***
		$f_opts = array();
		$f_opts['id']="concrete_type_descr";
						
		$f_concrete_type_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_descr",$f_opts);
		$this->addField($f_concrete_type_descr);
		//********************
		
		//*** Field mat1_id ***
		$f_opts = array();
		$f_opts['id']="mat1_id";
						
		$f_mat1_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat1_id",$f_opts);
		$this->addField($f_mat1_id);
		//********************
		
		//*** Field mat2_id ***
		$f_opts = array();
		$f_opts['id']="mat2_id";
						
		$f_mat2_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat2_id",$f_opts);
		$this->addField($f_mat2_id);
		//********************
		
		//*** Field mat3_id ***
		$f_opts = array();
		$f_opts['id']="mat3_id";
						
		$f_mat3_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat3_id",$f_opts);
		$this->addField($f_mat3_id);
		//********************
		
		//*** Field mat4_id ***
		$f_opts = array();
		$f_opts['id']="mat4_id";
						
		$f_mat4_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat4_id",$f_opts);
		$this->addField($f_mat4_id);
		//********************
		
		//*** Field mat5_id ***
		$f_opts = array();
		$f_opts['id']="mat5_id";
						
		$f_mat5_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat5_id",$f_opts);
		$this->addField($f_mat5_id);
		//********************
		
		//*** Field mat6_id ***
		$f_opts = array();
		$f_opts['id']="mat6_id";
						
		$f_mat6_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat6_id",$f_opts);
		$this->addField($f_mat6_id);
		//********************
		
		//*** Field mat7_id ***
		$f_opts = array();
		$f_opts['id']="mat7_id";
						
		$f_mat7_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat7_id",$f_opts);
		$this->addField($f_mat7_id);
		//********************
		
		//*** Field mat8_id ***
		$f_opts = array();
		$f_opts['id']="mat8_id";
						
		$f_mat8_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat8_id",$f_opts);
		$this->addField($f_mat8_id);
		//********************
		
		//*** Field mat9_id ***
		$f_opts = array();
		$f_opts['id']="mat9_id";
						
		$f_mat9_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat9_id",$f_opts);
		$this->addField($f_mat9_id);
		//********************
		
		//*** Field mat10_id ***
		$f_opts = array();
		$f_opts['id']="mat10_id";
						
		$f_mat10_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat10_id",$f_opts);
		$this->addField($f_mat10_id);
		//********************
		
		//*** Field mat1_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat1_rate";
						
		$f_mat1_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat1_rate",$f_opts);
		$this->addField($f_mat1_rate);
		//********************
		
		//*** Field mat2_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat2_rate";
						
		$f_mat2_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat2_rate",$f_opts);
		$this->addField($f_mat2_rate);
		//********************
		
		//*** Field mat3_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat3_rate";
						
		$f_mat3_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat3_rate",$f_opts);
		$this->addField($f_mat3_rate);
		//********************
		
		//*** Field mat4_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat4_rate";
						
		$f_mat4_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat4_rate",$f_opts);
		$this->addField($f_mat4_rate);
		//********************
		
		//*** Field mat5_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat5_rate";
						
		$f_mat5_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat5_rate",$f_opts);
		$this->addField($f_mat5_rate);
		//********************
		
		//*** Field mat6_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat6_rate";
						
		$f_mat6_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat6_rate",$f_opts);
		$this->addField($f_mat6_rate);
		//********************
		
		//*** Field mat7_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat7_rate";
						
		$f_mat7_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat7_rate",$f_opts);
		$this->addField($f_mat7_rate);
		//********************
		
		//*** Field mat8_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat8_rate";
						
		$f_mat8_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat8_rate",$f_opts);
		$this->addField($f_mat8_rate);
		//********************
		
		//*** Field mat9_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat9_rate";
						
		$f_mat9_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat9_rate",$f_opts);
		$this->addField($f_mat9_rate);
		//********************
		
		//*** Field mat10_rate ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="mat10_rate";
						
		$f_mat10_rate=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mat10_rate",$f_opts);
		$this->addField($f_mat10_rate);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
