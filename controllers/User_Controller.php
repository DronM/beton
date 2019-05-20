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



//require_once('functions/res_rus.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/GlobalFilter.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelWhereSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

require_once('common/PwdGen.php');
require_once('common/SMSService.php');

require_once('functions/CustomEmailSender.php');

class User_Controller extends ControllerSQL{

	const PWD_LEN = 6;
	const ER_USER_NOT_DEFIND = "Пользователь не определен!@1000";
	const ER_NO_EMAIL = "Не задан адрес электронный почты!@1001";
	const ER_NO_EMAIL_TEL = "У пользователя нет ни телефона ни эл.почты!";
	const ER_LOGIN_TAKEN = "Имя пользователя занято.";
	const ER_EMAIL_TAKEN = "Есть такой адрес электронной почты.";

	const ER_BANNED = "Доступ запрещен!@1005";

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('name'
				,array('required'=>TRUE));
		$pm->addParam($param);
		
				$param = new FieldExtEnum('role_id',',','admin,owner,boss,operator,manager,dispatcher,accountant,lab_worker,supplies,sales,plant_director,supervisor,vehicle_owner'
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
		
				$param = new FieldExtEnum('role_id',',','admin,owner,boss,operator,manager,dispatcher,accountant,lab_worker,supplies,sales,plant_director,supervisor,vehicle_owner'
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
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('User_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
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
	private function set_logged($ar){
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
		
		//global filters				
		if ($ar['role_id']=='vehicle_owner'){
			$ar_veh_owner = $this->getDbLink()->query_first(sprintf("SELECT id FROM vehicle_owners WHERE user_id=%d",$ar['id']));
			if(is_array($ar_veh_owner) && count($ar_veh_owner)){
				$_SESSION['global_vehicle_owner_id'] = $ar_veh_owner['id'];
			}
			else{
				$_SESSION['global_vehicle_owner_id'] = 0;
			}
						
			$model = new VehicleDialog_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('VehicleDialog_Model',$filter);
						
			$model = new PumpVehicleList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('PumpVehicleList_Model',$filter);
						
			$model = new ShipmentList_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('ShipmentList_Model',$filter);
						
			$model = new ShipmentDialog_Model($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById('vehicle_owner_id');
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('ShipmentDialog_Model',$filter);
			
		}
		
		$log_ar = $this->getDbLinkMaster()->query_first(
			sprintf("SELECT pub_key FROM logins
			WHERE session_id=md5('%s') AND user_id =%d AND date_time_out IS NULL",
			session_id(),intval($ar['id']))
		);
		if (!$log_ar['pub_key']){
			//no user login
			
			$this->pub_key = uniqid();
			
			$log_ar = $this->getDbLinkMaster()->query_first(
				sprintf("UPDATE logins SET 
					user_id = '%s',
					pub_key = '%s'
				WHERE session_id=md5('%s') AND user_id IS NULL
				RETURNING id",
				$ar['id'],$this->pub_key,session_id())
			);				
			if (!$log_ar['id']){
				//нет вообще юзера
				$log_ar = $this->getDbLinkMaster()->query_first(
					sprintf("INSERT INTO logins
					(date_time_in,ip,session_id,pub_key,user_id)
					VALUES(now(),'%s',md5('%s'),'%s',%d)
					RETURNING id",
					$_SERVER["REMOTE_ADDR"],
					session_id(),$this->pub_key,$ar['id'])
				);								
			}
			$_SESSION['LOGIN_ID'] = $ar['id'];			
		}
		else{
			//user logged
			$this->pub_key = trim($log_ar['pub_key']);
		}
	}
	
	private function do_login($pm){		
		$this->pwd = $this->getExtVal($pm,'pwd');
		$ar = $this->getDbLink()->query_first(
			sprintf(
			"SELECT 
				ud.*
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
			$this->set_logged($ar);
			
		}
	}
	
	private function login_ext($pm){
		
		$access_token = $this->pub_key.':'.md5($this->pub_key.session_id());
		$refresh_token = $this->pub_key.':'.md5($this->pub_key.$_SESSION['user_id'].md5($this->pwd));
		
		$_SESSION['token'] = $access_token;
		$_SESSION['tokenr'] = $refresh_token;
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Auth_Model',
				'values'=>array(
					new Field('access_token',DT_STRING,
						array('value'=>$access_token)),
					new Field('refresh_token',DT_STRING,
						array('value'=>$refresh_token)),
					new Field('expires_in',DT_INT,
						array('value'=>SESSION_EXP_SEC)),
					new Field('time',DT_STRING,
						array('value'=>round(microtime(true) * 1000)))
				)
			)
		));
		
		if (defined('PARAM_TOKEN')){
			if ($this->getExtVal($pm,'rememberMe')){
				setcookie(PARAM_TOKEN,$access_token,time()+SESSION_EXP_SEC,'expert72',$_SERVER['HTTP_HOST']);
			}
			else{
				setcookie(PARAM_TOKEN,NULL,-1,'expert72',$_SERVER['HTTP_HOST']);
			}
		}
	}
	
	public function login($pm){		
		$this->do_login($pm);
		$this->login_ext($pm);
	}

	public function login_refresh($pm){
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
		
		$ar = $this->getDbLink()->query_first(
		"SELECT
			l.id,
			trim(l.session_id) session_id,
			u.pwd u_pwd_hash
		FROM logins l
		LEFT JOIN users u ON u.id=l.user_id
		WHERE l.date_time_out IS NULL
			AND l.pub_key=".$refresh_salt_db);
		
		if (!$ar['session_id']
		||$refresh_hash!=md5($refresh_salt.$_SESSION['user_id'].$ar['u_pwd_hash'])
		){
			throw new Exception(ERR_AUTH);
		}	
				
		$link = $this->getDbLinkMaster();
		
		try{
			//продляем сессию, обновляем id
			$old_sess_id = session_id();
			session_regenerate_id();
			$new_sess_id = session_id();
			$pub_key = uniqid();
			
			$link->query('BEGIN');									
			$link->query(sprintf(
			"UPDATE sessions
				SET id=md5('%s')
			WHERE id=md5('%s')",$new_sess_id,$old_sess_id));
			
			$link->query(sprintf(
			"UPDATE logins
				SET set_date_time=now()::timestamp,
					session_id=md5('%s'),
					pub_key='%s'
			WHERE id=%d",$new_sess_id,$pub_key,$ar['id']));
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
			$this->setLogged(FALSE);
			throw new Exception(ERR_AUTH);
		}
		
		//новые данные		
		$access_token = $pub_key.':'.md5($pub_key.$new_sess_id);
		$refresh_token = $pub_key.':'.md5($pub_key.$_SESSION['user_id'].$ar['u_pwd_hash']);
		
		$_SESSION['token'] = $access_token;
		$_SESSION['tokenr'] = $refresh_token;
		
		$this->addModel(new ModelVars(
			array('name'=>'Vars',
				'id'=>'Auth_Model',
				'values'=>array(
					new Field('access_token',DT_STRING,
						array('value'=>$access_token)),
					new Field('refresh_token',DT_STRING,
						array('value'=>$refresh_token)),
					new Field('expires_in',DT_INT,
						array('value'=>SESSION_EXP_SEC)),
					new Field('time',DT_STRING,
						array('value'=>round(microtime(true) * 1000)))						
				)
			)
		));		
	}
		
	private function pwd_notify($userId,$pwd,$pwdDb,$email,$tel){
		if (strlen($email)){
			//email
			CustomEmailSender::addEMail(
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
		CustomEmailSender::addEMail(
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
					u.*
				FROM users_dialog AS u
				WHERE u.id=%d",
				$inserted_id_ar['id']
				));
		
			$this->set_logged($ar);
			
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
		
		$ar = $link->query_first(
			sprintf(
			"SELECT 
				u.name,
				u.role_id,
				u.id,
				get_role_types_descr(u.role_id) AS role_descr,
				u.tel_ext
			FROM user_mac_addresses AS ma
			LEFT JOIN users AS u ON u.id=ma.user_id
			WHERE ma.mac_address=%s",
			$k));
			
		if ($ar){
			$this->set_logged($ar);
			
			//session id
			$this->addNewModel(sprintf(
			"SELECT '%s' AS id",session_id()
			),'session');
			
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
	

}
?>