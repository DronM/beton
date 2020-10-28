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
 
class LabEntry_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("lab_entries");
			
		//*** Field shipment_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Отгрузка';
		$f_opts['id']="shipment_id";
						
		$f_shipment_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipment_id",$f_opts);
		$this->addField($f_shipment_id);
		//********************
		
		//*** Field samples ***
		$f_opts = array();
		
		$f_opts['alias']='Подборы';
		$f_opts['id']="samples";
						
		$f_samples=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"samples",$f_opts);
		$this->addField($f_samples);
		//********************
		
		//*** Field materials ***
		$f_opts = array();
		
		$f_opts['alias']='Материалы';
		$f_opts['id']="materials";
						
		$f_materials=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"materials",$f_opts);
		$this->addField($f_materials);
		//********************
		
		//*** Field ok2 ***
		$f_opts = array();
		
		$f_opts['alias']='OK2';
		$f_opts['id']="ok2";
						
		$f_ok2=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ok2",$f_opts);
		$this->addField($f_ok2);
		//********************
		
		//*** Field time ***
		$f_opts = array();
		
		$f_opts['alias']='Время';
		$f_opts['id']="time";
						
		$f_time=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"time",$f_opts);
		$this->addField($f_time);
		//********************
		
		//*** Field rate_date_id ***
		$f_opts = array();
		
		$f_opts['alias']='Подбор';
		$f_opts['id']="rate_date_id";
						
		$f_rate_date_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"rate_date_id",$f_opts);
		$this->addField($f_rate_date_id);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
