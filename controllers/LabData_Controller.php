<?php

require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');
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


class LabData_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('shipment_id'
				,array('required'=>TRUE,
				'alias'=>'Отгрузка'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('ok_sm'
				,array(
				'alias'=>'ОК см'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('weight'
				,array(
				'alias'=>'масса'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('weight_norm'
				,array(
				'alias'=>'масса норм'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('percent_1'
				,array(
				'alias'=>'%'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('p_1'
				,array(
				'alias'=>'p1'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('p_2'
				,array(
				'alias'=>'p2'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('p_3'
				,array(
				'alias'=>'p3'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('p_4'
				,array(
				'alias'=>'p4'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('p_7'
				,array(
				'alias'=>'p7'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('p_28'
				,array(
				'alias'=>'p28'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('p_norm'
				,array(
				'alias'=>'p_norm'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('percent_2'
				,array(
				'alias'=>'percent_2'
			));
		$pm->addParam($param);
		$param = new FieldExtText('lab_comment'
				,array(
				'alias'=>'Комментарий'
			));
		$pm->addParam($param);
		$param = new FieldExtText('num'
				,array(
				'alias'=>'№'
			));
		$pm->addParam($param);
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['shipment_id'
			]
		];
		$pm->addEvent('LabData.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('LabData_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_shipment_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('shipment_id'
				,array(
			
				'alias'=>'Отгрузка'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('ok_sm'
				,array(
			
				'alias'=>'ОК см'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('weight'
				,array(
			
				'alias'=>'масса'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('weight_norm'
				,array(
			
				'alias'=>'масса норм'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('percent_1'
				,array(
			
				'alias'=>'%'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('p_1'
				,array(
			
				'alias'=>'p1'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('p_2'
				,array(
			
				'alias'=>'p2'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('p_3'
				,array(
			
				'alias'=>'p3'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('p_4'
				,array(
			
				'alias'=>'p4'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('p_7'
				,array(
			
				'alias'=>'p7'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('p_28'
				,array(
			
				'alias'=>'p28'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('p_norm'
				,array(
			
				'alias'=>'p_norm'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('percent_2'
				,array(
			
				'alias'=>'percent_2'
			));
			$pm->addParam($param);
		$param = new FieldExtText('lab_comment'
				,array(
			
				'alias'=>'Комментарий'
			));
			$pm->addParam($param);
		$param = new FieldExtText('num'
				,array(
			
				'alias'=>'№'
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('shipment_id',array(
			
				'alias'=>'Отгрузка'
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['shipment_id'
				]
			];
			$pm->addEvent('LabData.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('LabData_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('shipment_id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
				
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['shipment_id'
			]
		];
		$pm->addEvent('LabData.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('LabData_Model');

			
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
		
		$this->setListModelId('LabDataList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('shipment_id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('LabDataList_Model');		

		
	}
}
?>
