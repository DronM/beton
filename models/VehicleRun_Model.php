<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class VehicleRun_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("");
			
		//*** Field veh_id ***
		$f_opts = array();
		$f_opts['id']="veh_id";
						
		$f_veh_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"veh_id",$f_opts);
		$this->addField($f_veh_id);
		//********************
		
		//*** Field st_free_start ***
		$f_opts = array();
		$f_opts['id']="st_free_start";
						
		$f_st_free_start=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"st_free_start",$f_opts);
		$this->addField($f_st_free_start);
		//********************
		
		//*** Field st_assigned ***
		$f_opts = array();
		$f_opts['id']="st_assigned";
						
		$f_st_assigned=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"st_assigned",$f_opts);
		$this->addField($f_st_assigned);
		//********************
		
		//*** Field st_shipped ***
		$f_opts = array();
		$f_opts['id']="st_shipped";
						
		$f_st_shipped=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"st_shipped",$f_opts);
		$this->addField($f_st_shipped);
		//********************
		
		//*** Field st_at_dest ***
		$f_opts = array();
		$f_opts['id']="st_at_dest";
						
		$f_st_at_dest=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"st_at_dest",$f_opts);
		$this->addField($f_st_at_dest);
		//********************
		
		//*** Field st_left_for_base ***
		$f_opts = array();
		$f_opts['id']="st_left_for_base";
						
		$f_st_left_for_base=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"st_left_for_base",$f_opts);
		$this->addField($f_st_left_for_base);
		//********************
		
		//*** Field st_free_end ***
		$f_opts = array();
		$f_opts['id']="st_free_end";
						
		$f_st_free_end=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"st_free_end",$f_opts);
		$this->addField($f_st_free_end);
		//********************
		
		//*** Field destinations_ref ***
		$f_opts = array();
		$f_opts['id']="destinations_ref";
						
		$f_destinations_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"destinations_ref",$f_opts);
		$this->addField($f_destinations_ref);
		//********************
		
		//*** Field run_time ***
		$f_opts = array();
		$f_opts['id']="run_time";
						
		$f_run_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"run_time",$f_opts);
		$this->addField($f_run_time);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
