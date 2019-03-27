<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
 
class AstCallClientShipHistList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("ast_calls_client_hist_list");
			
		//*** Field unique_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="unique_id";
				
		$f_unique_id=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unique_id",$f_opts);
		$this->addField($f_unique_id);
		//********************
		
		//*** Field dt_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Время';
		$f_opts['id']="dt_descr";
				
		$f_dt_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt_descr",$f_opts);
		$this->addField($f_dt_descr);
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
