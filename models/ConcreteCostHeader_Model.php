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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLArray.php');
 
class ConcreteCostHeader_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("concrete_costs_h");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['id']="date";
						
		$f_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date",$f_opts);
		$this->addField($f_date);
		//********************
		
		//*** Field clients_ar ***
		$f_opts = array();
		$f_opts['id']="clients_ar";
						
		$f_clients_ar=new FieldSQLArray($this->getDbLink(),$this->getDbName(),$this->getTableName(),"clients_ar",$f_opts);
		$this->addField($f_clients_ar);
		//********************
		
		//*** Field clients_list ***
		$f_opts = array();
		$f_opts['id']="clients_list";
						
		$f_clients_list=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"clients_list",$f_opts);
		$this->addField($f_clients_list);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_date,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
