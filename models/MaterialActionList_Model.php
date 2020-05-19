<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class MaterialActionList_Model extends {
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("material_actions");
			
		//*** Field is_cement ***
		$f_opts = array();
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="is_cement";
						
		$f_is_cement=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"is_cement",$f_opts);
		$this->addField($f_is_cement);
		//********************
		
		//*** Field material_name ***
		$f_opts = array();
		
		$f_opts['alias']='Материал';
		$f_opts['id']="material_name";
						
		$f_material_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"material_name",$f_opts);
		$this->addField($f_material_name);
		//********************
		
		//*** Field quant_start ***
		$f_opts = array();
		
		$f_opts['alias']='Начальный остаток';
		$f_opts['id']="quant_start";
						
		$f_quant_start=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_start",$f_opts);
		$this->addField($f_quant_start);
		//********************
		
		//*** Field quant_deb ***
		$f_opts = array();
		
		$f_opts['alias']='Приход';
		$f_opts['id']="quant_deb";
						
		$f_quant_deb=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_deb",$f_opts);
		$this->addField($f_quant_deb);
		//********************
		
		//*** Field quant_kred ***
		$f_opts = array();
		
		$f_opts['alias']='Расход';
		$f_opts['id']="quant_kred";
						
		$f_quant_kred=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_kred",$f_opts);
		$this->addField($f_quant_kred);
		//********************
		
		//*** Field quant_correction ***
		$f_opts = array();
		
		$f_opts['alias']='Корректировка';
		$f_opts['id']="quant_correction";
						
		$f_quant_correction=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_correction",$f_opts);
		$this->addField($f_quant_correction);
		//********************
		
		//*** Field quant_end ***
		$f_opts = array();
		
		$f_opts['alias']='Конечный остаток';
		$f_opts['id']="quant_end";
						
		$f_quant_end=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant_end",$f_opts);
		$this->addField($f_quant_end);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
