<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQLDOC.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInterval.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtArray.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */


require_once(FRAME_WORK_PATH.'basic_classes/ModelReportSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
class DOCMaterialProcurement_Controller extends ControllerSQLDOC{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDateTime('date_time'
				,array('required'=>TRUE,
				'alias'=>'Дата'
			));
		$pm->addParam($param);
		$param = new FieldExtString('number'
				,array(
				'alias'=>'Номер'
			));
		$pm->addParam($param);
		$param = new FieldExtString('doc_ref'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('processed'
				,array(
				'alias'=>'Проведен'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
				'alias'=>'Автор'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('supplier_id'
				,array('required'=>TRUE,
				'alias'=>'Поставщик'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('carrier_id'
				,array('required'=>TRUE,
				'alias'=>'Перевозчик'
			));
		$pm->addParam($param);
		$param = new FieldExtString('driver'
				,array(
				'alias'=>'Водитель'
			));
		$pm->addParam($param);
		$param = new FieldExtString('vehicle_plate'
				,array(
				'alias'=>'гос.номер'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('material_id'
				,array('required'=>TRUE,
				'alias'=>'Материал'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('cement_silos_id'
				,array(
				'alias'=>'Силос'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('quant_gross'
				,array(
				'alias'=>'Брутто'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('quant_net'
				,array(
				'alias'=>'Нетто'
			));
		$pm->addParam($param);
		$param = new FieldExtText('store'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('DOCMaterialProcurement_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTime('date_time'
				,array(
			
				'alias'=>'Дата'
			));
			$pm->addParam($param);
		$param = new FieldExtString('number'
				,array(
			
				'alias'=>'Номер'
			));
			$pm->addParam($param);
		$param = new FieldExtString('doc_ref'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('processed'
				,array(
			
				'alias'=>'Проведен'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			
				'alias'=>'Автор'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('supplier_id'
				,array(
			
				'alias'=>'Поставщик'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('carrier_id'
				,array(
			
				'alias'=>'Перевозчик'
			));
			$pm->addParam($param);
		$param = new FieldExtString('driver'
				,array(
			
				'alias'=>'Водитель'
			));
			$pm->addParam($param);
		$param = new FieldExtString('vehicle_plate'
				,array(
			
				'alias'=>'гос.номер'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('material_id'
				,array(
			
				'alias'=>'Материал'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('cement_silos_id'
				,array(
			
				'alias'=>'Силос'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('quant_gross'
				,array(
			
				'alias'=>'Брутто'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('quant_net'
				,array(
			
				'alias'=>'Нетто'
			));
			$pm->addParam($param);
		$param = new FieldExtText('store'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('DOCMaterialProcurement_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('DOCMaterialProcurement_Model');

			
		/* get_list */
		$pm = new PublicMethod('get_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);
		
		$this->setListModelId('DOCMaterialProcurementList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DOCMaterialProcurementList_Model');		

			
		$pm = new PublicMethod('before_open');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_actions');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_print');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('doc_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_material_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_shift_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);

		
	}
	
	public function insert($pm){
		//doc owner
		$pm->setParamValue('user_id',$_SESSION['user_id']);
		parent::insert($pm);		
	}
	public function get_details($pm){		
		$model = new DOCMaterialProcurementMaterialList_Model($this->getDbLink());	
		$from = null; $count = null;
		$limit = $this->limitFromParams($pm,$from,$count);
		$calc_total = ($count>0);
		if ($from){
			$model->setListFrom($from);
		}
		if ($count){
			$model->setRowsPerPage($count);
		}		
		$order = $this->orderFromParams($pm);
		$where = $this->conditionFromParams($pm,$model);
		$fields = $this->fieldsFromParams($pm);		
		$material_group_id = $where->getFieldValueForDb('material_group_id','=',0,0);
		if ($material_group_id==0){
			//throw new Exception($material_group_id);
			$where->deleteField('material_group_id','=');
		}
		
		$model->select(FALSE,$where,$order,
			$limit,$fields,NULL,NULL,
			$calc_total,TRUE);
		//
		$this->addModel($model);
		
	}
	public function get_print($pm){
		$this->addNewModel(
			sprintf(
			'SELECT number,
			get_date_str_rus(date_time::date) AS date_time_descr,
			supplier_descr,carrier_descr,material_descr,
			format_quant(quant_gross) AS quant_gross,
			format_quant(quant_net) AS quant_net,
			FROM doc_material_procurements_list_view
			WHERE id=%d',
			$pm->getParamValue('doc_id')),
		'head');
	}
	private function add_material_model($link){
		$mat_model = new ModelSQL($link,array('id'=>'RawMaterial_Model'));
		$mat_model->addField(new FieldSQLInt($link,null,null,"id"));
		$mat_model->addField(new FieldSQLString($link,null,null,"name"));
		$mat_model->query("SELECT id,name FROM raw_materials WHERE name <>'' ORDER BY id",
		TRUE);
		$this->addModel($mat_model);			
	}
	
	public function get_shift_list($pm){
		$link = $this->getDbLink();
		$this->add_material_model($link);
		
		$this->setListModelId('DOCMaterialProcurementShiftList_Model');
		
		$this->get_list($pm);
	}
	
	/*
	public function get_material_list($pm){
		$link = $this->getDbLink();
		$ar = $link->query_first("SELECT COUNT(*) AS cnt FROM raw_materials WHERE name <>''");
		$mat_count = $ar['cnt'];				
		//
		//result model
		$model = new ModelReportSQL($link,array("id"=>"get_material_list"));
		$model->addField(new FieldSQLString($link,null,null,"shift"));
		$model->addField(new FieldSQLString($link,null,null,"shift_descr"));		
		$model->addField(new FieldSQLString($link,null,null,"shift_from_descr"));		
		$model->addField(new FieldSQLString($link,null,null,"shift_to_descr"));		

		$fld_list='';
		$fld_def = '';
		for ($i = 1; $i <= $mat_count; $i++) {
			$fld_list.=',mat'.$i.'_quant';
			$fld_def.=',mat'.$i.'_quant numeric';
			$model->addField(new FieldSQLString($link,null,null,'mat'.$i.'_quant'));
		}
		$def_date=null;
		FieldSQLDateTime::formatForDb(mktime(),$def_date);
		
		$model_params = new ModelReportSQL($link);
		$model_params->addField(new FieldSQLDateTime($link,null,null,"date_time"));		
		$where = $this->conditionFromParams($pm,$model_params);
		if (!$where){
			throw new Exception("Не заданы условия!");
		}
		$sql=sprintf("SELECT
			shift,shift_descr,
			shift_from_descr,shift_to_descr%s
		FROM raw_material_procurement_dates(%s,%s)
		AS (shift timestamp,
		shift_descr text,
		shift_from_descr text,
		shift_to_descr text%s)",
		$fld_list,
		$where->getFieldValueForDb('date_time','>=',0,$def_date),
		$where->getFieldValueForDb('date_time','<=',0,$def_date),
		$fld_def);
		//throw new Exception($sql);
		$model->query($sql,TRUE);
		$this->addModel($model);		
		
		$this->add_material_model($link);
	}
	*/
}
?>