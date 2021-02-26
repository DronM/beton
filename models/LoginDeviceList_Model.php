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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class LoginDeviceList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("login_devices_list");
			
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field user_agent ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="user_agent";
						
		$f_user_agent=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_agent",$f_opts);
		$this->addField($f_user_agent);
		//********************
		
		//*** Field user_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Имя пользователя';
		$f_opts['id']="user_descr";
						
		$f_user_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_descr",$f_opts);
		$this->addField($f_user_descr);
		//********************
		
		//*** Field date_time_in ***
		$f_opts = array();
		
		$f_opts['alias']='Дата входа';
		$f_opts['id']="date_time_in";
						
		$f_date_time_in=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time_in",$f_opts);
		$this->addField($f_date_time_in);
		//********************
		
		//*** Field banned ***
		$f_opts = array();
		
		$f_opts['alias']='Вход запрещен';
		$f_opts['id']="banned";
						
		$f_banned=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"banned",$f_opts);
		$this->addField($f_banned);
		//********************
		
		//*** Field ban_hash ***
		$f_opts = array();
		$f_opts['id']="ban_hash";
						
		$f_ban_hash=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ban_hash",$f_opts);
		$this->addField($f_ban_hash);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
