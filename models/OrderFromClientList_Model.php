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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
 
class OrderFromClientList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("orders_from_clients_list");
			
		//*** Field id ***
		$f_opts = array();
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field date_time ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['id']="date_time";
						
		$f_date_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time",$f_opts);
		$this->addField($f_date_time);
		//********************
		
		//*** Field date_time_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Дата';
		$f_opts['id']="date_time_descr";
						
		$f_date_time_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"date_time_descr",$f_opts);
		$this->addField($f_date_time_descr);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		
		$f_opts['alias']='Клиент';
		$f_opts['id']="name";
						
		$f_name=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field tel ***
		$f_opts = array();
		
		$f_opts['alias']='Телефон';
		$f_opts['length']=15;
		$f_opts['id']="tel";
						
		$f_tel=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel",$f_opts);
		$this->addField($f_tel);
		//********************
		
		//*** Field tel_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Телефон';
		$f_opts['length']=15;
		$f_opts['id']="tel_descr";
						
		$f_tel_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"tel_descr",$f_opts);
		$this->addField($f_tel_descr);
		//********************
		
		//*** Field concrete_type ***
		$f_opts = array();
		
		$f_opts['alias']='Марка';
		$f_opts['length']=15;
		$f_opts['id']="concrete_type";
						
		$f_concrete_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"concrete_type",$f_opts);
		$this->addField($f_concrete_type);
		//********************
		
		//*** Field dest ***
		$f_opts = array();
		
		$f_opts['alias']='Объект';
		$f_opts['id']="dest";
						
		$f_dest=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dest",$f_opts);
		$this->addField($f_dest);
		//********************
		
		//*** Field total ***
		$f_opts = array();
		
		$f_opts['alias']='Сумма';
		$f_opts['length']=15;
		$f_opts['id']="total";
						
		$f_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total",$f_opts);
		$this->addField($f_total);
		//********************
		
		//*** Field total_descr ***
		$f_opts = array();
		
		$f_opts['alias']='Сумма';
		$f_opts['id']="total_descr";
						
		$f_total_descr=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"total_descr",$f_opts);
		$this->addField($f_total_descr);
		//********************
		
		//*** Field quant ***
		$f_opts = array();
		
		$f_opts['alias']='Количество';
		$f_opts['length']=15;
		$f_opts['id']="quant";
						
		$f_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"quant",$f_opts);
		$this->addField($f_quant);
		//********************
		
		//*** Field pump ***
		$f_opts = array();
		
		$f_opts['alias']='Есть насос';
		$f_opts['defaultValue']='false';
		$f_opts['id']="pump";
						
		$f_pump=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"pump",$f_opts);
		$this->addField($f_pump);
		//********************
		
		//*** Field comment_text ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="comment_text";
						
		$f_comment_text=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"comment_text",$f_opts);
		$this->addField($f_comment_text);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
