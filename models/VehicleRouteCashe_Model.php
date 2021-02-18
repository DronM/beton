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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSONB.php');
 
class VehicleRouteCashe_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("vehicle_route_cashe");
			
		//*** Field tracker_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Трэкер';
		$f_opts['length']=15;
		$f_opts['id']="tracker_id";
						
		$f_tracker_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tracker_id",$f_opts);
		$this->addField($f_tracker_id);
		//********************
		
		//*** Field shipment_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Отгрузка';
		$f_opts['id']="shipment_id";
						
		$f_shipment_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipment_id",$f_opts);
		$this->addField($f_shipment_id);
		//********************
		
		//*** Field vehicle_state ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		
		$f_opts['alias']='Состояние ТС';
		$f_opts['id']="vehicle_state";
						
		$f_vehicle_state=new FieldSQLEnum($this->getDbLink(),$this->getDbName(),$this->getTableName(),"vehicle_state",$f_opts);
		$this->addField($f_vehicle_state);
		//********************
		
		//*** Field update_dt ***
		$f_opts = array();
		
		$f_opts['alias']='Время последнего обновления';
		$f_opts['id']="update_dt";
						
		$f_update_dt=new FieldSQLDateTimeTZ($this->getDbLink(),$this->getDbName(),$this->getTableName(),"update_dt",$f_opts);
		$this->addField($f_update_dt);
		//********************
		
		//*** Field route ***
		$f_opts = array();
		
		$f_opts['alias']='Данные маршрута OSRM';
		$f_opts['id']="route";
						
		$f_route=new FieldSQLJSONB($this->getDbLink(),$this->getDbName(),$this->getTableName(),"route",$f_opts);
		$this->addField($f_route);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
