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
 
class ConcreteTypeList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("concrete_types_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		
		$f_opts['alias']='Наименование';
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field code_1c ***
		$f_opts = array();
		
		$f_opts['alias']='Код 1С';
		$f_opts['id']="code_1c";
						
		$f_code_1c=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"code_1c",$f_opts);
		$this->addField($f_code_1c);
		//********************
		
		//*** Field pres_norm ***
		$f_opts = array();
		
		$f_opts['alias']='Норма давл.';
		$f_opts['id']="pres_norm";
						
		$f_pres_norm=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pres_norm",$f_opts);
		$this->addField($f_pres_norm);
		//********************
		
		//*** Field mpa_ratio ***
		$f_opts = array();
		
		$f_opts['alias']='Кф.МПА';
		$f_opts['id']="mpa_ratio";
						
		$f_mpa_ratio=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mpa_ratio",$f_opts);
		$this->addField($f_mpa_ratio);
		//********************
		
		//*** Field price ***
		$f_opts = array();
		
		$f_opts['alias']='Цена';
		$f_opts['id']="price";
						
		$f_price=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"price",$f_opts);
		$this->addField($f_price);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
