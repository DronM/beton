<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class CarTrackingMalfucntion_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("car_tracking_malfucntions");
			
		//*** Field dt ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="dt";
				
		$f_dt=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dt",$f_opts);
		$this->addField($f_dt);
		//********************
		
		//*** Field tel ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=15;
		$f_opts['id']="tel";
				
		$f_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel",$f_opts);
		$this->addField($f_tel);
		//********************
		
		//*** Field tracker_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['length']=15;
		$f_opts['id']="tracker_id";
				
		$f_tracker_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tracker_id",$f_opts);
		$this->addField($f_tracker_id);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_dt,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
