<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class RawMaterialConsRateDateList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("raw_material_cons_rates_dates_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field dt ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="dt";
				
		$f_dt=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt",$f_opts);
		$this->addField($f_dt);
		//********************
		
		//*** Field period ***
		$f_opts = array();
		
		$f_opts['alias']='Период';
		$f_opts['id']="period";
				
		$f_period=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"period",$f_opts);
		$this->addField($f_period);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="name";
				
		$f_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
