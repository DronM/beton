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
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */


class RawMaterialConsRate_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('rate_date_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('concrete_type_id'
				,array(
				'alias'=>'Марка бетона'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('raw_material_id'
				,array(
				'alias'=>'Материал'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('rate'
				,array(
				'alias'=>'Расход'
			));
		$pm->addParam($param);
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('RawMaterialConsRate_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_rate_date_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('old_concrete_type_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('old_raw_material_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('rate_date_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('concrete_type_id'
				,array(
			
				'alias'=>'Марка бетона'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('raw_material_id'
				,array(
			
				'alias'=>'Материал'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('rate'
				,array(
			
				'alias'=>'Расход'
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('rate_date_id',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('concrete_type_id',array(
			
				'alias'=>'Марка бетона'
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('raw_material_id',array(
			
				'alias'=>'Материал'
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('RawMaterialConsRate_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('rate_date_id'
		));		
		
		$pm->addParam(new FieldExtInt('concrete_type_id'
		));		
		
		$pm->addParam(new FieldExtInt('raw_material_id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('RawMaterialConsRate_Model');

			
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
		
		$this->setListModelId('RawMaterialConsRateList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('rate_date_id'
		));
		
		$pm->addParam(new FieldExtInt('concrete_type_id'
		));
		
		$pm->addParam(new FieldExtInt('raw_material_id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('RawMaterialConsRate_Model');		

			
		$pm = new PublicMethod('raw_material_cons_report');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

				
	$opts=array();
					
		$pm->addParam(new FieldExtString('grp_fields',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('agg_fields',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
}
?>