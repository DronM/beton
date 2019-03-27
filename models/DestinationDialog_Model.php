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
 
class DestinationDialog_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("destinations_dialog");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		$f_opts['id']="name";
				
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field distance ***
		$f_opts = array();
		$f_opts['id']="distance";
				
		$f_distance=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"distance",$f_opts);
		$this->addField($f_distance);
		//********************
		
		//*** Field time_route ***
		$f_opts = array();
		$f_opts['id']="time_route";
				
		$f_time_route=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"time_route",$f_opts);
		$this->addField($f_time_route);
		//********************
		
		//*** Field price ***
		$f_opts = array();
		$f_opts['id']="price";
				
		$f_price=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"price",$f_opts);
		$this->addField($f_price);
		//********************
		
		//*** Field zone_str ***
		$f_opts = array();
		$f_opts['id']="zone_str";
				
		$f_zone_str=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"zone_str",$f_opts);
		$this->addField($f_zone_str);
		//********************
		
		//*** Field zone_center_str ***
		$f_opts = array();
		$f_opts['id']="zone_center_str";
				
		$f_zone_center_str=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"zone_center_str",$f_opts);
		$this->addField($f_zone_center_str);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
