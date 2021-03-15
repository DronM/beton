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



require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once('common/SMSService.php');

require_once(FUNC_PATH.'VehicleRoute.php');

class Vehicle_Controller extends ControllerSQL{

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('plate'
				,array('required'=>TRUE,
				'alias'=>'Номер'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('plate_n'
				,array(
				'alias'=>'Номер число для сортировки'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('load_capacity'
				,array('required'=>TRUE,
				'alias'=>'Грузоподъемность'
			));
		$pm->addParam($param);
		$param = new FieldExtString('make'
				,array('required'=>FALSE,
				'alias'=>'Марка'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('driver_id'
				,array('required'=>FALSE));
		$pm->addParam($param);
		$param = new FieldExtString('feature'
				,array('required'=>FALSE,
				'alias'=>'Свойство'
			));
		$pm->addParam($param);
		$param = new FieldExtString('tracker_id'
				,array(
				'alias'=>'Трэкер'
			));
		$pm->addParam($param);
		$param = new FieldExtString('sim_id'
				,array(
				'alias'=>'Идентификатор SIM карты'
			));
		$pm->addParam($param);
		$param = new FieldExtString('sim_number'
				,array(
				'alias'=>'Номер телефона SIM карты'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('vehicle_owner_id'
				,array(
				'alias'=>'УДАЛИТЬ Владелец'
			));
		$pm->addParam($param);
		$param = new FieldExtJSONB('vehicle_owners'
				,array(
				'alias'=>'История владелецев'
			));
		$pm->addParam($param);
		$param = new FieldExtArray('vehicle_owners_ar'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('Vehicle.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Vehicle_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('plate'
				,array(
			
				'alias'=>'Номер'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('plate_n'
				,array(
			
				'alias'=>'Номер число для сортировки'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('load_capacity'
				,array(
			
				'alias'=>'Грузоподъемность'
			));
			$pm->addParam($param);
		$param = new FieldExtString('make'
				,array(
			
				'alias'=>'Марка'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('driver_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('feature'
				,array(
			
				'alias'=>'Свойство'
			));
			$pm->addParam($param);
		$param = new FieldExtString('tracker_id'
				,array(
			
				'alias'=>'Трэкер'
			));
			$pm->addParam($param);
		$param = new FieldExtString('sim_id'
				,array(
			
				'alias'=>'Идентификатор SIM карты'
			));
			$pm->addParam($param);
		$param = new FieldExtString('sim_number'
				,array(
			
				'alias'=>'Номер телефона SIM карты'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('vehicle_owner_id'
				,array(
			
				'alias'=>'УДАЛИТЬ Владелец'
			));
			$pm->addParam($param);
		$param = new FieldExtJSONB('vehicle_owners'
				,array(
			
				'alias'=>'История владелецев'
			));
			$pm->addParam($param);
		$param = new FieldExtArray('vehicle_owners_ar'
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
			$pm->addEvent('Vehicle.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Vehicle_Model');

			
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
		$pm->addEvent('Vehicle.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Vehicle_Model');

			
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
		
		$this->setListModelId('VehicleDialog_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('VehicleDialog_Model');		

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('plate'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('VehicleDialog_Model');

			
		$pm = new PublicMethod('get_vehicle_statistics');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtDate('date',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('complete_features');
		
				
	$opts=array();
			
		$pm->addParam(new FieldExtString('feature',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('complete_makes');
		
				
	$opts=array();
			
		$pm->addParam(new FieldExtString('make',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('check_for_broken_trackers');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('vehicles_with_trackers');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_current_position');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_current_position_all');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_route');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('shipment_id',$opts));
	
				
	$opts=array();
	
		$opts['length']=20;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('tracker_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtEnum('vehicle_state',$opts));
	
			
		$this->addPublicMethod($pm);

			
			
		$pm = new PublicMethod('get_track');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtDateTime('dt_from',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtDateTime('dt_to',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtTime('stop_dur',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_tool_tip');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_stops_at_dest');
		
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
					
		$pm->addParam(new FieldExtString('templ',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}
	
	public function get_vehicle_statistics($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('date',DT_DATE);
		$this->addNewModel(vsprintf(
			'SELECT * FROM get_vehicle_statistics(%s)',
			$params->getArray()),
			'get_vehicle_statistics'
		);
	}
	public function check_for_broken_trackers(){
		$dbLink = $this->getDbLink();
		$ar = $dbLink->query_first(
			'SELECT * FROM check_for_broken_trackers()'
		);
		if ($ar){			
			$sms_service = new SMSService(SMS_LOGIN, SMS_PWD);
			$sms_id_resp = $sms_service->send($ar['cel_phone'],
				$ar['sms_text'],SMS_SIGN,SMS_TEST);
			$sms_id = NULL;
			FieldSQLString::formatForDb($this->getDbLinkMaster(),$sms_id_resp,$sms_id);
			$dbLink->query(sprintf(
			'INSERT INTO sms_trackers_service (mes_id,mes_text,date_time)
				VALUES(%s,%s,now())',
			$sms_id,$ar['sms_text']
			));
		}
	}
	public function complete_owners($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('owner',DT_STRING);
		$this->addNewModel(vsprintf(
			"SELECT * FROM vehicle_owner_list_view
			WHERE lower(owner) LIKE '%%'||%s||'%%'",
			$params->getArray()),
			'VehicleOwnerList_Model'
		);
	}
	public function complete_features($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('feature',DT_STRING);
		$this->addNewModel(vsprintf(
			"SELECT * FROM vehicle_feature_list_view
			WHERE lower(feature) LIKE '%%'||%s||'%%'",
			$params->getArray()),
			'VehicleFeatureList_Model'
		);	
	}
	public function complete_makes($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('make',DT_STRING);
		$this->addNewModel(vsprintf(
			"SELECT * FROM vehicle_make_list_view
			WHERE lower(make) LIKE '%%'||%s||'%%'",
			$params->getArray()),
			'VehicleMakeList_Model'
		);	
	}
	public function vehicles_with_trackers($pm){
		$this->addNewModel(
			sprintf(
				"SELECT
					0 AS id
					,'*** ВСЕ ***' AS plate
					,'NULL' AS tracker_id
				UNION ALL
				(SELECT
					id
					,plate
					,tracker_id
				FROM vehicles
				WHERE tracker_id IS NOT NULL AND tracker_id <>''%s
				ORDER BY plate)",
				($_SESSION['role_id']=='vehicle_owner')? sprintf(' AND vehicles.vehicle_owner_id=%d',$_SESSION['global_vehicle_owner_id']):''
			),
			'vehicles_with_trackers'
		);		
	}
	public function get_tracker_inf($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('id',DT_INT);	
		
		$cond = ($_SESSION['role_id']=='vehicle_owner')? sprintf(' AND vehicles.vehicle_owner_id=%d',$_SESSION['global_vehicle_owner_id']):'';
		$this->addNewModel(
			vsprintf(
				"SELECT
				date5_time5_descr(recieved_dt+age(now(),now() at time zone 'UTC')) AS recieved_dt_str
				FROM car_tracking
				LEFT JOIN vehicles ON vehicles.tracker_id=car_tracking.car_id
				WHERE vehicles.id=%d".$cond."
				ORDER BY period DESC LIMIT 1",
				$params->getArray()				
			),
			'get_tracker_inf'
		);		
	}
	
	/**
	 * Returns existing route
	 */
	public function get_route($pm){
		$route_ar = $this->getDbLink->query_first(sprintf(
			"SELECT
				t.route
			FROM vehicle_route_cashe AS t
			WHERE
				t.tracker_id = %s
				AND t.shipment_id = %d
				AND t.vehicle_state = %s"				
			,$this->getExtDbVal($pm,'tracker_id')
			,$this->getExtDbVal($pm,'shipment_id')
			,$this->getExtDbVal($pm,'vehicle_state')
		));
		if(is_array($route_ar) && count($route_ar)){
			$this->addModel(new ModelVars(
				array('id'=>'Route_Model',
					'values'=>array(
						new Field('route',DT_STRING,
							array('value'=>$route_ar['route']))
					)
				)
			));	
		}
	}
	
	public function get_current_position($pm){
		
		$vehicle_id = $this->getExtDbVal($pm,'id');
		if($_SESSION['role_id']=='vehicle_owner'){
			$ar = $this->getDbLink()->query_first(sprintf("SELECT vehicle_owner_id FROM vehicles WHERE id=%d",$vehicle_id));
			if(!is_array($ar) ||!count($ar) || $ar['vehicle_owner_id']!=$_SESSION['global_vehicle_owner_id']){
				throw new Exception('Permission denied!');
			}
		}
		
		//zones
		$this->addNewModel(
			VehicleRoute::getZoneListQuery($vehicle_id)
			,'ZoneList_Model'
		);
		
		//position
		$this->addNewModel(
			VehicleRoute::getLastPosQuery($vehicle_id)
			,'VehicleLastPos_Model'
		);
		
		$route = VehicleRoute::getRoute($vehicle_id,$this->getDbLink());
		
		if($route){
			$this->addModel(new ModelVars(
				array('id'=>'Route_Model',
					'values'=>array(
						new Field('route',DT_STRING,
							array('value'=>$route))
					)
				)
			));
		}
	}
	public function get_current_position_all($pm){
		//zones
		$this->addNewModel(
		"SELECT 
			replace(
				replace(st_astext(d.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text
			) AS base_zone
		FROM destinations AS d
		WHERE d.id=constant_base_geo_zone_id()",
		'ZoneList_Model');
		
		//position
		if($_SESSION['role_id']=='vehicle_owner'){
			$q = sprintf(
				"SELECT * FROM vehicles_last_pos WHERE id IN (SELECT t.id FROM vehicles t WHERE t.vehicle_owner_id=%d)",
				$_SESSION['global_vehicle_owner_id']
			);
		}
		else{
			$q = "SELECT * FROM vehicles_last_pos";
		}
		
		$this->addNewModel($q,'VehicleLastPos_Model');		
	}
	
	public function get_track($pm){
		$link = $this->getDbLink();
		
		if($_SESSION['role_id']=='vehicle_owner'){
			$ar = $link->query_first(sprintf("SELECT vehicle_owner_id FROM vehicles WHERE id=%d",$this->getExtDbVal($pm,'id')));
			if(!is_array($ar) ||!count($ar) || $ar['vehicle_owner_id']!=$_SESSION['global_vehicle_owner_id']){
				throw new Exception('Permission denied!');
			}
		}
		
		$this->addNewModel(sprintf(
			"SELECT
				(
					SELECT
					replace(replace(st_astext(zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text) AS coords
					FROM destinations
					WHERE id=constant_base_geo_zone_id()
				) AS base_zone,
				NULL AS dest_zone
			UNION ALL
			SELECT
				NULL AS base_zone,
				replace(replace(st_astext(zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text) AS dest_zone
			FROM vehicle_schedule_states AS st
			LEFT JOIN vehicle_schedules AS vs ON vs.id=st.schedule_id
			LEFT JOIN vehicles AS v ON v.id=vs.vehicle_id
			LEFT JOIN destinations AS dest ON dest.id=st.destination_id
			WHERE v.id=%d
			AND st.date_time BETWEEN %s AND %s
			AND st.state='busy'::vehicle_states",
			$this->getExtDbVal($pm,'id'),
			$this->getExtDbVal($pm,'dt_from'),
			$this->getExtDbVal($pm,'dt_to')
			)
			,'ZoneList_Model'
		);
		//track
		$this->addNewModel(sprintf(
			"SELECT * FROM vehicles_get_track(%d,%s,%s,%s)",
			$this->getExtDbVal($pm,'id'),
			$this->getExtDbVal($pm,'dt_from'),
			$this->getExtDbVal($pm,'dt_to'),
			$this->getExtDbVal($pm,'stop_dur')
			),
			'TrackData_Model'
		);				
	}
	public function get_tool_tip($pm){
		$link = $this->getDbLink();
		
		$ar = $link->query_first(sprintf(
		"SELECT
			date8_time5_descr(current_coord_date_time::timestamp without time zone) AS dt,
			current_coord[1] AS cur_lat,
			current_coord[2] AS cur_lon,		
			coord[1][1] AS lat_min,coord[1][2] AS lat_max,
			coord[2][1] AS lon_min,coord[2][2] AS lon_max,
			descr
		FROM vehicle_current_heading(%d)
		AS (current_coord float[],current_coord_date_time timestamp,
		coord float[],descr text)",
		$this->getExtDbVal($pm,'id')
		));
		$res = '';
		if ($ar){
			$res = '<div>трэкер:'.$ar['dt'].'</div>';
			if ($ar['descr']=='to_base' ||
			$ar['descr']=='to_dest'){
				$km = 'xx';
				$t = ($ar['descr']=='to_base')? 'до базы:':'до объекта:';
				$res.=sprintf('<div>%s%s км.</div>',$t,$km);
			}
		}
		echo $res;
	}
	public function get_stops_at_dest($pm){
		$link = $this->getDbLink();
		$model = new ModelSQL($link,array("id"=>"get_stops_at_dest"));
		$model->addField(new FieldSQLDateTime($link,null,null,"date_time",DT_DATETIME));
		$model->addField(new FieldSQLInt($link,null,null,"destination_id",DT_INT));
		$model->addField(new FieldSQLInt($link,null,null,"vehicle_id",DT_INT));
		$model->addField(new FieldSQLString($link,null,null,"stop_dur",DT_TIME));
		
		$where = $this->conditionFromParams($pm,$model);
		$from = null;
		$to = null;
		$destination_id = 0;
		$vehicle_id = 0;
		$vehicle_owner_id = 0;
		$stop_dur = "'00:05'";
		
		foreach($where->fields as $w_field){
			$id = $w_field['field']->getId();
			if ($id=='date_time'){
				if ($w_field['signe']=='>='){
					$from = $w_field['field']->getValueForDb();
				}
				else{
					$to = $w_field['field']->getValueForDb();
				}
			}
			else if ($id=='destination_id'){
				$destination_id = $w_field['field']->getValueForDb();
			}
			else if ($id=='vehicle_id'){
				$vehicle_id = $w_field['field']->getValueForDb();
			}			
			else if ($id=='stop_dur'){
				$stop_dur = $w_field['field']->getValueForDb();
			}			
		}
		
		if($_SESSION['role_id']=='vehicle_owner' && $vehicle_id){
			$ar = $link->query_first(sprintf("SELECT vehicle_owner_id FROM vehicles WHERE id=%d",$vehicle_id));
			if(!is_array($ar) ||!count($ar) || $ar['vehicle_owner_id']!=$_SESSION['global_vehicle_owner_id']){
				throw new Exception('Permission denied!');
			}
			$vehicle_owner_id = $_SESSION['global_vehicle_owner_id'];
		}
				
		$model->setSelectQueryText(
		sprintf(
		"SELECT * FROM vehicles_at_destination(%s,%s,%d,%d,%s::interval,%d)",
		$from,$to,$destination_id,$vehicle_id,$stop_dur,$vehicle_owner_id));
		
		$model->select(false,null,null,
			null,null,null,null,null,TRUE);
		//
		$this->addModel($model);				
	}	
}
?>