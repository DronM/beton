<?php
/**
 *
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/models/Model_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 *
 */

require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class Shift_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("shifts");
			
		//*** Field date ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		
		$f_opts['alias']='Дата';
		$f_opts['id']="date";
						
		$f_date=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date",$f_opts);
		$this->addField($f_date);
		//********************
		
		//*** Field closed ***
		$f_opts = array();
		$f_opts['primaryKey'] = FALSE;
		$f_opts['autoInc']=FALSE;
		
		$f_opts['alias']='Закрыта';
		$f_opts['id']="closed";
						
		$f_closed=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"closed",$f_opts);
		$this->addField($f_closed);
		//********************
		
		//*** Field close_date_time ***
		$f_opts = array();
		$f_opts['primaryKey'] = FALSE;
		$f_opts['autoInc']=FALSE;
		
		$f_opts['alias']='Дата закрытия';
		$f_opts['id']="close_date_time";
						
		$f_close_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"close_date_time",$f_opts);
		$this->addField($f_close_date_time);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
