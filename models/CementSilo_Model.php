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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class CementSilo_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("cement_silos");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field production_site_id ***
		$f_opts = array();
		$f_opts['id']="production_site_id";
						
		$f_production_site_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_site_id",$f_opts);
		$this->addField($f_production_site_id);
		//********************
		
		//*** Field production_descr ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="production_descr";
						
		$f_production_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"production_descr",$f_opts);
		$this->addField($f_production_descr);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field weigh_app_name ***
		$f_opts = array();
		$f_opts['length']=100;
		$f_opts['id']="weigh_app_name";
						
		$f_weigh_app_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"weigh_app_name",$f_opts);
		$this->addField($f_weigh_app_name);
		//********************
		
		//*** Field load_capacity ***
		$f_opts = array();
		$f_opts['length']=19;
		$f_opts['id']="load_capacity";
						
		$f_load_capacity=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"load_capacity",$f_opts);
		$this->addField($f_load_capacity);
		//********************
		
		//*** Field visible ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="visible";
						
		$f_visible=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"visible",$f_opts);
		$this->addField($f_visible);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
