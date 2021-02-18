<?php
require_once(FRAME_WORK_PATH.'basic_classes/Controller.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTime.php');

require_once(FRAME_WORK_PATH.'basic_classes/SessionVarManager.php');
require_once(FRAME_WORK_PATH.'basic_classes/EventSrv.php');

include("common/pChart2.1.3/class/pData.class.php");
include("common/pChart2.1.3/class/pDraw.class.php");
include("common/pChart2.1.3/class/pImage.class.php");

require_once(ABSOLUTE_PATH.'functions/Beton.php');

class Graph_Controller extends Controller{
	
	public function __construct(){
		parent::__construct();

		$param_from = new FieldExtDateTime('date_time_from'
				,array('required'=>TRUE));		
		$param_to = new FieldExtDateTime('date_time_to'
				,array('required'=>TRUE));		
				
		$pm = new PublicMethod('get_plant_load');
		$pm->addParam($param_from);				
		$pm->addParam($param_to);
		$this->addPublicMethod($pm);
		
		$pm = new PublicMethod('make_plant_load');
		$pm->addParam($param_from);
		$pm->addParam($param_to);
		$this->addPublicMethod($pm);		
		
		$pm = new PublicMethod('clear_cache');
		$pm->addParam(new FieldExtDateTime('date_from'
				,array('required'=>TRUE)));
		$pm->addParam(new FieldExtDateTime('date_to'
				,array('required'=>TRUE)));
		$this->addPublicMethod($pm);		
		
	}
	private function get_contents($cache){
		$im = imagecreatefrompng($cache);
		ob_start();
		imagepng($im);	
		$contents =  ob_get_contents();
		ob_end_clean();		
		return $contents;
	}
	/* ???? Переделать очистку кэша из контроллеров*/
	private static function clearCache($date_from,$date_to,$on_slave=FALSE){
		$link_master = Graph_Controller::get_db_con_master();
		$link_master->query(sprintf(
		"UPDATE plant_load_charts SET state=0 WHERE id='%s'",
		date('Y-m-d',$date_from)));
		
		//event
		if(defined('APP_NAME') && defined('APP_SERVER_HOST') && defined('APP_SERVER_PORT')
		){
			//change to all
			//'emitterId'=>SessionVarManager::getValue('eventServerClientId')			
			$event_par = [				
				'cond_date'=>date('Y-m-d',$date_from)
			];
			EventSrv::publishAsync('Graph.change',$event_par,APP_NAME,APP_SERVER_HOST,APP_SERVER_PORT);
		}		
	}
	private static function get_db_con(){
		$dbLink = new DB_Sql;
		$dbLink->appname = APP_NAME;
		$dbLink->technicalemail = TECH_EMAIL;
		$dbLink->reporterror = DEBUG;
		$dbLink->database	= DB_NAME;
		$dbLink->connect(DB_SERVER,DB_USER,DB_PASSWORD);			
		return $dbLink;
	}
	private static function get_db_con_master(){
		$dbLink = new DB_Sql;
		$dbLink->appname = APP_NAME;
		$dbLink->technicalemail = TECH_EMAIL;
		$dbLink->reporterror = DEBUG;
		$dbLink->database	= DB_NAME;
		$dbLink->connect(DB_SERVER_MASTER,DB_USER,DB_PASSWORD);			
		return $dbLink;
	}
	
	private static function make_load_graph($dbLink,$date_from,$date_to,&$chartData){
		$dt1 = date('Y-m-d H:i:s',$date_from);
		$dt2 = date('Y-m-d H:i:s',$date_to);
		
		$consts = $dbLink->query_first("SELECT
			const_max_hour_load_val() AS max_h_load,
			const_chart_step_min_val() AS step_min");
		if (!$consts || !is_array($consts)){
			throw new Exception("Constants not defined!");
		}
		$query_orders =sprintf("
			SELECT  date_time,date_time_to,
				quant,unload_speed
			FROM orders
			WHERE date_time BETWEEN '%s' AND '%s'
			ORDER BY date_time",$dt1,$dt2);
		$query_shipments = sprintf("
			SELECT ship_date_time,
			quant AS quant_shipped
			FROM shipments
			WHERE ship_date_time BETWEEN '%s' AND '%s'
			ORDER BY ship_date_time",$dt1,$dt2);			
			
		$chart_data = array();		
		$QUANT_NORM_ON_STEP = ceil($consts['max_h_load']*$consts['step_min']/60);		
		$STEP_SEC = $consts['step_min']*60;
		
		//all points to chart
		for ($i=$date_from;$i <= $date_to+1;$i+=$STEP_SEC){
			$chart_data[$i] = array("time"=>date('H:i',$i),
				"orders"=>0,"shipments"=>0,
				"norm"=>$QUANT_NORM_ON_STEP);
		}
		$chart_data[$i-$STEP_SEC]["orders"] = VOID;
		$chart_data[$i-$STEP_SEC]["shipments"] = VOID;
		
		//orders
		$chart_data[$date_from]["orders"] = 0;//$QUANT_NORM_ON_STEP;
		$dbLink->query($query_orders);
		while ($ar = $dbLink->fetch_array()){
			$order_unload_speed = $ar['unload_speed']*$consts['step_min']/60;
			$quant = $ar['quant'];
			
			$time_from = strtotime($ar['date_time'])+1;
			$time_from = ceil($time_from / $STEP_SEC) * $STEP_SEC;
			$time_to = strtotime($ar['date_time_to'])+1;
			$time_to = ceil($time_to / $STEP_SEC) * $STEP_SEC;
			$time_to = min($time_to,$date_to+1);
			
			for ($i=$time_from;$i < $time_to;$i+=$STEP_SEC){
				$ind = ceil($i / $STEP_SEC) * $STEP_SEC;
				
				$quant_cur = min($quant,$order_unload_speed);				
				$chart_data[$ind]["orders"]+= $quant_cur;
				$quant-=$quant_cur;			
				if ( (($i+$STEP_SEC)>=$time_to)
					&& $quant > 0){
					//last iteration
					$chart_data[$ind]["orders"]+= $quant;
				}
			}
		}
		
		//shipment
		$chart_data[$date_from]["shipments"] = 0;//$QUANT_NORM_ON_STEP;
		$dbLink->query($query_shipments);
		while ($ar = $dbLink->fetch_array()){
			$seconds = strtotime($ar['ship_date_time']);
			$ind = ceil($seconds / $STEP_SEC) * $STEP_SEC;
			$chart_data[$ind]["shipments"]+= $ar["quant_shipped"];
		}
		
		//var_dump($chart_data);
		//exit;
		
		$shipments = array();
		$norm = array();
		$orders = array();
		$times = array();				
		foreach ($chart_data as $d){
			array_push($times,$d["time"]);
			array_push($norm,$d["norm"]);
			array_push($orders,$d["orders"]);
			array_push($shipments,$d["shipments"]);
		}
		$chartData = array(
			'shipments' => $shipments,
			'norm' => $norm,
			'orders' => $orders,
			'times' => $times
		);
		
	}
	
	public function get_plant_load($pm){
		$date_from = $pm->getParamValue('date_time_from');
		$date_to = $pm->getParamValue('date_time_to');		
		
		$dbLink = Graph_Controller::get_db_con();
		$dbLinkMaster = Graph_Controller::get_db_con_master();
		$this->addModel(self::getPlantLoadModel($dbLink,$dbLinkMaster,$date_from,$date_to));
	}
	
	/**
	 * returns model
	 */
	public static function getPlantLoadModel($dbLink,$dbLinkMaster,$dateFrom,$dateTo){
		$chart_data_s = '';
		$tries = 2;
		$sleep_interv = 5;
		
		while ($tries){
			$ar = $dbLink->query_first(
				sprintf("SELECT
					state,
					chart_data
				FROM plant_load_charts WHERE id='%s'::date",
				date("Y-m-d",$dateFrom))
				);
			
			if (is_array($ar) && count($ar) && $ar['state']){
				if ($ar['state']=='2'){
					$chart_data_s = $ar['chart_data'];
					break;
				}
				else if ($ar['state']=='0'){
					break;
				}
			}
			else{
				break;
			}
			sleep($sleep_interv);
			$tries--;				
		}
		
		if (!strlen($chart_data_s)){
			//new chart
			$dbLinkMaster->query(sprintf(
				"SELECT plant_load_charts_update('%s'::date,1,'')",
				date("Y-m-d",$dateFrom)
			));
			$chart_data = NULL;
			self::make_load_graph($dbLink,$dateFrom,$dateTo,$chart_data);
			
			$chart_data_s = json_encode($chart_data);
			$dbLinkMaster->query(sprintf(
				"SELECT plant_load_charts_update('%s'::date,2,'%s')",
				date("Y-m-d",$dateFrom),
				$chart_data_s
			));			
		}
		
		return new ModelVars(
			array('name'=>'Vars',
				'id'=>'Graph_Model',
				'values'=>array(
					new Field('chart_data',DT_STRING,array('value'=>$chart_data_s))
				)
			)
		);	
	}
	
	public function make_plant_load($pm){
		$date_from = $pm->getParamValue('date_time_from');
		$date_to = $pm->getParamValue('date_time_to');
		
		$dbLinkMaster = Graph_Controller::get_db_con_master();
		$dbLinkMaster->query(sprintf(
		"SELECT plant_load_charts_update('%s'::date,1,'')",
		date("Y-m-d",$date_from)
		));
		
		//make new graph
		$chart_data = array();
		$this->make_load_graph($this->getDbLink(),$date_from,$date_to,$chart_data);
		$dbLinkMaster = Graph_Controller::get_db_con_master();
		$dbLinkMaster->query(sprintf(
			"SELECT plant_load_charts_update('%s'::date,2,'%s')",
			date("Y-m-d",$date_from),
			json_encode($chart_data)
		));
	}
	
	/*
	public static function getShiftBounds($dbLink,$dateTime,&$from,&$to){
		$ar = $dbLink->query_first(
			sprintf("SELECT
			d1,d2 FROM get_shift_bounds('%s')
			AS (d1 timestamp, d2 timestamp)",date('Y-m-d H:i:s',$dateTime))
			);
		$from = strtotime($ar['d1']);
		$to = strtotime($ar['d2']);
	}
	*/
	
	public static function clearCacheOnDate($dbLink,$dateTime){
		$shift_from = Beton::shiftStart($dateTime);
		$shift_to = Beton::shiftEnd($shift_from);

		Graph_Controller::clearCache($shift_from,$shift_to);	
	}	
	public static function clearCacheOnOrderId($dbLink,$orderId){
		$ar = $dbLink->query_first(
			sprintf("SELECT d1,d2
			FROM get_shift_bounds(
				(SELECT date_time FROM orders WHERE id=%d))
			AS (d1 timestamp, d2 timestamp)",
				$orderId)
			);
		if (is_array($ar)){
			Graph_Controller::clearCache(strtotime($ar["d1"]),
				strtotime($ar["d2"]));
		}	
	}		
	public static function clearCacheOnShipId($dbLink,$shipId){
		$ar = $dbLink->query_first(
			sprintf("SELECT d1,d2
			FROM get_shift_bounds(
				(SELECT ship_date_time
				FROM shipments WHERE id=%d))
			AS (d1 timestamp, d2 timestamp)",
				$shipId)
			);
		if (is_array($ar)){
			Graph_Controller::clearCache(strtotime($ar["d1"]),strtotime($ar["d2"]));
		}	
	}		
	public function clear_cache($pm){
		$date_from = $pm->getParamValue('date_from');
		$date_to = $pm->getParamValue('date_to');
		Graph_Controller::clearCache($date_from,$date_to);
	}
}
?>