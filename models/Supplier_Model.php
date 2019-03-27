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
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
 
class Supplier_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("suppliers");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		
		$f_opts['alias']='Наименование';
		$f_opts['length']=100;
		$f_opts['id']="name";
				
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field name_full ***
		$f_opts = array();
		
		$f_opts['alias']='Полное наименование';
		$f_opts['id']="name_full";
				
		$f_name_full=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name_full",$f_opts);
		$this->addField($f_name_full);
		//********************
		
		//*** Field tel ***
		$f_opts = array();
		
		$f_opts['alias']='Мобильный телефон';
		$f_opts['length']=15;
		$f_opts['id']="tel";
				
		$f_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel",$f_opts);
		$this->addField($f_tel);
		//********************
		
		//*** Field tel2 ***
		$f_opts = array();
		
		$f_opts['alias']='Мобильный телефон';
		$f_opts['length']=15;
		$f_opts['id']="tel2";
				
		$f_tel2=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel2",$f_opts);
		$this->addField($f_tel2);
		//********************
		
		//*** Field lang_id ***
		$f_opts = array();
		$f_opts['id']="lang_id";
				
		$f_lang_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"lang_id",$f_opts);
		$this->addField($f_lang_id);
		//********************
		
		//*** Field ext_ref_scales ***
		$f_opts = array();
		$f_opts['length']=36;
		$f_opts['id']="ext_ref_scales";
				
		$f_ext_ref_scales=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ext_ref_scales",$f_opts);
		$this->addField($f_ext_ref_scales);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_name,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
