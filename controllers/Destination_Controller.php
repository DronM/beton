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



require_once('common/geo/yandex.php');
require_once(FRAME_WORK_PATH.'basic_classes/CondParamsSQL.php');

class Destination_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('name'
				,array('required'=>TRUE,
				'alias'=>'Наименование'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('distance'
				,array('required'=>FALSE,
				'alias'=>'Расстояние'
			));
		$pm->addParam($param);
		$param = new FieldExtTime('time_route'
				,array('required'=>TRUE,
				'alias'=>'Время'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('price'
				,array(
				'alias'=>'Стоимость'
			));
		$pm->addParam($param);
		$param = new FieldExtString('zone'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('special_price'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('price_for_driver'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Destination_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		$param = new FieldExtString('name'
				,array(
			
				'alias'=>'Наименование'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('distance'
				,array(
			
				'alias'=>'Расстояние'
			));
			$pm->addParam($param);
		$param = new FieldExtTime('time_route'
				,array(
			
				'alias'=>'Время'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('price'
				,array(
			
				'alias'=>'Стоимость'
			));
			$pm->addParam($param);
		$param = new FieldExtString('zone'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('special_price'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('price_for_driver'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Destination_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Destination_Model');

			
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
		
		$this->setListModelId('DestinationList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('DestinationDialog_Model');		

			
		$pm = new PublicMethod('complete_dest');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('name_pat',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('client_id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_coords_on_name');
		
				
	$opts=array();
	
		$opts['alias']='Наименование';
		$opts['length']=100;
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtString('name',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('at_dest_avg_time');
		
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

			
		$pm = new PublicMethod('route_to_dest_avg_time');
		
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

	public function get_coords_on_name($pm){
		$addr = array();
		$inf = array();
		$addr['city'] = 'область+Тюменская,город+Тюмень,'.$this->getExtVal($pm,'name');
		get_inf_on_address($addr,$inf);
		$model = new Model(array('id'=>'Coords_Model'));
		$model->addField(new Field('lon_lower',DT_STRING));
		$model->addField(new Field('lon_upper',DT_STRING));
		$model->addField(new Field('lat_lower',DT_STRING));
		$model->addField(new Field('lat_upper',DT_STRING));
		$model->insert();
		$model->lon_lower = $inf['lon_lower'];
		$model->lon_upper = $inf['lon_upper'];
		$model->lat_lower = $inf['lat_lower'];
		$model->lat_upper = $inf['lat_upper'];
		$this->addModel($model);
	}
	
	public function at_dest_avg_time($pm){
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		$this->addNewModel(sprintf('SELECT * FROM at_dest_avg_time(%s,%s)',
		$cond->getValForDb('date_time','ge',DT_DATETIME),
		$cond->getValForDb('date_time','le',DT_DATETIME)),
		'at_dest_avg_time');
	}
	public function route_to_dest_avg_time($pm){
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		$this->addNewModel(sprintf('SELECT * FROM route_to_dest_avg_time(%s,%s)',
		$cond->getValForDb('date_time','ge',DT_DATETIME),
		$cond->getValForDb('date_time','le',DT_DATETIME)),
		'route_to_dest_avg_time');
	}
	
	
	public function complete_dest($pm){
		if($pm->getParamValue('name_pat')){
			$this->addNewModel(sprintf(
			"SELECT
				dest.*
			FROM destination_list_view AS dest
			WHERE lower(dest.name) LIKE lower(%s)||'%%'",
			$this->getExtDbVal($pm,'name_pat')
			),
			'DestinationList_Model');
		}
		else if($pm->getParamValue('client_id')){
			$this->addNewModel(sprintf(
			"SELECT DISTINCT ON (o.destination_id)
				dest.*
			FROM orders AS o
			LEFT JOIN destination_list_view dest ON dest.id=o.destination_id
			WHERE o.client_id=%d
			ORDER BY o.destination_id,o.date_time DESC",
			$this->getExtDbVal($pm,'client_id')
			),
			'DestinationList_Model');
		}
	}
}
?>