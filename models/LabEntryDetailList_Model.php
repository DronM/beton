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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class LabEntryDetailList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("lab_entry_detail_list");
			
		//*** Field shipment_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="shipment_id";
						
		$f_shipment_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipment_id",$f_opts);
		$this->addField($f_shipment_id);
		//********************
		
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field code ***
		$f_opts = array();
		$f_opts['id']="code";
						
		$f_code=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"code",$f_opts);
		$this->addField($f_code);
		//********************
		
		//*** Field ship_date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['id']="ship_date_time";
						
		$f_ship_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ship_date_time",$f_opts);
		$this->addField($f_ship_date_time);
		//********************
		
		//*** Field concrete_types_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Марка';
		$f_opts['id']="concrete_types_ref";
						
		$f_concrete_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_types_ref",$f_opts);
		$this->addField($f_concrete_types_ref);
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
		
		//*** Field p7 ***
		$f_opts = array();
		
		$f_opts['alias']='П7%';
		$f_opts['id']="p7";
						
		$f_p7=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p7",$f_opts);
		$this->addField($f_p7);
		//********************
		
		//*** Field p28 ***
		$f_opts = array();
		
		$f_opts['alias']='П28%';
		$f_opts['id']="p28";
						
		$f_p28=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p28",$f_opts);
		$this->addField($f_p28);
		//********************
		
		//*** Field p_date ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['id']="p_date";
						
		$f_p_date=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_date",$f_opts);
		$this->addField($f_p_date);
		//********************
		
		//*** Field kn ***
		$f_opts = array();
		$f_opts['id']="kn";
						
		$f_kn=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"kn",$f_opts);
		$this->addField($f_kn);
		//********************
		
		//*** Field mpa ***
		$f_opts = array();
		$f_opts['id']="mpa";
						
		$f_mpa=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mpa",$f_opts);
		$this->addField($f_mpa);
		//********************
		
		//*** Field mpa_avg ***
		$f_opts = array();
		$f_opts['id']="mpa_avg";
						
		$f_mpa_avg=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"mpa_avg",$f_opts);
		$this->addField($f_mpa_avg);
		//********************
		
		//*** Field pres_norm ***
		$f_opts = array();
		$f_opts['id']="pres_norm";
						
		$f_pres_norm=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pres_norm",$f_opts);
		$this->addField($f_pres_norm);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
