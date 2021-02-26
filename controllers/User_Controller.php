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



//require_once('functions/res_rus.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/GlobalFilter.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');
require_once(FRAME_WORK_PATH.'basic_classes/SessionVarManager.php');

require_once('common/PwdGen.php');
require_once('common/SMSService.php');

require_once('functions/CustomEmailSender.php');

//User Agent parser
require_once 'common/matomo/device-detector/autoload.php';
require_once 'common/matomo/device-detector/DeviceDetector.php';
require_once 'common/matomo/device-detector/Parser/AbstractParser.php';
require_once 'common/matomo/device-detector/Parser/AbstractBotParser.php';
require_once 'common/matomo/device-detector/Parser/Bot.php';
require_once 'common/matomo/device-detector/Parser/OperatingSystem.php';
require_once 'common/matomo/device-detector/Yaml/ParserInterface.php';
require_once 'common/matomo/device-detector/Yaml/Spyc.php';
require_once 'common/matomo/device-detector/Cache/CacheInterface.php';
require_once 'common/matomo/device-detector/Cache/StaticCache.php';

require_once 'common/matomo/device-detector/Parser/VendorFragment.php';
require_once 'common/matomo/device-detector/Parser/Client/AbstractClientParser.php';
require_once 'common/matomo/device-detector/Parser/Client/FeedReader.php';
require_once 'common/matomo/device-detector/Parser/Client/MobileApp.php';
require_once 'common/matomo/device-detector/Parser/Client/MediaPlayer.php';
require_once 'common/matomo/device-detector/Parser/Client/PIM.php';
require_once 'common/matomo/device-detector/Parser/Client/Browser.php';
require_once 'common/matomo/device-detector/Parser/Client/Browser/Engine/Version.php';
require_once 'common/matomo/device-detector/Parser/Client/Library.php';
require_once 'common/matomo/device-detector/Parser/Device/AbstractDeviceParser.php';
require_once 'common/matomo/device-detector/Parser/Device/HbbTv.php';
require_once 'common/matomo/device-detector/Parser/Device/Notebook.php';
require_once 'common/matomo/device-detector/Parser/Device/Console.php';
require_once 'common/matomo/device-detector/Parser/Device/CarBrowser.php';
require_once 'common/matomo/device-detector/Parser/Device/Camera.php';
require_once 'common/matomo/device-detector/Parser/Device/PortableMediaPlayer.php';
require_once 'common/matomo/device-detector/Parser/Device/Mobile.php';


use DeviceDetector\DeviceDetector;
use DeviceDetector\Parser\Device\AbstractDeviceParser;
AbstractDeviceParser::setVersionTruncation(AbstractDeviceParser::VERSION_TRUNCATION_NONE);

class User_Controller extends ControllerSQL{

	const PWD_LEN = 6;
	const ER_USER_NOT_DEFIND = "Пользователь не определен!@1000";
	const ER_NO_EMAIL = "Не задан адрес электронный почты!@1001";
	const ER_NO_EMAIL_TEL = "У пользователя нет ни телефона ни эл.почты!";
	const ER_LOGIN_TAKEN = "Имя пользователя занято.";
	const ER_EMAIL_TAKEN = "Есть такой адрес электронной почты.";

	const ER_BANNED = "Доступ запрещен!@1005";
	const ER_DEVICE_BANNED = "Доступ с данного устройства запрещен!@1006";
	
	const ER_AUTOREFRESH_NOT_ALLOWED = "Обновление сессии запрещено!@1010";

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('name'
				,array('required'=>TRUE));
		$pm->addParam($param);
		
				$param = new FieldExtEnum('role_id',',','admin,owner,boss,operator,manager,dispatcher,accountant,lab_worker,supplies,sales,plant_director,supervisor,vehicle_owner,client'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtString('email'
				,array('required'=>FALSE));
		$pm->addParam($param);
		$param = new FieldExtPassword('pwd'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('tel_ext'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('phone_cel'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('create_dt'
				,array(
				'alias'=>'Дата создания'
			));
		$pm->addParam($param);
		$param = new FieldExtBool('banned'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('time_zone_locale_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('production_site_id'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('User.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('User_Model');

			
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
		
				$param = new FieldExtEnum('role_id',',','admin,owner,boss,operator,manager,dispatcher,accountant,lab_worker,supplies,sales,plant_director,supervisor,vehicle_owner,client'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('email'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtPassword('pwd'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('tel_ext'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('phone_cel'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('create_dt'
				,array(
			
				'alias'=>'Дата создания'
			));
			$pm->addParam($param);
		$param = new FieldExtBool('banned'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('time_zone_locale_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('production_site_id'
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
			$pm->addEvent('User.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('User_Model');

			
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
		$pm->addEvent('User.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('User_Model');

			
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
		
		$this->setListModelId('UserList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('UserDialog_Model');		

			
		$pm = new PublicMethod('set_new_pwd');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtPassword('pwd',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('reset_pwd');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('user_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('login');
		
				
	$opts=array();
	
		$opts['alias']='Имя пользователя';
		$opts['length']=50;				
		$pm->addParam(new FieldExtString('name',$opts));
	
				
	$opts=array();
	
		$opts['alias']='Пароль';
		$opts['length']=20;				
		$pm->addParam(new FieldExtPassword('pwd',$opts));
	
				
	$opts=array();
	
		$opts['length']=2;				
		$pm->addParam(new FieldExtString('width_type',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('login_ext');
		
				
	$opts=array();
	
		$opts['alias']='Имя пользователя';
		$opts['length']=50;				
		$pm->addParam(new FieldExtString('name',$opts));
	
				
	$opts=array();
	
		$opts['alias']='Пароль';
		$opts['length']=20;				
		$pm->addParam(new FieldExtPassword('pwd',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('login_refresh');
		
				
	$opts=array();
	
		$opts['length']=50;				
		$pm->addParam(new FieldExtString('refresh_token',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('login_k');
		
				
	$opts=array();
	
		$opts['length']=20;				
		$pm->addParam(new FieldExtString('k',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('logout');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('logout_html');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('login_html');
		
				
	$opts=array();
	
		$opts['alias']='Имя пользователя';
		$opts['length']=50;				
		$pm->addParam(new FieldExtString('name',$opts));
	
				
	$opts=array();
	
		$opts['alias']='Пароль';
		$opts['length']=20;				
		$pm->addParam(new FieldExtPassword('pwd',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('logged');
		
		$this->addPublicMethod($pm);

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('name'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('UserList_Model');

			
		$pm = new PublicMethod('get_profile');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('password_recover');
		
				
	$opts=array();
	
		$opts['length']=100;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('email',$opts));
	
				
	$opts=array();
	
		$opts['length']=10;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('captcha_key',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_user_operator_list');
		
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

			
		$pm = new PublicMethod('update_production_site');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('old_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('production_site_id',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}
		
	
	public function insert($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
	
		$email = $params->getVal('email');
		$tel = $params->getVal('phone_cel');
	
		if (!strlen($email)){
			throw new Exception(User_Controller::ER_NO_EMAIL);
		}
		$new_pwd = '159753';//gen_pwd(self::PWD_LEN);
		$pm->setParamValue('pwd',$new_pwd);
		
		$model_id = $this->getInsertModelId();
		$model = new $model_id($this->getDbLinkMaster());
		$inserted_id_ar = $this->modelInsert($model,TRUE);
		
		$this->pwd_notify($inserted_id_ar['id'],$new_pwd,"'".$new_pwd."'",$email,$tel);
			
		$fields = array();
		foreach($inserted_id_ar as $key=>$val){
			array_push($fields,new Field($key,DT_STRING,array('value'=>$val)));
		}			
		$this->addModel(new ModelVars(
			array('id'=>'InsertedId_Model',
				'values'=>$fields)
			)
		);
			
	}
	
	private function setLogged($logged){
		if ($logged){			
			$_SESSION['LOGGED'] = TRUE;			
		}
		else{
			session_destroy();
			$_SESSION = array();
		}		
	}
	public function logout(){
		$this->setLogged(FALSE);
	}
	
	public function logout_html(){
		$this->logout();
		header("Location: index.php");
	}
	
	/* array with user inf*/
	private function set_logged($ar,&$pubKey){
	
		//global $dbLinkSessMaster;
		
		//check User-Agent header for restricted devices
		$headers = '';			
		if (!function_exists('getallheaders')){
			function getallheaders(){
				$headers = [];
				foreach ($_SERVER as $name => $value){
					if (substr($name, 0, 5) == 'HTTP_'){
						$headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value;
					}
				}
				return $headers;
			}
		} 
		$headers = getallheaders();
		//remove unnecessary headers
		$skeep_hd = ['if-modified-since','cookie','referer','connection','accept-encoding','accept-language','accept','content-length','content-type'];		
		foreach($skeep_hd as $skeep_k){
			if(isset($headers[$skeep_k])){
				unset($headers[$skeep_k]);
			}
		}
		
		if (isset($headers['User-Agent']) && isset($ar['ban_hash']) && strpos($ar['ban_hash'],md5($headers['User-Agent']))!==FALSE){
			throw new Exception(self::ER_DEVICE_BANNED);
		}
		$headers_json = json_encode($headers);		
		
		if (isset($headers['User-Agent'])){
			$userAgent = $headers['User-Agent'];//$_SERVER['HTTP_USER_AGENT'];
			$dd = new DeviceDetector($userAgent);
			$dd->skipBotDetection();
			$dd->parse();
			$header_user_agent = json_encode(array(
				'clientInfo'	=> $dd->getClient()
				,'osInfo'	=> $dd->getOs()
				,'device'	=> $dd->getDeviceName()
				,'brand'	=> $dd->getBrandName()
				,'model'	=> $dd->getModel()
			));
		}
		else{
			$header_user_agent = 'NULL';
		}
		$this->setLogged(TRUE);
		
		$_SESSION['user_id']		= $ar['id'];
		$_SESSION['user_name']		= $ar['name'];
		$_SESSION['role_id']		= $ar['role_id'];
		$_SESSION['locale_id'] 		= 'ru';
		$_SESSION['user_time_locale'] 	= $ar['user_time_locale'];
		$_SESSION['tel_ext'] 		= $ar['tel_ext'];
		if(isset($ar['production_sites_ref'])){
			$_SESSION['production_site_id']	= intval(json_decode($ar['production_sites_ref'])->keys->id);
		}		
		
		$_SESSION['first_shift_start_time'] = $ar['first_shift_start_time'];
		$_SESSION['first_shift_end_time'] = $ar['first_shift_end_time'];
		
		//microservices
		$_SESSION['ms_app_id']		= MS_APP_ID;
		$_SESSION['ms_role_id']		= 'client';
		
		SessionVarManager::addVar('eventServerClientId','',TRUE);
		SessionVarManager::addVar('testVar','1',TRUE);
		
		//global filters				
		if ($ar['role_id']=='client'){
			$client_ar = $this->getDbLink()->query_first(sprintf("SELECT id,account_from_date FROM clients WHERE user_id=%d",$ar['id']));
			$_SESSION['global_client_id'] = (count($client_ar)&&isset($client_ar['id']))? $client_ar['id']:null;
			$_SESSION['global_client_from_date'] = (count($client_ar)&&isset($client_ar['account_from_date']))? strtotime($client_ar['account_from_date']):null;
			
			$model = new ShipmentForClientList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			//client_id
			$field = clone $model->getFieldById('client_id');
			$field->setValue($_SESSION['global_client_id']);
			$filter->addField($field,'=');
			//client_from_date
			/*
			$field2 = clone $model->getFieldById('ship_date');
			$field2->setValue($_SESSION['global_client_from_date']);
			$filter->addField($field2,'>=');
			*/
			GlobalFilter::set('ShipmentForClientList_Model',$filter);
						
			$model = new OrderForClientList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('client_id');
			$field->setValue($_SESSION['global_client_id']);
			$filter->addField($field,'=');
			//client_from_date
			/*
			$field2 = clone $model->getFieldById('date_time');
			$field2->setValue($_SESSION['global_client_from_date']);
			$filter->addField($field2,'>=');
			*/
			GlobalFilter::set('OrderForClientList_Model',$filter);
						
			$model = new ShipmentForOrderList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			//client_id
			$field = clone $model->getFieldById('client_id');
			$field->setValue($_SESSION['global_client_id']);
			$filter->addField($field,'=');
			//client_from_date
			$field2 = clone $model->getFieldById('date_time');
			$field2->setValue($_SESSION['global_client_from_date']);
			$filter->addField($field2,'>=');
			GlobalFilter::set('ShipmentForOrderList_Model',$filter);
			
		}		
		else if ($ar['role_id']=='vehicle_owner'){
			$ar_veh_owner = $this->getDbLink()->query_first(sprintf("SELECT id FROM vehicle_owners WHERE user_id=%d LIMIT 1",$ar['id']));
			if(is_array($ar_veh_owner) && count($ar_veh_owner)){
				$_SESSION['global_vehicle_owner_id'] = $ar_veh_owner['id'];
				$ar_clients = $this->getDbLink()->query_first(
					sprintf(
						"SELECT
							string_agg(client_id::text,',') AS client_list
						FROM vehicle_owner_clients
						WHERE vehicle_owner_id = (SELECT id FROM vehicle_owners WHERE user_id=%d)",
						$ar['id']
					)
				);
				if(is_array($ar_clients) && count($ar_clients) && isset($ar_clients['client_list'])){
					$_SESSION['global_vehicle_owner_client_list'] = $ar_clients['client_list'];
				}
				else{
					$_SESSION['global_vehicle_owner_client_list'] = '0';
				}
			}
			else{
				$_SESSION['global_vehicle_owner_id'] = 0;
			}
						
			$model = new OrderPumpList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('pump_vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('OrderPumpList_Model',$filter);
						
			$model = new ShipmentList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('ShipmentList_Model',$filter);
						
			$model = new ShipmentForVehOwnerList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('ShipmentForVehOwnerList_Model',$filter);
						
			$model = new ShipmentDialog_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('ShipmentDialog_Model',$filter);
						
			$model = new ShipmentPumpList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('pump_vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('ShipmentPumpList_Model',$filter);
						
			$model = new ShipmentPumpForVehOwnerList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('pump_vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('ShipmentPumpForVehOwnerList_Model',$filter);
			
			
			$cl_ar = explode(',',$_SESSION['global_vehicle_owner_client_list']);
			$cl_single = (count($cl_ar)==1);			
			
			//ALWAYS fieldId
			$filter = new ModelWhereSQL();
			if($cl_single){
				$expr = sprintf('client_id = %d',$_SESSION['global_vehicle_owner_client_list']);
			}
			else{
				$expr = sprintf('client_id IN (%s)',$_SESSION['global_vehicle_owner_client_list']);
			}
			$filter->addExpression('vehicle_owner_client_list',$expr,'AND');
			GlobalFilter::set('ShipmentForClientVehOwnerList_Model',$filter);
						
			
			//** owner list ***
			
			//ALWAYS fieldId
			$filter = new ModelWhereSQL();
			$filter->addExpression(
				'vehicle_owner_list',
				sprintf('%d =ANY(vehicle_owners_ar)',
					$_SESSION['global_vehicle_owner_id']
				),
				'AND'
			);
			GlobalFilter::set('VehicleDialog_Model',$filter);
			
			//ALWAYS fieldId
			$filter = new ModelWhereSQL();
			$filter->addExpression(
				'vehicle_owner_list',
				sprintf('%d =ANY(vehicle_owners_ar)',
					$_SESSION['global_vehicle_owner_id']
				),
				'AND'
			);
			GlobalFilter::set('PumpVehicleList_Model',$filter);
			
			//ALWAYS fieldId
			$filter = new ModelWhereSQL();
			$filter->addExpression(
				'vehicle_owner_list',
				sprintf('%d =ANY(pump_vehicle_owners_ar)',
					$_SESSION['global_vehicle_owner_id']
				),
				'AND'
			);
			GlobalFilter::set('PumpVehicleWorkList_Model',$filter);
						
			
		}
				
		$dif_sess_srv = (
			(defined('SESS_SERVER_MASTER')&&defined('DB_SERVER_MASTER')&&SESS_SERVER_MASTER!=DB_SERVER_MASTER)
			&& (isset($_SESSION['ms_app_id'])? $_SESSION['ms_app_id'] : ( defined('MS_APP_ID')? MS_APP_ID : 0))
		);
		
		$sess_db_link = $this->getDbLinkMaster();//$GLOBALS['dbLinkSessMaster'];
		$log_ar = $sess_db_link->query_first(sprintf(
			"SELECT pub_key
			FROM logins
			WHERE session_id='%s' AND user_id =%d AND date_time_out IS NULL%s"
			,session_id()
			,intval($ar['id'])
			,$dif_sess_srv? aprintf(' AND app_id=%d',MS_APP_ID):''
		));
		if (!$log_ar['pub_key']){
			//no user login
			
			$pubKey = uniqid();
			
			$log_ar = $sess_db_link->query_first(
				sprintf("UPDATE logins SET 
					user_id = %d,
					pub_key = '%s',
					date_time_in = now(),
					set_date_time = now(),
					headers_j='%s',
					user_agent='%s'
					FROM (
						SELECT
							l.id AS id
						FROM logins l
						WHERE l.session_id='%s' AND l.user_id IS NULL
						ORDER BY l.date_time_in DESC
						LIMIT 1										
					) AS s
					WHERE s.id = logins.id
					RETURNING logins.id",
					intval($ar['id']),
					$pubKey,
					$headers_json,
					$header_user_agent,
					session_id()
				)
			);				
			if (!$log_ar['id']){
				//нет вообще юзера
				if($dif_sess_srv){
					$log_ar = $sess_db_link->query_first(sprintf(
						"INSERT INTO logins
						(date_time_in,ip,session_id,pub_key,user_id,headers,app_id)
						VALUES(now(),'%s','%s','%s',%d,'%s',%d)
						RETURNING id"
						,$_SERVER["REMOTE_ADDR"]
						,session_id()
						,$pubKey
						,$ar['id']
						,$headers
						,MS_APP_ID
					));								
				}
				else{
					$log_ar = $sess_db_link->query_first(sprintf(
						"INSERT INTO logins
						(date_time_in,ip,session_id,pub_key,user_id,headers)
						VALUES(now(),'%s','%s','%s',%d,'%s')
						RETURNING id"
						,$_SERVER["REMOTE_ADDR"]
						,session_id()
						,$pubKey
						,$ar['id']
						,$headers
					));								
				}
			}
			$_SESSION['LOGIN_ID'] = $ar['id'];			
		}
		else{
			//user logged
			$pubKey = trim($log_ar['pub_key']);
		}
	}
	
	private function do_login($pm,&$pubKey,&$pwd){		
		$pwd = $this->getExtVal($pm,'pwd');
		$ar = $this->getDbLink()->query_first(
			sprintf(
			"SELECT 
				ud.*,
				const_first_shift_start_time_val() AS first_shift_start_time,
				CASE
					WHEN const_shift_length_time_val()>='24 hours'::interval THEN
						const_first_shift_start_time_val()::interval + 
						const_shift_length_time_val()::interval-'24 hours 1 second'::interval
					ELSE
						const_first_shift_start_time_val()::interval + 
						const_shift_length_time_val()::interval-'1 second'::interval
				END AS first_shift_end_time,
				(SELECT string_agg(bn.hash,',') FROM login_device_bans bn WHERE bn.user_id=u.id) AS ban_hash								
			FROM users AS u
			LEFT JOIN users_dialog AS ud ON ud.id=u.id
			WHERE (u.name=%s OR u.email=%s) AND u.pwd=md5(%s)",
			$this->getExtDbVal($pm,'name'),
			$this->getExtDbVal($pm,'name'),
			$this->getExtDbVal($pm,'pwd')
			));
			
		if (!is_array($ar) || !count($ar)){
			throw new Exception(ERR_AUTH);
		}
		else if ($ar['banned']=='t'){
			throw new Exception(self::ER_BANNED);
		}
		
		else{
			$this->set_logged($ar,$pubKey);
			$_SESSION['width_type'] = $pm->getParamValue("width_type");			
		}
	}
	
	public function login($pm){		
		$pubKey = '';
		$pwd = '';
		$this->do_login($pm,$pubKey,$pwd);
		$this->add_auth_model($pubKey,session_id(),md5($pwd),$this->calc_session_expiration_time());
	}

	public function login_refresh($pm){	
	
		if(!defined('SESSION_EXP_SEC') || !intval(SESSION_EXP_SEC)){
			throw new Exception(self::ER_AUTOREFRESH_NOT_ALLOWED);
		}
		
		$p = new ParamsSQL($pm,$this->getDbLink());
		$p->addAll();
		$refresh_token = $p->getVal('refresh_token');
		$refresh_p = strpos($refresh_token,':');
		if ($refresh_p===FALSE){
			throw new Exception(ERR_AUTH);
		}
		$refresh_salt = substr($refresh_token,0,$refresh_p);
		$refresh_salt_db = NULL;
		$f = new FieldExtString('salt');
		FieldSQLString::formatForDb($this->getDbLink(),$f->validate($refresh_salt),$refresh_salt_db);
		
		$refresh_hash = substr($refresh_token,$refresh_p+1);
		
		$sess_db_link = $this->getDbLinkMaster();//$GLOBALS['dbLinkSessMaster'];
		$ar = $sess_db_link->query_first(sprintf(
			"SELECT
				l.id,
				trim(l.session_id) session_id
			FROM logins l
			WHERE l.date_time_out IS NULL AND l.pub_key=%s AND l.user_id=%d"
			,$refresh_salt_db
			,$_SESSION['user_id']
		));
		
		$u_pwd_ar = $this->getDbLink()->query_first(sprintf(
			"SELECT pwd AS u_pwd_hash FROM users WHERE id=%d"
			,$_SESSION['user_id']
		));
		
		if (!$ar['session_id'] || $refresh_hash!=md5($refresh_salt.$_SESSION['user_id'].$u_pwd_ar['u_pwd_hash'])
		){
			throw new Exception(ERR_AUTH);
		}	
				
		try{
			//session prolongation, new id assigning
			$old_sess_id = session_id();
			session_regenerate_id();
			$new_sess_id = session_id();
			$pub_key = uniqid();
			
			$sess_db_link->query('BEGIN');									
			$sess_db_link->query(sprintf(
			"UPDATE sessions
				SET id='%s'
			WHERE id='%s'",$new_sess_id,$old_sess_id));
			
			$sess_db_link->query(sprintf(
			"UPDATE logins
			SET
				set_date_time=now()::timestamp,
				session_id='%s',
				pub_key='%s'
			WHERE id=%d",$new_sess_id,$pub_key,$ar['id']));
			
			$sess_db_link->query('COMMIT');
		}
		catch(Exception $e){
			$sess_db_link->query('ROLLBACK');
			$this->setLogged(FALSE);
			throw new Exception(ERR_AUTH);
		}
		
		$this->add_auth_model($pub_key,$new_sess_id,$u_pwd_ar['u_pwd_hash'],$this->calc_session_expiration_time());
	}

	/**
	 * @returns {DateTime}
	 */
	private function calc_session_expiration_time(){
		return time()+
			(
				(defined('SESSION_EXP_SEC')&&intval(SESSION_EXP_SEC))?
				SESSION_EXP_SEC :
				( (defined('SESSION_LIVE_SEC')&&intval(SESSION_LIVE_SEC))? SESSION_LIVE_SEC : 365*24*60*60)
			);
	}
	
	private function add_auth_model($pubKey,$sessionId,$pwdHash,$expiration){
	
		$_SESSION['token'] = $pubKey.':'.md5($pubKey.$sessionId);
		$_SESSION['tokenExpires'] = $expiration;
		
		$fields = array(
			new Field('access_token',DT_STRING, array('value'=>$_SESSION['token'])),
			new Field('tokenExpires',DT_DATETIME,array('value'=>date('Y-m-d H:i:s',$expiration)))
		);
		
		if(defined('SESSION_EXP_SEC') && intval(SESSION_EXP_SEC)){
			$_SESSION['tokenr'] = $pubKey.':'.md5($pubKey.$_SESSION['user_id'].$pwdHash);			
			array_push($fields,new Field('refresh_token',DT_STRING,array('value'=>$_SESSION['tokenr'])));
		}
		
		setcookie("token",$_SESSION['token'],$expiration,'/');
		
		SessionVarManager::setValue('eventServerClientId',$_SESSION['token'],FALSE);
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Auth_Model',
				'values'=>$fields
			)
		));		
	}
		
	private function pwd_notify($userId,$pwd,$pwdDb,$email,$tel){
		if (strlen($email)){
			//email
			CustomEmailSender::regEMail(
				$this->getDbLinkMaster(),
				sprintf("email_user_reset_pwd(%d,%s)",
					$userId,
					$pwdDb
				),
				NULL,
				'reset_pwd'
			);
		}		
		if (strlen($tel)){
			//SMS
			$sms_service = new SMSService(SMS_LOGIN, SMS_PWD);
			$sms_service->send($tel,
				'Вам назначен новый пароль '.$pwd,
				SMS_SIGN,SMS_TEST);			
		}
	
	}
	
	private function email_confirm_notify($userId,$key){
		//email
		CustomEmailSender::regEMail(
			$this->getDbLinkMaster(),
			sprintf("email_user_email_conf(%d,%s)",
				$userId,$key
			),
			NULL,
			'user_email_conf'
		);
	}
	
	public function password_recover($pm){		
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT id FROM users WHERE email=%s",
		$this->getExtDbVal($pm,'email')
		));
		if (!is_array($ar) || !count($ar)){
			throw new Exception('Адрес электронной почты не найден!');
		}		
		
		$pwd = gen_pwd(self::PWD_LEN);
		$pwd_db = "'".$pwd."'";
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			
			$this->getDbLinkMaster()->query(sprintf(
				"UPDATE users SET pwd=md5(%s)
				WHERE id=%d",
				$pwd_db,$ar['id'])
			);
			$this->pwd_notify($ar['id'],$pwd,$pwd_db,$this->getExtVal($pm,'email'),NULL);
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw new Exception($e);		
		}
	}
	
	public function get_time($pm){
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Time_Model',
				'values'=>array(
					new Field('value',DT_STRING,
						array('value'=>round(microtime(true) * 1000)))
					)
				)
			)
		);		
	}
	
	public function register($pm){
		/*
		1) Проверить почту
		2) занести в users
		3) Подтверждение письма
		4) Отправить письмо для подтверждения мыла. после подтверждения можно заходить через мыло
		5) авторизовать
		*/
		
		$ar = $this->field_check($pm,'email');
		if (count($ar) && $ar['ex']=='t'){
			throw new Exception(self::ER_EMAIL_TAKEN);
		}
		
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			
			$inserted_id_ar = $this->getDbLinkMaster()->query_first(sprintf(
			"INSERT INTO users (role_id,name,pwd,email,pers_data_proc_agreement,time_zone_locale_id)
			values ('client'::role_types,%s,md5(%s),%s,TRUE,1)
			RETURNING id",
			$this->getExtDbVal($pm,'name'),
			$this->getExtDbVal($pm,'pwd'),
			$this->getExtDbVal($pm,'email')
			));

			$ar_email_key = $this->getDbLinkMaster()->query_first(sprintf(
				"INSERT INTO user_email_confirmations (key,user_id)
				values (md5(CURRENT_TIMESTAMP::text),%d)
				RETURNING key",
				$inserted_id_ar['id']
			));
	
			ExpertEmailSender::addEMail(
				$this->getDbLinkMaster(),
				sprintf("email_new_account(%d,%s)",
					$inserted_id_ar['id'],$this->getExtDbVal($pm,'pwd')
				),
				NULL,
				'reset_pwd'
			);
		
			$this->email_confirm_notify($inserted_id_ar['id'],"'".$ar_email_key['key']."'");
		
			$ar = $this->getDbLink()->query_first(
				sprintf(
				"SELECT 
					u.*,
					const_first_shift_start_time_val() AS first_shift_start_time,
					CASE
						WHEN const_shift_length_time_val()>='24 hours'::interval THEN
							const_first_shift_start_time_val()::interval + 
							const_shift_length_time_val()::interval-'24 hours 1 second'::interval
						ELSE
							const_first_shift_start_time_val()::interval + 
							const_shift_length_time_val()::interval-'1 second'::interval
					END AS first_shift_end_time				
				FROM users_dialog AS u
				WHERE u.id=%d",
				$inserted_id_ar['id']
				));
			$pub_key = '';
			$this->set_logged($ar,$pub_key);
			
			$this->getDbLinkMaster()->query('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			throw new Exception($e);		
		}				
	}

	private function field_check($pm,$field){
		return $this->getDbLink()->query_first(sprintf("SELECT TRUE AS ex FROM users WHERE ".$field."=%s",$this->getExtDbVal($pm,$field)));
	}
	
	public function name_check($pm){
		$ar = $this->field_check($pm,'name');
		if (count($ar) && $ar['ex']=='t'){
			throw new Exception(self::ER_LOGIN_TAKEN);
		}
	}

	public function email_confirm($pm){
		try{
			$this->getDbLinkMaster()->query('BEGIN');
			$ar = $this->getDbLinkMaster()->query_first(sprintf(
				"UPDATE user_email_confiramtions
				SET confirmed=TRUE
				WHERE key=%s AND confirmed=FALSE
				RETURNING user_id",
				$this->getExtDbVal($pm,'key')
			));
			if (!count($ar)){
				throw new Exception('ER');
			}

			$this->getDbLinkMaster()->query(sprintf(
				"UPDATE users
				SET email_confirmed=TRUE
				WHERE id=%d",
				$ar['user_id']
			));
			
			$this->getDbLinkMaster()->query('COMMIT');
			
			header('index.php?v=EmailConfirmed');
		}	
		catch(Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');
			
			header('HTTP/1.0 404 Not Found');
		}
	}
	public function get_profile(){
		if (!$_SESSION['user_id']){
			throw new Exception(self::ER_USER_NOT_DEFIND);	
		}
		$m = new UserProfile_Model($this->getDbLink());		
		$f = $m->getFieldById('id');
		$f->setValue($_SESSION['user_id']);		
		$where = new ModelWhereSQL();
		$where->addField($f,'=');
		$m->select(FALSE,$where,null,null,null,null,null,null,true);		
		$this->addModel($m);
	}
	
	public function login_k($pm){
		$link = $this->getDbLink();
		
		$k = NULL;
		FieldSQLString::formatForDb($link,$pm->getParamValue('k'),$k);
		
		/*
				u.name,
				u.role_id,
				u.id,
				get_role_types_descr(u.role_id) AS role_descr,
				u.tel_ext,
		
		*/
		$ar = $link->query_first(
			sprintf(
			"SELECT 
				u.*,
				usr.pwd AS pwd,
				const_first_shift_start_time_val() AS first_shift_start_time,
				CASE
					WHEN const_shift_length_time_val()>='24 hours'::interval THEN
						const_first_shift_start_time_val()::interval + 
						const_shift_length_time_val()::interval-'24 hours 1 second'::interval
					ELSE
						const_first_shift_start_time_val()::interval + 
						const_shift_length_time_val()::interval-'1 second'::interval
				END AS first_shift_end_time				
				
			FROM user_mac_addresses AS ma
			LEFT JOIN users_dialog AS u ON u.id=ma.user_id
			LEFT JOIN users AS usr ON usr.id=ma.user_id
			WHERE ma.mac_address=%s",
			$k));
			
		if ($ar){
			$pub_key = '';
			$this->set_logged($ar,$pub_key);
			
			//session id
			$this->addNewModel(sprintf(
			"SELECT '%s' AS id",session_id()
			),'session');
			
			$this->add_auth_model($pub_key,session_id(),$ar['pwd'],$this->calc_session_expiration_time());			
			
			//user inf
			$this->addModel(new ModelVars(
				array('name'=>'Vars',
					'id'=>'UserInf_Model',
					'values'=>array(
						new Field('name',DT_STRING, array('value'=>$ar['name'])),
						new Field('tel_ext',DT_STRING,array('value'=>$ar['tel_ext']))
					)
				)
			));		
			
		}
		else{
			throw new Exception(ERR_AUTH);
		}
	
	}
	
	private function update_pwd($userId,$pwd,$email,$tel){
		$pwd_db = NULL;
		FieldSQLString::formatForDb($this->getDbLink(),
			$pwd,
			$pwd_db);
	
		$this->pwd_notify($userId,$pwd,$pwd_db,$email,$tel);
		
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE users SET pwd=md5(%s)
			WHERE id=%d",
			$pwd_db,$userId)
		);
	}
	
	public function reset_pwd($pm){
		
		$ar = $this->getDbLink()->query_first(sprintf(
		"SELECT email,phone_cel
		FROM users
		WHERE id=%d",
		$this->getExtDbVal($pm,'user_id')
		));
		if (!is_array($ar)||!count($ar)){
			throw new Exception(User_Controller::ER_USER_NOT_DEFIND);
		}		
		if (!strlen($ar['email'])&&!strlen($ar['phone_cel'])){
			throw new Exception(User_Controller::ER_NO_EMAIL_TEL);
		}
		
		$this->update_pwd(
			$this->getExtDbVal($pm,'user_id'),
			gen_pwd(self::PWD_LEN),
			$ar['email'],$ar['phone_cel']);
	}
	
	
	public function update($pm){
		if($this->getExtDbVal($pm,'old_id')!=$_SESSION['user_id'] && $_SESSION['role_id']!='owner'){
			throw new Exception('Permission denied!');
		}
		parent::update($pm);
		
	}

	public function update_production_site($pm){
		$this->getDbLinkMaster()->query(
			sprintf(
				"UPDATE users
				SET production_site_id = %d
				WHERE id=%d",
				$this->getExtDbVal($pm,'production_site_id'),
				$this->getExtDbVal($pm,'old_id')
			)
		);
	}
	
	public function get_user_operator_list($pm){
		$model = new UserOperatorList_Model($this->getDbLink());
		$model->query("SELECT * FROM user_operator_list",TRUE);
		$this->addModel($model);
	}

	public static function closeConnection($conn,$pubKey){
		$conn->query(sprintf(
			"SELECT pg_notify(
			'User.logout'
			,json_build_object(
				'params',json_build_object(
					'pub_key','%s'
				)
			)::text
			)"
			,$pubKey
		));					
	
	}
	

}
?>