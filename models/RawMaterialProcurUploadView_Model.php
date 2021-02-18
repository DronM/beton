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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class RawMaterialProcurUploadView_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("raw_material_procur_upload_view");
			
		//*** Field date_time ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field descr ***
		$f_opts = array();
		$f_opts['id']="descr";
						
		$f_descr=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"descr",$f_opts);
		$this->addField($f_descr);
		//********************
		
		//*** Field result ***
		$f_opts = array();
		$f_opts['id']="result";
						
		$f_result=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"result",$f_opts);
		$this->addField($f_result);
		//********************
		
		//*** Field doc_count ***
		$f_opts = array();
		$f_opts['id']="doc_count";
						
		$f_doc_count=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"doc_count",$f_opts);
		$this->addField($f_doc_count);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
