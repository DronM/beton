<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class OrderPump_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("order_pumps");
			
		//*** Field order_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['id']="order_id";
						
		$f_order_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"order_id",$f_opts);
		$this->addField($f_order_id);
		//********************
		
		//*** Field viewed ***
		$f_opts = array();
		$f_opts['defaultValue']='TRUE';
		$f_opts['id']="viewed";
						
		$f_viewed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"viewed",$f_opts);
		$this->addField($f_viewed);
		//********************
		
		//*** Field comment ***
		$f_opts = array();
		$f_opts['id']="comment";
						
		$f_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment",$f_opts);
		$this->addField($f_comment);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
