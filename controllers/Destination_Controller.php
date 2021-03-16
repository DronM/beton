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



require_once('common/geo/yandex.php');
require_once(FRAME_WORK_PATH.'basic_classes/CondParamsSQL.php');

require_once('common/OSRMV5.php');
require_once('common/geo/yandex.php');
require_once('common/geo/YndxReverseCode.php');
require_once('common/decodePolylineToArray.php');

class Destination_Controller extends ControllerSQL{

	const ER_OSRM_ROUTE_QUERY = 'Ошибка получения данных с сервера OSRM!';
	const ER_ZONE_COORD_QUERY = 'Ошибка обработки координат зоны!';

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
		$param = new FieldExtFloat('near_road_lon'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('near_road_lat'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('send_route_sms'
				,array(
				'alias'=>'Отправлять СМС с маршрутом'
			));
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('Destination.insert',$ev_opts);
		
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
		$param = new FieldExtFloat('near_road_lon'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('near_road_lat'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('send_route_sms'
				,array(
			
				'alias'=>'Отправлять СМС с маршрутом'
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['id'
				]
			];
			$pm->addEvent('Destination.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Destination_Model');

			
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
		$pm->addEvent('Destination.delete',$ev_opts);
		
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

			
		$pm = new PublicMethod('complete_for_order');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('name_pat',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('client_id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_data_for_new_address');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('address_str',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_for_client_list');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_coords_on_name');
		
				
	$opts=array();
	
		$opts['alias']='Наименование';
		$opts['length']=100;
		$opts['required']=TRUE;		
		$pm->addParam(new FieldExtString('name',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_route_to_zone');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('zone_coords',$opts));
	
			
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

	/**
	 * need $inf['lat_pos'],$inf['lon_pos']
	 */
	private function make_route_to_zone(&$inf){
		//OSRM
		//nearest road
		$osrm = new OSRMV5(OSRM_PROTOCOLE,OSRM_HOST,OSRM_PORT);
		$inf['road_lon_pos']=NULL;$inf['road_lat_pos']=NULL;
		$osrm->getNearestRoadCoord(
			$inf['lat_pos'],$inf['lon_pos'],
			$inf['road_lat_pos'],$inf['road_lon_pos']
		);
		//production sites, cash!
		$q_id = $this->getDbLink()->query(sprintf(
			"SELECT
				id,
				name,
				replace(replace(st_astext(zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text) AS zone_str,
				replace(replace(st_astext(st_centroid(zone)), 'POINT('::text, ''::text), ')'::text, ''::text) AS zone_center_str,
				near_road_lon,
				near_road_lat
			FROM destinations
			WHERE id IN (SELECT DISTINCT destination_id FROM production_sites)"
		));
		
		$inf['routes'] = array();
		
		while($ar = $this->getDbLink()->fetch_array($q_id)){
			//Маршрут от production_site до зоны клиента
			$route = $osrm->getRoute(
				array(
					$ar['near_road_lon'].','.$ar['near_road_lat'],
					$inf['road_lon_pos'].','.$inf['road_lat_pos']
				),
				'json',
				NULL,
				array("geometries=polyline")									
			);
			if (!$route->routes || !count($route->routes) || !$route->routes[0]->geometry){
				throw new Exception(self::ER_OSRM_ROUTE_QUERY);
			}

			$inf['routes'][$ar['id']] = array(
				'id' => $ar['id']
				,'name' => $ar['name']
				,'zone_str' => $ar['zone_str']
				,'zone_center_str' => $ar['zone_center_str']
				,'route' => $route
			);
		}
		
	
	}

	private function add_coord_model(&$inf){
		$model = new Model(array('id'=>'Coords_Model'));
		$model->addField(new Field('lon_lower',DT_STRING));
		$model->addField(new Field('lon_upper',DT_STRING));
		$model->addField(new Field('lat_lower',DT_STRING));
		$model->addField(new Field('lat_upper',DT_STRING));
		$model->addField(new Field('lon_pos',DT_STRING));
		$model->addField(new Field('lat_pos',DT_STRING));
		$model->addField(new Field('road_lon_pos',DT_STRING));
		$model->addField(new Field('road_lat_pos',DT_STRING));
		$model->addField(new Field('routes',DT_STRING));
				
		$model->insert();
		$model->lon_lower = $inf['lon_lower'];
		$model->lon_upper = $inf['lon_upper'];
		$model->lat_lower = $inf['lat_lower'];
		$model->lat_upper = $inf['lat_upper'];
		$model->lon_pos = $inf['lon_pos'];
		$model->lat_pos = $inf['lat_pos'];
		$model->road_lon_pos = $inf['road_lon_pos'];
		$model->road_lat_pos = $inf['road_lat_pos'];
		$model->routes = json_encode($inf['routes']);
		
		$this->addModel($model);
	}

	public function get_route_to_zone($pm){
		//need zone center
		
		$p_str = $this->getExtVal($pm,'zone_coords');
		
		$p_str_h = md5($p_str);		
		if(!$_SESSION['get_route_to_zone_cash'] || !$_SESSION['get_route_to_zone_cash'][$p_str_h]){
			
			$points = explode(',',$p_str);
			if (count($points)){
				array_push($points,$points[0]);
				$ar = $this->getDbLink()->query_first(sprintf(
					"SELECT
						replace(replace(st_astext(st_centroid(
							ST_GeomFromText('POLYGON((%s))')
						)), 'POINT('::text, ''::text), ')'::text, ''::text) AS zone_center_str"
					,implode(',',$points)
				));
				if(!is_array($ar) || !count($ar)){
					throw new Exception(self::ER_ZONE_COORD_QUERY);
				}
				$z_coords = explode(' ',$ar['zone_center_str']);
				if(count($z_coords)!=2){
					throw new Exception(self::ER_ZONE_COORD_QUERY);
				}
				$inf = array(
					'lat_pos' =>$z_coords[1]
					,'lon_pos' =>$z_coords[0]
				);
				
				if($_SESSION['get_route_to_zone_cash'] && count($_SESSION['get_route_to_zone_cash'])>10){
					unset($_SESSION['get_route_to_zone_cash']);
				}
				if(!$_SESSION['get_route_to_zone_cash']){
					$_SESSION['get_route_to_zone_cash'] = array();
				}
				$_SESSION['get_route_to_zone_cash'][$p_str_h] = $inf;				
			}
		}
		else{
			$inf = $_SESSION['get_route_to_zone_cash'][$p_str_h];
		}
		
		if(isset($inf) && is_array($inf) && count($inf)){
			$this->make_route_to_zone($inf);
			$this->add_coord_model($inf);
		}		
	}

	public function get_coords_on_name($pm){
		$addr = array();
		$inf = array();
		//'область+Тюменская,город+Тюмень,'.
		$addr['city'] = $this->getExtVal($pm,'name');
		$addr_h = md5($addr['city']);
		
		if(!$_SESSION['get_coords_on_name_cash'] || !$_SESSION['get_coords_on_name_cash'][$addr_h]){
		
			//yandex
			get_inf_on_address($addr,$inf);
			
			$this->make_route_to_zone($inf);
			
			if($_SESSION['get_coords_on_name_cash'] && count($_SESSION['get_coords_on_name_cash'])>10){
				unset($_SESSION['get_coords_on_name_cash']);
			}
			
			if(!$_SESSION['get_coords_on_name_cash']){
				$_SESSION['get_coords_on_name_cash'] = array();
			}
			$_SESSION['get_coords_on_name_cash'][$addr_h] = $inf;
		}
		else{
			$inf = $_SESSION['get_coords_on_name_cash'][$addr_h];
		}
		
		$this->add_coord_model($inf);
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

	/**
	 * new function
	 */
	public function complete_for_order($pm){
		$name_pat_set = ($pm->getParamValue('name_pat')!='');
		$client_id_set = ($pm->getParamValue('client_id')!='');
		
		$limit_cnt = 10;
		
		//Только клиент, пустой шаблон
		//выдаем зоны клиента
		if($client_id_set && !$name_pat_set){
			
			$model = new DestinationForOrderList_Model($this->getDbLink());
		
			$model->query(sprintf(
				"WITH
				last_price AS
					(SELECT
						max(t.date) AS date,
						t.distance_to
					FROM shipment_for_owner_costs AS t
					GROUP BY t.distance_to
					ORDER BY t.distance_to
					)
				,act_price AS
					(SELECT
						t.distance_to,
						t.price
					FROM last_price
					LEFT JOIN shipment_for_owner_costs AS t ON last_price.date=t.date AND last_price.distance_to=t.distance_to
					ORDER BY t.distance_to
					)							
				SELECT DISTINCT ON (o.destination_id)
					dest.id
					,dest.name
					,dest.distance
					,dest.time_route
					,CASE
						WHEN coalesce(dest.special_price,FALSE) = TRUE THEN coalesce(dest.price,0)
						ELSE
							coalesce(
								coalesce(
									(SELECT act_price.price
									FROM act_price
									WHERE dest.distance <= act_price.distance_to
									LIMIT 1
									)
								,dest.price)
							,0)
					END AS price
					,TRUE AS client_dest
					,FALSE AS is_address
				FROM orders AS o
				LEFT JOIN destinations AS dest ON dest.id=o.destination_id
				WHERE o.client_id=%d
				ORDER BY o.destination_id,o.date_time DESC
				LIMIT %d"
				,$this->getExtDbVal($pm,'client_id')
				,$limit_cnt
			));
		}
		
		//шаблон есть Клиента может и не быть
		//выдаем вперед зоны клиента + все зоны по шаблону + адреса по шаблону
		else if($name_pat_set){
			
			$model = new Model(array('id'=>'DestinationForOrderList_Model'));
			
			$client_dest_col = '';
			if($client_id_set){
				$client_dest_col = sprintf(
					'(id IN (SELECT destination_id FROM orders WHERE client_id=%d)) AS client_dest'
					,$this->getExtDbVal($pm,'client_id')
				);
			}
			else{
				$client_dest_col = 'FALSE AS client_dest';
			}
		
			//client destinations
			$q_id = $this->getDbLink()->query(sprintf(
			"WITH
			last_price AS
				(SELECT
					max(t.date) AS date,
					t.distance_to
				FROM shipment_for_owner_costs AS t
				GROUP BY t.distance_to
				ORDER BY t.distance_to
				)
			,act_price AS
				(SELECT
					t.distance_to,
					t.price
				FROM last_price
				LEFT JOIN shipment_for_owner_costs AS t ON last_price.date=t.date AND last_price.distance_to=t.distance_to
				ORDER BY t.distance_to
				)			
			SELECT
				id
				,name
				,distance
				,time_route
				,CASE
					WHEN coalesce(special_price,FALSE) = TRUE THEN coalesce(price,0)
					ELSE
						coalesce(
							coalesce(
								(SELECT act_price.price
								FROM act_price
								WHERE distance <= act_price.distance_to
								LIMIT 1
								)
							,price)
						,0)
				END AS price
				,".$client_dest_col."
			FROM destinations
			WHERE name ilike '%%'||%s||'%%'
			ORDER BY client_dest DESC
			LIMIT 5"
			,$this->getExtDbVal($pm,'name_pat')
			));
			
			while($ar = $this->getDbLink()->fetch_array($q_id)){
				$row = array(
					new Field('id',DT_STRING,array('value'=>$ar['id']))
					,new Field('name',DT_STRING,array('value'=>$ar['name']))
					,new Field('distance',DT_STRING,array('value'=>$ar['distance']))
					,new Field('time_route',DT_STRING,array('value'=>$ar['time_route']))
					,new Field('price',DT_STRING,array('value'=>$ar['price']))
					,new Field('client_dest',DT_BOOL,array('value'=>$ar['client_dest']))
					,new Field('is_address',DT_BOOL,array('value'=>FALSE))
				);
				$model->insert($row);												
				$limit_cnt--;
			}	
			
			if($limit_cnt){				
				//new addresses to model
				//$name_pat_w = str_word_count($this->getExtVal($pm,'name_pat'),1,"АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя");
				$name_pat_w = explode(' ',$this->getExtVal($pm,'name_pat'));
				$name_pat = '%'.implode('%',$name_pat_w).'%';
				$q_id = $this->getDbLink()->query(
					"SELECT search_name FROM fias.find_address("."'".$name_pat."'".",".$limit_cnt.")"
				);
				while($ar = $this->getDbLink()->fetch_array($q_id)){
					$row = array(
						new Field('id',DT_STRING,array('value'=>NULL))
						,new Field('name',DT_STRING,array('value'=>$ar['search_name']))
						,new Field('time_route',DT_STRING)
						,new Field('distance',DT_STRING)
						,new Field('price',DT_STRING)
						,new Field('client_dest',DT_BOOL,array('value'=>FALSE))
						,new Field('is_address',DT_BOOL,array('value'=>TRUE))
					);
					$model->insert($row);												
				}
			}
		}
		else{
			$model = new DestinationForOrderList_Model($this->getDbLink());
			//empty
		}
		
		
		$this->addModel($model);			
	}
	
	public function get_for_client_list($pm){
		$this->addNewModel(sprintf(
		"SELECT * FROM destination_list_view
		WHERE id IN (SELECT DISTINCT o.destination_id FROM orders o WHERE o.client_id=%d %s)
		ORDER BY name"
		,$_SESSION['global_client_id']
		,is_null($_SESSION['global_client_from_date'])? '':sprintf(" AND o.date_time>='%s'",date('Y-m-d',$_SESSION['global_client_from_date']))
		),
		'DestinationList_Model');
	
	}
	
	/**
	 * Example values: lon=>65.697777, lat=>56.942547
	 */
	private function getNearestRoadCoord($lat,$lon,&$roadCoord){
		if (count($points)>=2){
			$osrm = new OSRMV5(OSRM_PROTOCOLE,OSRM_HOST,OSRM_PORT,'v1');
			
			$roadCoord['lat'] = NULL;
			$roadCoord['lon'] = NULL;
			
			$osrm->getNearestRoadCoord(
				$lat,$lon,
				$roadCoord['lat'],$roadCoord['lon']
			);
		}
	}
	
	/*
	 * Дан адрес, необходимо:
	 *	1) получить координаты
	 *	2) Построить зону с зазором х метров
	 *	3) Найти ближайщую от центра зоны дорогу
	 *	4) Проложить дорогу до производства
	 */
	public function get_data_for_new_address($pm){
	
	}
}
?>