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
 
class EmailTemplateList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("email_templates_list");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="id";
				
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field email_type ***
		$f_opts = array();
		$f_opts['id']="email_type";
				
		$f_email_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"email_type",$f_opts);
		$this->addField($f_email_type);
		//********************
		
		//*** Field email_type_descr ***
		$f_opts = array();
		$f_opts['id']="email_type_descr";
				
		$f_email_type_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"email_type_descr",$f_opts);
		$this->addField($f_email_type_descr);
		//********************
		
		//*** Field template ***
		$f_opts = array();
		$f_opts['id']="template";
				
		$f_template=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"template",$f_opts);
		$this->addField($f_template);
		//********************
		
		//*** Field fields ***
		$f_opts = array();
		$f_opts['id']="fields";
				
		$f_fields=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"fields",$f_opts);
		$this->addField($f_fields);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
