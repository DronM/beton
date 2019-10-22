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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class LabEntry30DaysList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("lab_entry_30days_2");
			
		//*** Field concrete_type_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="concrete_type_id";
						
		$f_concrete_type_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_id",$f_opts);
		$this->addField($f_concrete_type_id);
		//********************
		
		//*** Field concrete_type_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Марка';
		$f_opts['id']="concrete_type_descr";
						
		$f_concrete_type_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type_descr",$f_opts);
		$this->addField($f_concrete_type_descr);
		//********************
		
		//*** Field cnt ***
		$f_opts = array();
		
		$f_opts['alias']='Всего машин';
		$f_opts['id']="cnt";
						
		$f_cnt=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"cnt",$f_opts);
		$this->addField($f_cnt);
		//********************
		
		//*** Field day_cnt ***
		$f_opts = array();
		
		$f_opts['alias']='Всего по будням';
		$f_opts['id']="day_cnt";
						
		$f_day_cnt=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"day_cnt",$f_opts);
		$this->addField($f_day_cnt);
		//********************
		
		//*** Field selected_cnt ***
		$f_opts = array();
		
		$f_opts['alias']='Отбор по будням';
		$f_opts['id']="selected_cnt";
						
		$f_selected_cnt=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"selected_cnt",$f_opts);
		$this->addField($f_selected_cnt);
		//********************
		
		//*** Field selected_avg_cnt ***
		$f_opts = array();
		
		$f_opts['alias']='Отбор по будням';
		$f_opts['id']="selected_avg_cnt";
						
		$f_selected_avg_cnt=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"selected_avg_cnt",$f_opts);
		$this->addField($f_selected_avg_cnt);
		//********************
		
		//*** Field need_cnt ***
		$f_opts = array();
		
		$f_opts['alias']='Надо еще';
		$f_opts['id']="need_cnt";
						
		$f_need_cnt=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"need_cnt",$f_opts);
		$this->addField($f_need_cnt);
		//********************
		
		//*** Field ok ***
		$f_opts = array();
		
		$f_opts['alias']='ОК';
		$f_opts['id']="ok";
						
		$f_ok=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ok",$f_opts);
		$this->addField($f_ok);
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
		
		//*** Field selected_cnt2 ***
		$f_opts = array();
		
		$f_opts['alias']='Отбор';
		$f_opts['id']="selected_cnt2";
						
		$f_selected_cnt2=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"selected_cnt2",$f_opts);
		$this->addField($f_selected_cnt2);
		//********************
		
		//*** Field ok2 ***
		$f_opts = array();
		
		$f_opts['alias']='ОК';
		$f_opts['id']="ok2";
						
		$f_ok2=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ok2",$f_opts);
		$this->addField($f_ok2);
		//********************
		
		//*** Field p72 ***
		$f_opts = array();
		
		$f_opts['alias']='П7%';
		$f_opts['id']="p72";
						
		$f_p72=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p72",$f_opts);
		$this->addField($f_p72);
		//********************
		
		//*** Field p282 ***
		$f_opts = array();
		
		$f_opts['alias']='П28%';
		$f_opts['id']="p282";
						
		$f_p282=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p282",$f_opts);
		$this->addField($f_p282);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
