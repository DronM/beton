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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
 
class LoginDeviceBan_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("login_device_bans");
			
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field hash ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=32;
		$f_opts['id']="hash";
						
		$f_hash=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"hash",$f_opts);
		$this->addField($f_hash);
		//********************
		
		//*** Field create_dt ***
		$f_opts = array();
		
		$f_opts['alias']='Дата создания';
		$f_opts['defaultValue']='CURRENT_TIMESTAMP';
		$f_opts['id']="create_dt";
						
		$f_create_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"create_dt",$f_opts);
		$this->addField($f_create_dt);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
