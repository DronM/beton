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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLArray.php');
 
class ProductionSiteForEditList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("production_sites_for_edit_list");
			
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
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=100;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field elkon_connection ***
		$f_opts = array();
		$f_opts['id']="elkon_connection";
						
		$f_elkon_connection=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"elkon_connection",$f_opts);
		$this->addField($f_elkon_connection);
		//********************
		
		//*** Field active ***
		$f_opts = array();
		
		$f_opts['alias']='Активен';
		$f_opts['id']="active";
						
		$f_active=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"active",$f_opts);
		$this->addField($f_active);
		//********************
		
		//*** Field last_elkon_production_id ***
		$f_opts = array();
		$f_opts['id']="last_elkon_production_id";
						
		$f_last_elkon_production_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"last_elkon_production_id",$f_opts);
		$this->addField($f_last_elkon_production_id);
		//********************
		
		//*** Field missing_elkon_production_ids ***
		$f_opts = array();
		$f_opts['id']="missing_elkon_production_ids";
						
		$f_missing_elkon_production_ids=new FieldSQLArray($this->getDbLink(),$this->getDbName(),$this->getTableName(),"missing_elkon_production_ids",$f_opts);
		$this->addField($f_missing_elkon_production_ids);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_name,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
