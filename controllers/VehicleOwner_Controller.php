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

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



require_once('common/MyDate.php');
require_once(ABSOLUTE_PATH.'functions/Beton.php');

class VehicleOwner_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('name'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('VehicleOwner_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('name'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('VehicleOwner_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('VehicleOwner_Model');

			
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
		
		$this->setListModelId('VehicleOwnerList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('VehicleOwnerList_Model');		

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('name'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('VehicleOwner_Model');

			
		$pm = new PublicMethod('get_tot_report');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtDate('date',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('templ',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public function get_tot_report($pm){
		$vown_id = 0;
		if($_SESSION['role_id']=='vehicle_owner'){
			$vown_id = intval($_SESSION['global_vehicle_owner_id']);
		}
		
		$dt = (!$pm->getParamValue('date'))? MyDate::StartMonth(time()) : $this->getExtVal($pm,'date');
		$dt+= Beton::shiftStartTime();
		$date_from = Beton::shiftStart($dt);
		$date_to = Beton::shiftEnd(MyDate::EndMonth($dt));
		$date_from_db = "'".date('Y-m-d H:i:s',$date_from)."'";
		$date_to_db = "'".date('Y-m-d H:i:s',$date_to)."'";
		
		$q = "WITH
			ships AS (
				SELECT
					sum(cost) AS cost,
					sum(cost_for_driver) AS cost_for_driver,
					sum(demurrage_cost) AS demurrage_cost
				FROM shipments_for_veh_owner_list AS t
				WHERE
					".($vown_id? sprintf("t.vehicle_owner_id=%d AND ",$vown_id):"")."
					t.ship_date_time BETWEEN ".$date_from_db." AND ".$date_to_db."
			)
			,pumps AS (
				SELECT
					sum(t.pump_cost) AS cost
				FROM shipments_pump_list t
				WHERE
					".($vown_id? sprintf("t.pump_vehicle_owner_id=%d AND ",$vown_id):"")."
					t.date_time  BETWEEN ".$date_from_db." AND ".$date_to_db."
			)
			,
			client_ships AS (
				SELECT
					sum(t.cost_concrete) AS cost_concrete,
					sum(t.cost_shipment) AS cost_shipment
				FROM shipments_for_client_veh_owner_list t
				WHERE	
					".($vown_id? sprintf("t.vehicle_owner_id=%d AND ",$vown_id):"")."
					t.ship_date  BETWEEN ".$date_from_db." AND ".$date_to_db."
			)
		SELECT
			(SELECT cost FROM ships) AS ship_cost,
			(SELECT cost_for_driver FROM ships) AS ship_for_driver_cost,
			(SELECT demurrage_cost FROM ships) AS ship_demurrage_cost,
			(SELECT cost FROM pumps) AS pumps_cost,
			(SELECT cost_concrete FROM client_ships) AS client_ships_concrete_cost,
			(SELECT cost_shipment FROM client_ships) AS client_ships_shipment_cost";
		$this->addNewModel($q,'VehicleOwnerTotReport_Model');
	}


}
?>