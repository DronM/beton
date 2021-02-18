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
 
class AstCallClientCallHistoryList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("ast_calls_client_history_list");
			
		//*** Field unique_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="unique_id";
						
		$f_unique_id=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unique_id",$f_opts);
		$this->addField($f_unique_id);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		$f_opts['id']="client_id";
						
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field dt ***
		$f_opts = array();
		
		$f_opts['alias']='Время';
		$f_opts['id']="dt";
						
		$f_dt=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt",$f_opts);
		$this->addField($f_dt);
		//********************
		
		//*** Field manager_comment ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="manager_comment";
						
		$f_manager_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"manager_comment",$f_opts);
		$this->addField($f_manager_comment);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
