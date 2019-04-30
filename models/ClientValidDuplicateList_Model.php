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
 
class ClientValidDuplicateList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("client_valid_duplicates_list");
			
		//*** Field tel ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Телефон';
		$f_opts['id']="tel";
				
		$f_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel",$f_opts);
		$this->addField($f_tel);
		//********************
		
		//*** Field clients ***
		$f_opts = array();
		
		$f_opts['alias']='Клиент';
		$f_opts['id']="clients";
				
		$f_clients=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"clients",$f_opts);
		$this->addField($f_clients);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
