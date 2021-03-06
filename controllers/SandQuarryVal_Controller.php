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


class SandQuarryVal_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDate('day'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('quarry_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_mkr'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_2_5'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_1_25'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_0_63'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_0_63_2'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_0_315'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_0_16'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_0_05'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_nasip'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_dno'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_istin'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_humid'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_dust'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('v_void'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('v_comment'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('SandQuarryVal.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('SandQuarryVal_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDate('day'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('quarry_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_mkr'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_2_5'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_1_25'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_0_63'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_0_63_2'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_0_315'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_0_16'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_0_05'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_nasip'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_dno'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_istin'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_humid'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_dust'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('v_void'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('v_comment'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['id'
				]
			];
			$pm->addEvent('SandQuarryVal.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('SandQuarryVal_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
				
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('SandQuarryVal.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('SandQuarryVal_Model');

			
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
		
		$this->setListModelId('SandQuarryValList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('SandQuarryValList_Model');		

		
	}	
	
}
?>