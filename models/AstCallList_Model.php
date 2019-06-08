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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLJSON.php');
 
class AstCallList_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		$this->setDbName("public");
		
		$this->setTableName("ast_calls_new_list");
			
		//*** Field unique_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['sysCol']=TRUE;
		$f_opts['id']="unique_id";
						
		$f_unique_id=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"unique_id",$f_opts);
		$this->addField($f_unique_id);
		//********************
		
		//*** Field client_id ***
		$f_opts = array();
		$f_opts['id']="client_id";
						
		$f_client_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_id",$f_opts);
		$this->addField($f_client_id);
		//********************
		
		//*** Field clients_ref ***
		$f_opts = array();
		$f_opts['id']="clients_ref";
						
		$f_clients_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"clients_ref",$f_opts);
		$this->addField($f_clients_ref);
		//********************
		
		//*** Field user_id ***
		$f_opts = array();
		$f_opts['id']="user_id";
						
		$f_user_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"user_id",$f_opts);
		$this->addField($f_user_id);
		//********************
		
		//*** Field users_ref ***
		$f_opts = array();
		$f_opts['id']="users_ref";
						
		$f_users_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"users_ref",$f_opts);
		$this->addField($f_users_ref);
		//********************
		
		//*** Field call_type ***
		$f_opts = array();
		$f_opts['id']="call_type";
						
		$f_call_type=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"call_type",$f_opts);
		$this->addField($f_call_type);
		//********************
		
		//*** Field start_time ***
		$f_opts = array();
		$f_opts['id']="start_time";
						
		$f_start_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"start_time",$f_opts);
		$this->addField($f_start_time);
		//********************
		
		//*** Field end_time ***
		$f_opts = array();
		$f_opts['id']="end_time";
						
		$f_end_time=new FieldSQLDateTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"end_time",$f_opts);
		$this->addField($f_end_time);
		//********************
		
		//*** Field dur_time ***
		$f_opts = array();
		$f_opts['id']="dur_time";
						
		$f_dur_time=new FieldSQLTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"dur_time",$f_opts);
		$this->addField($f_dur_time);
		//********************
		
		//*** Field manager_comment ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="manager_comment";
						
		$f_manager_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"manager_comment",$f_opts);
		$this->addField($f_manager_comment);
		//********************
		
		//*** Field client_comment ***
		$f_opts = array();
		$f_opts['id']="client_comment";
						
		$f_client_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_comment",$f_opts);
		$this->addField($f_client_comment);
		//********************
		
		//*** Field client_create_date ***
		$f_opts = array();
		$f_opts['id']="client_create_date";
						
		$f_client_create_date=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_create_date",$f_opts);
		$this->addField($f_client_create_date);
		//********************
		
		//*** Field ours ***
		$f_opts = array();
		$f_opts['id']="ours";
						
		$f_ours=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ours",$f_opts);
		$this->addField($f_ours);
		//********************
		
		//*** Field client_type_id ***
		$f_opts = array();
		$f_opts['id']="client_type_id";
						
		$f_client_type_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_type_id",$f_opts);
		$this->addField($f_client_type_id);
		//********************
		
		//*** Field client_types_ref ***
		$f_opts = array();
		$f_opts['id']="client_types_ref";
						
		$f_client_types_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_types_ref",$f_opts);
		$this->addField($f_client_types_ref);
		//********************
		
		//*** Field client_come_from_id ***
		$f_opts = array();
		$f_opts['id']="client_come_from_id";
						
		$f_client_come_from_id=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_come_from_id",$f_opts);
		$this->addField($f_client_come_from_id);
		//********************
		
		//*** Field client_come_from_ref ***
		$f_opts = array();
		$f_opts['id']="client_come_from_ref";
						
		$f_client_come_from_ref=new FieldSQLJSON($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_come_from_ref",$f_opts);
		$this->addField($f_client_come_from_ref);
		//********************
		
		//*** Field client_kind ***
		$f_opts = array();
		$f_opts['id']="client_kind";
						
		$f_client_kind=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"client_kind",$f_opts);
		$this->addField($f_client_kind);
		//********************
		
		//*** Field caller_id_num ***
		$f_opts = array();
		$f_opts['id']="caller_id_num";
						
		$f_caller_id_num=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"caller_id_num",$f_opts);
		$this->addField($f_caller_id_num);
		//********************
		
		//*** Field ext ***
		$f_opts = array();
		$f_opts['id']="ext";
						
		$f_ext=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ext",$f_opts);
		$this->addField($f_ext);
		//********************
		
		//*** Field num ***
		$f_opts = array();
		$f_opts['id']="num";
						
		$f_num=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"num",$f_opts);
		$this->addField($f_num);
		//********************
		
		//*** Field offer_quant ***
		$f_opts = array();
		$f_opts['id']="offer_quant";
						
		$f_offer_quant=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"offer_quant",$f_opts);
		$this->addField($f_offer_quant);
		//********************
		
		//*** Field offer_total ***
		$f_opts = array();
		$f_opts['id']="offer_total";
						
		$f_offer_total=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"offer_total",$f_opts);
		$this->addField($f_offer_total);
		//********************
		
		//*** Field offer_result ***
		$f_opts = array();
		$f_opts['id']="offer_result";
						
		$f_offer_result=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"offer_result",$f_opts);
		$this->addField($f_offer_result);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'DESC';
		$order->addField($f_start_time,$direct);
$this->setLimitConstant('doc_per_page_count');
	}

}
?>
