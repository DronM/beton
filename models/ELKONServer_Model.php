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
 
class ELKONServer_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("elkon_servers");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field data_base_name ***
		$f_opts = array();
		
		$f_opts['alias']='Наименование базы данных';
		$f_opts['length']=150;
		$f_opts['id']="data_base_name";
						
		$f_data_base_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"data_base_name",$f_opts);
		$this->addField($f_data_base_name);
		//********************
		
		//*** Field user_name ***
		$f_opts = array();
		
		$f_opts['alias']='Имя пользователя';
		$f_opts['length']=150;
		$f_opts['id']="user_name";
						
		$f_user_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_name",$f_opts);
		$this->addField($f_user_name);
		//********************
		
		//*** Field user_password ***
		$f_opts = array();
		
		$f_opts['alias']='Пароль пользователя';
		$f_opts['length']=150;
		$f_opts['id']="user_password";
						
		$f_user_password=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_password",$f_opts);
		$this->addField($f_user_password);
		//********************
		
		//*** Field host ***
		$f_opts = array();
		
		$f_opts['alias']='IP хоста';
		$f_opts['length']=150;
		$f_opts['id']="host";
						
		$f_host=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"host",$f_opts);
		$this->addField($f_host);
		//********************
		
		//*** Field port ***
		$f_opts = array();
		
		$f_opts['alias']='Порт хоста';
		$f_opts['id']="port";
						
		$f_port=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"port",$f_opts);
		$this->addField($f_port);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
