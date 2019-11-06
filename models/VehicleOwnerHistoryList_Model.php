<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class VehicleOwnerHistoryList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("vehicle_owner_history_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field vehicle_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="vehicle_id";
						
		$f_vehicle_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_id",$f_opts);
		$this->addField($f_vehicle_id);
		//********************
		
		//*** Field vehicles_ref ***
		$f_opts = array();
		$f_opts['id']="vehicles_ref";
						
		$f_vehicles_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicles_ref",$f_opts);
		$this->addField($f_vehicles_ref);
		//********************
		
		//*** Field vehicle_owner_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="vehicle_owner_id";
						
		$f_vehicle_owner_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_owner_id",$f_opts);
		$this->addField($f_vehicle_owner_id);
		//********************
		
		//*** Field vehicle_owners_ref ***
		$f_opts = array();
		$f_opts['id']="vehicle_owners_ref";
						
		$f_vehicle_owners_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_owners_ref",$f_opts);
		$this->addField($f_vehicle_owners_ref);
		//********************
		
		//*** Field date_from ***
		$f_opts = array();
		$f_opts['id']="date_from";
						
		$f_date_from=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_from",$f_opts);
		$this->addField($f_date_from);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
