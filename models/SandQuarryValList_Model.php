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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
 
class SandQuarryValList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("sand_quarry_vals_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field day ***
		$f_opts = array();
		$f_opts['id']="day";
						
		$f_day=new FieldSQLDate($this->getDbLink(),$this->getDbName(),$this->getTableName(),"day",$f_opts);
		$this->addField($f_day);
		//********************
		
		//*** Field day_descr ***
		$f_opts = array();
		$f_opts['id']="day_descr";
						
		$f_day_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"day_descr",$f_opts);
		$this->addField($f_day_descr);
		//********************
		
		//*** Field quarry_id ***
		$f_opts = array();
		$f_opts['id']="quarry_id";
						
		$f_quarry_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quarry_id",$f_opts);
		$this->addField($f_quarry_id);
		//********************
		
		//*** Field quarry_descr ***
		$f_opts = array();
		$f_opts['id']="quarry_descr";
						
		$f_quarry_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quarry_descr",$f_opts);
		$this->addField($f_quarry_descr);
		//********************
		
		//*** Field v_mkr ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_mkr";
						
		$f_v_mkr=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_mkr",$f_opts);
		$this->addField($f_v_mkr);
		//********************
		
		//*** Field v_2_5 ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_2_5";
						
		$f_v_2_5=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_2_5",$f_opts);
		$this->addField($f_v_2_5);
		//********************
		
		//*** Field v_1_25 ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_1_25";
						
		$f_v_1_25=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_1_25",$f_opts);
		$this->addField($f_v_1_25);
		//********************
		
		//*** Field v_0_63 ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_0_63";
						
		$f_v_0_63=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_0_63",$f_opts);
		$this->addField($f_v_0_63);
		//********************
		
		//*** Field v_0_16 ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_0_16";
						
		$f_v_0_16=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_0_16",$f_opts);
		$this->addField($f_v_0_16);
		//********************
		
		//*** Field v_0_05 ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_0_05";
						
		$f_v_0_05=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_0_05",$f_opts);
		$this->addField($f_v_0_05);
		//********************
		
		//*** Field v_nasip ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_nasip";
						
		$f_v_nasip=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_nasip",$f_opts);
		$this->addField($f_v_nasip);
		//********************
		
		//*** Field v_istin ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_istin";
						
		$f_v_istin=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_istin",$f_opts);
		$this->addField($f_v_istin);
		//********************
		
		//*** Field v_humid ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_humid";
						
		$f_v_humid=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_humid",$f_opts);
		$this->addField($f_v_humid);
		//********************
		
		//*** Field v_dust ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_dust";
						
		$f_v_dust=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_dust",$f_opts);
		$this->addField($f_v_dust);
		//********************
		
		//*** Field v_void ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="v_void";
						
		$f_v_void=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_void",$f_opts);
		$this->addField($f_v_void);
		//********************
		
		//*** Field v_comment ***
		$f_opts = array();
		$f_opts['id']="v_comment";
						
		$f_v_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"v_comment",$f_opts);
		$this->addField($f_v_comment);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
