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
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
 
class LabData_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("lab_data");
			
		//*** Field shipment_id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=FALSE;
		
		$f_opts['alias']='Отгрузка';
		$f_opts['id']="shipment_id";
						
		$f_shipment_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"shipment_id",$f_opts);
		$this->addField($f_shipment_id);
		//********************
		
		//*** Field ok_sm ***
		$f_opts = array();
		
		$f_opts['alias']='ОК см';
		$f_opts['id']="ok_sm";
						
		$f_ok_sm=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"ok_sm",$f_opts);
		$this->addField($f_ok_sm);
		//********************
		
		//*** Field weight ***
		$f_opts = array();
		
		$f_opts['alias']='масса';
		$f_opts['id']="weight";
						
		$f_weight=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"weight",$f_opts);
		$this->addField($f_weight);
		//********************
		
		//*** Field weight_norm ***
		$f_opts = array();
		
		$f_opts['alias']='масса норм';
		$f_opts['id']="weight_norm";
						
		$f_weight_norm=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"weight_norm",$f_opts);
		$this->addField($f_weight_norm);
		//********************
		
		//*** Field percent_1 ***
		$f_opts = array();
		
		$f_opts['alias']='%';
		$f_opts['id']="percent_1";
						
		$f_percent_1=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"percent_1",$f_opts);
		$this->addField($f_percent_1);
		//********************
		
		//*** Field p_1 ***
		$f_opts = array();
		
		$f_opts['alias']='p1';
		$f_opts['id']="p_1";
						
		$f_p_1=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_1",$f_opts);
		$this->addField($f_p_1);
		//********************
		
		//*** Field p_2 ***
		$f_opts = array();
		
		$f_opts['alias']='p2';
		$f_opts['id']="p_2";
						
		$f_p_2=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_2",$f_opts);
		$this->addField($f_p_2);
		//********************
		
		//*** Field p_3 ***
		$f_opts = array();
		
		$f_opts['alias']='p3';
		$f_opts['id']="p_3";
						
		$f_p_3=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_3",$f_opts);
		$this->addField($f_p_3);
		//********************
		
		//*** Field p_4 ***
		$f_opts = array();
		
		$f_opts['alias']='p4';
		$f_opts['id']="p_4";
						
		$f_p_4=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_4",$f_opts);
		$this->addField($f_p_4);
		//********************
		
		//*** Field p_7 ***
		$f_opts = array();
		
		$f_opts['alias']='p7';
		$f_opts['id']="p_7";
						
		$f_p_7=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_7",$f_opts);
		$this->addField($f_p_7);
		//********************
		
		//*** Field p_28 ***
		$f_opts = array();
		
		$f_opts['alias']='p28';
		$f_opts['id']="p_28";
						
		$f_p_28=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_28",$f_opts);
		$this->addField($f_p_28);
		//********************
		
		//*** Field p_norm ***
		$f_opts = array();
		
		$f_opts['alias']='p_norm';
		$f_opts['id']="p_norm";
						
		$f_p_norm=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"p_norm",$f_opts);
		$this->addField($f_p_norm);
		//********************
		
		//*** Field percent_2 ***
		$f_opts = array();
		
		$f_opts['alias']='percent_2';
		$f_opts['id']="percent_2";
						
		$f_percent_2=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"percent_2",$f_opts);
		$this->addField($f_percent_2);
		//********************
		
		//*** Field lab_comment ***
		$f_opts = array();
		
		$f_opts['alias']='Комментарий';
		$f_opts['id']="lab_comment";
						
		$f_lab_comment=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"lab_comment",$f_opts);
		$this->addField($f_lab_comment);
		//********************
		
		//*** Field num ***
		$f_opts = array();
		
		$f_opts['alias']='№';
		$f_opts['id']="num";
						
		$f_num=new FieldSQLText($this->getDbLink(),$this->getDbName(),$this->getTableName(),"num",$f_opts);
		$this->addField($f_num);
		//********************
	$this->setLimitConstant('doc_per_page_count');
	}

}
?>
