<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
 
class VehFeaturesOnDateList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("");
			
		//*** Field feature ***
		$f_opts = array();
		$f_opts['id']="feature";
						
		$f_feature=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"feature",$f_opts);
		$this->addField($f_feature);
		//********************
		
		//*** Field cnt ***
		$f_opts = array();
		$f_opts['id']="cnt";
						
		$f_cnt=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cnt",$f_opts);
		$this->addField($f_cnt);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
