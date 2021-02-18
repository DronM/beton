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


class LabEntryDetail_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('id'
				,array('required'=>FALSE,
				'alias'=>'Код'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('shipment_id'
				,array('required'=>TRUE,
				'alias'=>'Отгрузка'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('ok'
				,array(
				'alias'=>'ОК'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('weight'
				,array(
				'alias'=>'Масса'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('kn'
				,array(
				'alias'=>'КН'
			));
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id_key'
			]
		];
		$pm->addEvent('LabEntryDetail.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('LabEntryDetail_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id_key',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id_key'
				,array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('id'
				,array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('shipment_id'
				,array(
			
				'alias'=>'Отгрузка'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('ok'
				,array(
			
				'alias'=>'ОК'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('weight'
				,array(
			
				'alias'=>'Масса'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('kn'
				,array(
			
				'alias'=>'КН'
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id_key',array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['id_key'
				]
			];
			$pm->addEvent('LabEntryDetail.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('LabEntryDetail_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id_key'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
				
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id_key'
			]
		];
		$pm->addEvent('LabEntryDetail.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('LabEntryDetail_Model');

			
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
		
		$this->setListModelId('LabEntryDetailList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id_key'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('LabEntryDetailList_Model');		

		
	}
}
?>
