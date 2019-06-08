<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
 
class LabEntryDetail_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("lab_entry_details");
			
		//*** Field shipment_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		
		$f_opts['alias']='Отгрузка';
		$f_opts['id']="shipment_id";
						
		$f_shipment_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipment_id",$f_opts);
		$this->addField($f_shipment_id);
		//********************
		
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field ok ***
		$f_opts = array();
		
		$f_opts['alias']='ОК';
		$f_opts['id']="ok";
						
		$f_ok=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ok",$f_opts);
		$this->addField($f_ok);
		//********************
		
		//*** Field weight ***
		$f_opts = array();
		
		$f_opts['alias']='Масса';
		$f_opts['id']="weight";
						
		$f_weight=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"weight",$f_opts);
		$this->addField($f_weight);
		//********************
		
		//*** Field kn ***
		$f_opts = array();
		
		$f_opts['alias']='КН';
		$f_opts['id']="kn";
						
		$f_kn=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"kn",$f_opts);
		$this->addField($f_kn);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
