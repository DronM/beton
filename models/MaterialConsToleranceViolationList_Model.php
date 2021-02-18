<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class MaterialConsToleranceViolationList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("material_cons_tolerance_violation_list");
			
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Период';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field material_id ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="material_id";
						
		$f_material_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_id",$f_opts);
		$this->addField($f_material_id);
		//********************
		
		//*** Field materials_ref ***
		$f_opts = array();
		
		$f_opts['alias']='Материал';
		$f_opts['id']="materials_ref";
						
		$f_materials_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"materials_ref",$f_opts);
		$this->addField($f_materials_ref);
		//********************
		
		//*** Field material_ord ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="material_ord";
						
		$f_material_ord=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_ord",$f_opts);
		$this->addField($f_material_ord);
		//********************
		
		//*** Field norm_quant ***
		$f_opts = array();
		
		$f_opts['alias']='Расход нормативный';
		$f_opts['id']="norm_quant";
						
		$f_norm_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"norm_quant",$f_opts);
		$this->addField($f_norm_quant);
		//********************
		
		//*** Field fact_quant ***
		$f_opts = array();
		
		$f_opts['alias']='Расход фактический';
		$f_opts['id']="fact_quant";
						
		$f_fact_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fact_quant",$f_opts);
		$this->addField($f_fact_quant);
		//********************
		
		//*** Field diff_quant ***
		$f_opts = array();
		
		$f_opts['alias']='Отклонение (факт-норм)';
		$f_opts['id']="diff_quant";
						
		$f_diff_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"diff_quant",$f_opts);
		$this->addField($f_diff_quant);
		//********************
		
		//*** Field diff_percent ***
		$f_opts = array();
		
		$f_opts['alias']='Отклонение, %';
		$f_opts['id']="diff_percent";
						
		$f_diff_percent=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"diff_percent",$f_opts);
		$this->addField($f_diff_percent);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
