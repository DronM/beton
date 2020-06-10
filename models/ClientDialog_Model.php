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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class ClientDialog_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("clients_dialog");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field name_full ***
		$f_opts = array();
		
		$f_opts['alias']='Полное наименование';
		$f_opts['id']="name_full";
						
		$f_name_full=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name_full",$f_opts);
		$this->addField($f_name_full);
		//********************
		
		//*** Field manager_comment ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="manager_comment";
						
		$f_manager_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"manager_comment",$f_opts);
		$this->addField($f_manager_comment);
		//********************
		
		//*** Field phone_cel ***
		$f_opts = array();
		$f_opts['id']="phone_cel";
						
		$f_phone_cel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"phone_cel",$f_opts);
		$this->addField($f_phone_cel);
		//********************
		
		//*** Field client_types_ref ***
		$f_opts = array();
		$f_opts['id']="client_types_ref";
						
		$f_client_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_types_ref",$f_opts);
		$this->addField($f_client_types_ref);
		//********************
		
		//*** Field client_come_from_ref ***
		$f_opts = array();
		$f_opts['id']="client_come_from_ref";
						
		$f_client_come_from_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_come_from_ref",$f_opts);
		$this->addField($f_client_come_from_ref);
		//********************
		
		//*** Field client_kind ***
		$f_opts = array();
		$f_opts['id']="client_kind";
						
		$f_client_kind=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_kind",$f_opts);
		$this->addField($f_client_kind);
		//********************
		
		//*** Field users_ref ***
		$f_opts = array();
		$f_opts['id']="users_ref";
						
		$f_users_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"users_ref",$f_opts);
		$this->addField($f_users_ref);
		//********************
		
		//*** Field accounts_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Аккаунт';
		$f_opts['id']="accounts_ref";
						
		$f_accounts_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"accounts_ref",$f_opts);
		$this->addField($f_accounts_ref);
		//********************
		
		//*** Field account_from_date ***
		$f_opts = array();
		$f_opts['id']="account_from_date";
						
		$f_account_from_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"account_from_date",$f_opts);
		$this->addField($f_account_from_date);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
