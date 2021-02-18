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


class ProductionVehicleCorrection_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('production_site_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('production_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('vehicle_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['production_site_id'
			,'production_id'
			]
		];
		$pm->addEvent('ProductionVehicleCorrection.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('ProductionVehicleCorrection_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_production_site_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('old_production_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('production_site_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('production_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('vehicle_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('production_site_id',array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('production_id',array(
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['production_site_id'
				,'production_id'
				]
			];
			$pm->addEvent('ProductionVehicleCorrection.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('ProductionVehicleCorrection_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('production_site_id'
		));		
		
		$pm->addParam(new FieldExtInt('production_id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
				
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['production_site_id'
			,'production_id'
			]
		];
		$pm->addEvent('ProductionVehicleCorrection.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('ProductionVehicleCorrection_Model');

			
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
		
		$this->setListModelId('ProductionVehicleCorrectionList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('production_site_id'
		));
		
		$pm->addParam(new FieldExtInt('production_id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ProductionVehicleCorrectionList_Model');		

		
	}	
	

	public function insert($pm){
		if($_SESSION['role_id']!='admin' || !$pm->getParamValue('user_id')){
			$pm->setParamValue('user_id',$_SESSION['user_id']);
		}

		$this->getDbLinkMaster()->query(sprintf(
			"DELETE FROM production_vehicle_corrections
			WHERE production_site_id=%d AND production_id=%d"
			,$this->getExtDbVal($pm,'production_site_id')
			,$this->getExtDbVal($pm,'production_id')
			)
		);
		parent::insert($pm);
	}


}
?>