<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'User'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

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

class <xsl:value-of select="@id"/>_Controller extends ControllerSQL{

	const PWD_LEN = 6;
	const ER_USER_NOT_DEFIND = "Пользователь не определен!@1000";
	const ER_NO_EMAIL = "Не задан адрес электронный почты!@1001";
	const ER_NO_EMAIL_TEL = "У пользователя нет ни телефона ни эл.почты!";
	const ER_LOGIN_TAKEN = "Имя пользователя занято.";
	const ER_EMAIL_TAKEN = "Есть такой адрес электронной почты.";

	const ER_BANNED = "Доступ запрещен!@1005";

	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}
		
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
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
		
		$_SESSION['first_shift_start_time'] = $ar['first_shift_start_time'];
		$_SESSION['first_shift_end_time'] = $ar['first_shift_end_time'];
		
		//global filters				
		if ($ar['role_id']=='vehicle_owner'){
			$ar_veh_owner = $this->getDbLink()->query_first(sprintf("SELECT id,client_id FROM vehicle_owners WHERE user_id=%d",$ar['id']));
			if(is_array($ar_veh_owner) &amp;&amp; count($ar_veh_owner)){
				$_SESSION['global_vehicle_owner_id'] = $ar_veh_owner['id'];
				$_SESSION['global_client_vehicle_owner_id'] = $ar_veh_owner['client_id'];
			}
			else{
				$_SESSION['global_vehicle_owner_id'] = 0;
			}
			<xsl:for-each select="/metadata/models/model/globalFilter[@id='vehicle_owner_id']">
			<xsl:variable name="model_id" select="concat(../@id,'_Model')"/>
			<xsl:variable name="field_id">
				<xsl:choose>
					<xsl:when test="@fieldId">'<xsl:value-of select="@fieldId"/>'</xsl:when>
					<xsl:otherwise>'vehicle_owner_id'</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>			
			$model = new <xsl:value-of select="$model_id"/>($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById(<xsl:value-of select="$field_id"/>);
			$field->setValue($_SESSION['global_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('<xsl:value-of select="$model_id"/>',$filter);
			</xsl:for-each>
			
			<xsl:for-each select="/metadata/models/model/globalFilter[@id='client_vehicle_owner_id']">
			<xsl:variable name="model_id" select="concat(../@id,'_Model')"/>
			<xsl:variable name="field_id">
				<xsl:choose>
					<xsl:when test="@fieldId">'<xsl:value-of select="@fieldId"/>'</xsl:when>
					<xsl:otherwise>'client_vehicle_owner_id'</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>			
			$model = new <xsl:value-of select="$model_id"/>($this->getDbLink());
			$filter = new ModelWhereSQL();
			$field = clone $model->getFieldById(<xsl:value-of select="$field_id"/>);
			$field->setValue($_SESSION['global_client_vehicle_owner_id']);
			$filter->addField($field,'=');
			GlobalFilter::set('<xsl:value-of select="$model_id"/>',$filter);
			</xsl:for-each>
			
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
				ud.*,
				const_first_shift_start_time_val() AS first_shift_start_time,
				CASE
					WHEN const_shift_length_time_val()>='24 hours'::interval THEN
						const_first_shift_start_time_val()::interval + 
						const_shift_length_time_val()::interval-'24 hours 1 second'::interval
					ELSE
						const_first_shift_start_time_val()::interval + 
						const_shift_length_time_val()::interval-'1 second'::interval
				END AS first_shift_end_time				
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
		if (count($ar) &amp;&amp; $ar['ex']=='t'){
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
		if (count($ar) &amp;&amp; $ar['ex']=='t'){
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
		if (!strlen($ar['email'])&amp;&amp;!strlen($ar['phone_cel'])){
			throw new Exception(User_Controller::ER_NO_EMAIL_TEL);
		}
		
		$this->update_pwd(
			$this->getExtDbVal($pm,'user_id'),
			gen_pwd(self::PWD_LEN),
			$ar['email'],$ar['phone_cel']);
	}
	
	
	public function update($pm){
		if($this->getExtDbVal($pm,'old_id')!=$_SESSION['user_id'] &amp;&amp; $_SESSION['role_id']!='owner'){
			throw new Exception('Permission denied!');
		}
		parent::update($pm);
	}
	
	public function get_user_operator_list($pm){
		$model = new UserOperatorList_Model($this->getDbLink());
		$model->query("SELECT * FROM user_operator_list",TRUE);
		$this->addModel($model);
	}
	
</xsl:template>

</xsl:stylesheet>
