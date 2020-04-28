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



require_once(USER_CONTROLLERS_PATH.'Shipment_Controller.php');

require_once(USER_MODELS_PATH.'ProductionMaterialList_Model.php');

class Production_Controller extends ControllerSQL{

	const LOG_LEVEL_DEBUG = 9;
	const LOG_LEVEL_NOTE = 3;
	const LOG_LEVEL_ERROR = 0;
	
	const ER_NO_MSSQL_DRIVER = 'No MSSQL driver installed!';

	private $mssqlConnections;


	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('production_id'
				,array('required'=>TRUE,
				'alias'=>'Elkon production ID'
			));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('production_dt_start'
				,array('required'=>TRUE,
				'alias'=>'Начало производства в Elkon'
			));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('production_dt_end'
				,array(
				'alias'=>'Окончание производства в Elkon'
			));
		$pm->addParam($param);
		$param = new FieldExtString('production_user'
				,array(
				'alias'=>'Пользователь Elkon'
			));
		$pm->addParam($param);
		$param = new FieldExtString('production_vehicle_descr'
				,array('required'=>TRUE,
				'alias'=>'ТС в Elkon'
			));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('dt_start_set'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('dt_end_set'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('production_site_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('shipment_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('concrete_type_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('vehicle_schedule_state_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('vehicle_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('production_concrete_type_descr'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('material_tolerance_violated'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Production_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('production_id'
				,array(
			
				'alias'=>'Elkon production ID'
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('production_dt_start'
				,array(
			
				'alias'=>'Начало производства в Elkon'
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('production_dt_end'
				,array(
			
				'alias'=>'Окончание производства в Elkon'
			));
			$pm->addParam($param);
		$param = new FieldExtString('production_user'
				,array(
			
				'alias'=>'Пользователь Elkon'
			));
			$pm->addParam($param);
		$param = new FieldExtString('production_vehicle_descr'
				,array(
			
				'alias'=>'ТС в Elkon'
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('dt_start_set'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('dt_end_set'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('production_site_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('shipment_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('concrete_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('vehicle_schedule_state_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('vehicle_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('production_concrete_type_descr'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('material_tolerance_violated'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Production_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Production_Model');

			
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
		
		$this->setListModelId('ProductionList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ProductionList_Model');		

			
		$pm = new PublicMethod('check_data');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('check_production');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('production_site_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('production_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_production_material_list');
		
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

		
	}	
	

	public function get_production_material_list($pm){
		$this->setListModelId('ProductionMaterialList_Model');
		parent::get_list($pm);
	}

/*

UPDATE public.production_sites
   SET elkon_connection='{"databaseName":"Santral","userName":"andreymikhalevich","userPassword":"wimaf2020ii42","host":"192.168.1.12","port":59900,"logLevel":9}'::JSONB
 WHERE id=2;

*/

	private static function get_con_id($prodSiteId){
		return 'srv_'.$prodSiteId;
	}
	
	private static function use_mssql_connect(){
		return function_exists('mssql_select_db');
	}

	private static function use_sqlsrv_connect(){
		return function_exists('sqlsrv_connect');
	}

	private function log_action($prodSiteId,$mes,$mesLevel,$servLevel){
		if($servLevel >= $mesLevel){

			$mes_db = NULL;		
			FieldSQLString::formatForDb($this->getDbLink(),$mes,$mes_db);
			
			 $this->getDbLinkMaster()->query(sprintf(
			 	"INSERT INTO elkon_log (production_site_id,level,message) VALUES
			 	(%d,%d,%s)",
			 	$prodSiteId,
			 	$mesLevel,
			 	$mes_db
			 ));
		}
	}

	/**
	 * Возвращает производства более или равное $productionId
	 * каждая строка- это новое начатое производство
	 * Uretim.Statu=1 - отмененное
	 * $sign = меньше / или равно
	 * т.е получает или слкдующее или равное по Ид
	 */
	private function elkon_get_productions($prodSiteId,$elkonCon,$productionId,$sign){
		$q  = sprintf(
			"SELECT
				Uretim.Id AS id,
				Uretim.BasTarih AS dt_start,
				Recete.ReceteAdi AS concrete_type_descr,
				Uretim.AracPlaka AS vehicle_descr,
				Uretim.Olusturan AS user_descr
			FROM Uretim
			LEFT JOIN Recete ON Recete.Id=Uretim.ReceteId
			WHERE Uretim.Id %s %d AND Uretim.BasTarih IS NOT NULL AND Uretim.BasTarih<>'' AND (Uretim.Statu=0 OR Uretim.Statu=2)
			ORDER BY Uretim.Id",
			$sign,
			$productionId
		);
		
		$productions = [];
		$con_id = self::get_con_id($prodSiteId);			
		$this->log_action(
			$prodSiteId,
			(($sign=='=')? 'Получение из elkon производства по идентификатору '.$productionId:'Получение из elkon следующего производства больше '.$productionId),
			self::LOG_LEVEL_DEBUG,
			$elkonCon->logLevel
		);		
		if(self::use_mssql_connect()){			
			try{
				$res = mssql_query($q, $this->mssqlConnections[$con_id]);
				while($row = mssql_fetch_assoc($res)){
					array_push($productions,$row);
				}
			}
			finally{
				mssql_free_result($res);
			}
		}
		else if(self::use_sqlsrv_connect()){
			try{
				$res = sqlsrv_query($this->mssqlConnections[$con_id], $q);
				if( $res === FALSE ) {
					throw new Exception(print_r(sqlsrv_errors()));	
				}
				while($row = sqlsrv_fetch_array($res,SQLSRV_FETCH_ASSOC)){
					array_push($productions,$row);
				}
			}
			finally{
				if($res!==FALSE){
					sqlsrv_free_stmt($res);
				}
			}
		
		}
		else{
			throw new Exception(self::ER_NO_MSSQL_DRIVER);
		}
		
		return $productions;
		
	}

	private function elkon_get_next_productions($prodSiteId,$elkonCon,$productionId){
		return $this->elkon_get_productions($prodSiteId,$elkonCon,$productionId,">");
	}
	private function elkon_get_production_by_id($prodSiteId,$elkonCon,$productionId){
		return $this->elkon_get_productions($prodSiteId,$elkonCon,$productionId,"=");
	}

	/**
	 * если производство с данным ID  закрыто - возвращает таблицу списанных материалов
	 * Всего с материалами 12 полей и 4 с цементом = 16 Это соответствует константе MT_FIELD_CNT
	 * Все поля: Agrega (Инертные) Su (Вода), Katki (Добавки), Cemento (Цемент) переходят в поля материалов
	 * нам пофиг у нас все материалы равнозачные
	 * и все приводим как в файле экспорта: Цемент1,Инертные1, Хим. добавки1, Вода1
	 * изначальная идея была использовать наименования Элкон, но чтобы был такой же механизм как
	 * при ручном импорте сделаем как в файле без
	 *	Mat1.MalzemeAdi AS mat1_descr
	 *	LEFT JOIN Malzeme AS Mat1 ON Mat1.Id=UretimSonuc.Agrega1MalzemeId
	 *
	 *	Uretim.Statu=1 - Это отмененные производства, их не учитываем!
	 */
	private function elkon_get_materials_on_closed_production($prodSiteId,$elkonCon,$productionId){
		$q  = sprintf(
			"WITH
			manual_correction AS (
				SELECT TOP 1
					*
				FROM ManuelKayit
				WHERE ManuelKayit.M_Tarih < (SELECT Uretim.BasTarih FROM Uretim WHERE Uretim.Id=%d)
				ORDER BY ManuelKayit.M_Tarih DESC
			)
			SELECT
				UretimSonuc.BitisTarihi AS production_dt_end,
				UretimSonuc.Miktar AS concrete_quant,
				Recete.ReceteAdi AS concrete_descr,
				Uretim.Olusturan AS user_descr,
				Uretim.AracPlaka AS vehicle_descr,
				(SELECT manual_correction.Id FROM manual_correction) AS correction_id,
				(SELECT manual_correction.M_Tarih FROM manual_correction) AS correction_dt_end,  
				
				'Инертные1' AS mat1_descr,
				UretimSonuc.Agrega1 AS mat1_quant,
				UretimSonuc.Agrega1Istenen AS mat1_quant_req,
				0 AS mat1_cement,
				(SELECT manual_correction.M_Agrega1 FROM manual_correction) AS mat1_quant_corrected,
				
				'Инертные2' AS mat2_descr,
				UretimSonuc.Agrega2 AS mat2_quant,
				UretimSonuc.Agrega2Istenen AS mat2_quant_req,
				0 AS mat2_cement,
				(SELECT manual_correction.M_Agrega2 FROM manual_correction) AS mat2_quant_corrected,
				
				'Инертные3' AS mat3_descr,
				UretimSonuc.Agrega3 AS mat3_quant,
				UretimSonuc.Agrega3Istenen AS mat3_quant_req,
				0 AS mat3_cement,
				(SELECT manual_correction.M_Agrega3 FROM manual_correction) AS mat3_quant_corrected,

				'Инертные4' AS mat4_descr,
				UretimSonuc.Agrega4 AS mat4_quant,
				UretimSonuc.Agrega4Istenen AS mat4_quant_req,
				0 AS mat4_cement,
				(SELECT manual_correction.M_Agrega4 FROM manual_correction) AS mat4_quant_corrected,

				'Инертные5' AS mat5_descr,
				UretimSonuc.Agrega5 AS mat5_quant,
				UretimSonuc.Agrega5Istenen AS mat5_quant_req,
				0 AS mat5_cement,
				(SELECT manual_correction.M_Agrega5 FROM manual_correction) AS mat5_quant_corrected,

				'Инертные6' AS mat6_descr,
				UretimSonuc.Agrega6 AS mat6_quant,
				UretimSonuc.Agrega6Istenen AS mat6_quant_req,
				0 AS mat6_cement,
				0 AS mat6_quant_corrected,
								
				'Хим. добавки1' AS mat7_descr,
				UretimSonuc.Katki1 AS mat7_quant,
				UretimSonuc.Katki1Istenen AS mat7_quant_req,
				0 AS mat7_cement,
				(SELECT manual_correction.M_Katki1 FROM manual_correction) AS mat7_quant_corrected,
				
				'Хим. добавки2' AS mat8_descr,
				UretimSonuc.Katki2 AS mat8_quant,
				UretimSonuc.Katki2Istenen AS mat8_quant_req,
				0 AS mat8_cement,
				(SELECT manual_correction.M_Katki2 FROM manual_correction) AS mat8_quant_corrected,
				
				'Хим. добавки3' AS mat9_descr,
				UretimSonuc.Katki3 AS mat9_quant,
				UretimSonuc.Katki3Istenen AS mat9_quant_req,
				0 AS mat9_cement,
				(SELECT manual_correction.M_Katki3 FROM manual_correction) AS mat9_quant_corrected,

				'Хим. добавки4' AS mat10_descr,
				UretimSonuc.Katki4 AS mat10_quant,
				UretimSonuc.Katki4Istenen AS mat10_quant_req,
				0 AS mat10_cement,
				(SELECT manual_correction.M_Katki4 FROM manual_correction) AS mat10_quant_corrected,

				'Вода1' AS mat11_descr,
				UretimSonuc.Su1 AS mat11_quant,
				UretimSonuc.Su1Istenen AS mat11_quant_req,
				0 AS mat11_cement,
				(SELECT manual_correction.M_Su1 FROM manual_correction) AS mat11_quant_corrected,

				'Вода2' AS mat12_descr,
				UretimSonuc.Su2 AS mat12_quant,
				UretimSonuc.Su2Istenen AS mat12_quant_req,
				0 AS mat12_cement,
				(SELECT manual_correction.M_Su2 FROM manual_correction) AS mat12_quant_corrected,
				
				'Цемент1' AS mat13_descr,
				UretimSonuc.Cimento1 AS mat13_quant,
				UretimSonuc.Cimento1Istenen AS mat13_quant_req,
				1 AS mat13_cement,
				(SELECT manual_correction.M_Cimento1 FROM manual_correction) AS mat13_quant_corrected,

				'Цемент2' AS mat14_descr,
				UretimSonuc.Cimento2 AS mat14_quant,
				UretimSonuc.Cimento2Istenen AS mat14_quant_req,
				1 AS mat14_cement,
				(SELECT manual_correction.M_Cimento2 FROM manual_correction) AS mat14_quant_corrected,
				
				'Цемент3' AS mat15_descr,
				UretimSonuc.Cimento3 AS mat15_quant,
				UretimSonuc.Cimento3Istenen AS mat15_quant_req,
				1 AS mat15_cement,
				(SELECT manual_correction.M_Cimento3 FROM manual_correction) AS mat15_quant_corrected,

				'Цемент4' AS mat16_descr,
				UretimSonuc.Cimento4 AS mat16_quant,
				UretimSonuc.Cimento4Istenen AS mat16_quant_req,
				1 AS mat16_cement,
				(SELECT manual_correction.M_Cimento4 FROM manual_correction) AS mat16_quant_corrected
				
			FROM Uretim
			LEFT JOIN UretimSonuc ON UretimSonuc.UretimId=Uretim.id
			LEFT JOIN Recete ON Recete.Id=Uretim.ReceteId
			
			WHERE Uretim.Id=%d AND UretimSonuc.BitisTarihi IS NOT NULL",
			$productionId,
			$productionId
		);
		
		$con_id = self::get_con_id($prodSiteId);			
		$this->log_action($prodSiteId,'Получение из elkon списанных материалов по закрытому производству '.$productionId,self::LOG_LEVEL_DEBUG,$elkonCon->logLevel);
		
		if(self::use_mssql_connect()){			
			try{
				$res = mssql_query($q, $this->mssqlConnections[$con_id]);
				$row = mssql_fetch_assoc($res);
			}
			finally{
				mssql_free_result($res);
			}
		}
		else if(self::use_sqlsrv_connect()){
			try{
				$res = sqlsrv_query($this->mssqlConnections[$con_id], $q);
				if($res === FALSE ) {
					throw new Exception(print_r(sqlsrv_errors()));	
				}
				$row = sqlsrv_fetch_array($res,SQLSRV_FETCH_ASSOC);
			}
			finally{
				if($res!==FALSE){
					sqlsrv_free_stmt($res);
				}
			}
		}
		else{
			throw new Exception(self::ER_NO_MSSQL_DRIVER);
		}
		
		return $row;
	}

	/**
	 * Обязательно исправить файл /etc/freetds/freetds.conf
	 * в секции global добавить
	 * 	tds version = 7.0
         *	client charset = UTF8
	 * И ВСЕ!!! больше никаких настроек при подключении mssql_connect()
	 */	
	private function connect_to_elkon_server($prodSiteId,$elkonCon){
		//substr(phpversion(),0,1)
		$con_id = self::get_con_id($prodSiteId);		
		
		if(self::use_mssql_connect()){		
			$server_name = sprintf('%s:%d',$elkonCon->host,$elkonCon->port);
			
			if((is_null($this->mssqlConnections) || !isset($this->mssqlConnections[$con_id]))){
				$this->log_action($prodSiteId,'Соединение mssql_connect с сервером '.$server_name,self::LOG_LEVEL_DEBUG,$elkonCon->logLevel);
			
				$this->mssqlConnections[$con_id] = @mssql_connect($server_name, $elkonCon->userName, $elkonCon->userPassword);
				if($this->mssqlConnections[$con_id]===FALSE){
					throw new Exception('Ошибка соединения с сервером '.$server_name);
				}
				mssql_select_db($elkonCon->databaseName, $this->mssqlConnections[$con_id]);
			}
			else{
				$this->log_action($prodSiteId,'Используется открытое соединение с сервером '.$server_name,self::LOG_LEVEL_DEBUG,$elkonCon->logLevel);
			}
		}
		else if(self::use_sqlsrv_connect()){
			$server_name = sprintf('%s, %d',$elkonCon->host,$elkonCon->port);
			
			if((is_null($this->mssqlConnections) || !isset($this->mssqlConnections[$con_id]))){
				$this->log_action($prodSiteId,'Соединение sqlsrv_connect с сервером '.$server_name,self::LOG_LEVEL_DEBUG,$elkonCon->logLevel);
				$con_info = array(
					'Database'=>$elkonCon->databaseName
					,'UID'=>$elkonCon->userName
					,'PWD'=>$elkonCon->userPassword
					//,'CharacterSet' => 'UTF-8'
				);
				$this->mssqlConnections[$con_id] = @sqlsrv_connect($server_name, $con_info);
			}
			else{
				$this->log_action($prodSiteId,'Используется открытое соединение с сервером '.$server_name,self::LOG_LEVEL_DEBUG,$elkonCon->logLevel);
			}			
		}
		else{
			throw new Exception(self::ER_NO_MSSQL_DRIVER);
		}	
	}

	private function insert_elkon_productions($productionSiteId,&$productionsData,$elkonLogLevel,$updateLastProduction){
		$q_head = "INSERT INTO productions (
			production_id,
			production_dt_start,
			production_user,
			production_vehicle_descr,
			production_site_id,
			concrete_type_id,
			production_concrete_type_descr				
		) VALUES ";												
		$q_body = '';				
		
		$max_production_id = 0;
		foreach($productionsData as $production_data){
		
			$id_db = 0;
			FieldSQLInt::formatForDb($production_data['id'],$id_db);

			$dt_start = strtotime($production_data['dt_start']);
			if($dt_start===FALSE || $dt_start===-1){
				//throw new Exception('Ошибка преобразования даты начала производства:"'.$production_data['dt_start'].'", Производство элкон:'.$production_data['id']);
				$this->log_action($productionSiteId,'Ошибка преобразования даты начала производства:"'.$production_data['dt_start'].'"',self::LOG_LEVEL_ERROR,$elkonLogLevel);
				continue;
			}
			$dt_start_db = '';
			FieldSQLDateTime::formatForDb($dt_start,$dt_start_db);

			$user_db = '';
			FieldSQLString::formatForDb($this->getDbLink(),$production_data['user_descr'],$user_db);

			$vehicle_descr_db = '';
			FieldSQLString::formatForDb($this->getDbLink(),$production_data['vehicle_descr'],$vehicle_descr_db);

			$concrete_type_descr_db = '';
			FieldSQLString::formatForDb($this->getDbLink(),$production_data['concrete_type_descr'],$concrete_type_descr_db);
		
			//******* Марка бетона идентификатор **********
			$concrete_type_id = 'NULL';
			if(!isset($concrete_types[$production_data['concrete_type_descr']])){
				$ar = $this->getDbLink()->query_first(sprintf("SELECT material_fact_consumptions_add_concrete_type(%s) AS concrete_type_id",$concrete_type_descr_db));
				$concrete_type_id = is_null($ar['concrete_type_id'])? 'NULL':$ar['concrete_type_id'];
				$concrete_types[$production_data['concrete_type_descr']] = $concrete_type_id;
			}
			else{
				$concrete_type_id = $concrete_types[$production_data['concrete_type_descr']];
			}
		
			$q_body.= ($q_body=='')? '':',';
			$q_body.=sprintf(
				"(%d,
				%s,
				%s,
				%s,
				%d,
				%s,%s)",
				$id_db,
				$dt_start_db,
				$user_db,
				$vehicle_descr_db,
				$productionSiteId,
				$concrete_type_id,
				$concrete_type_descr_db
			);
			
			if($max_production_id < $id_db){
				$max_production_id = $id_db;
			}
		}
		if(strlen($q_body)){
			try{
				$this->log_action($productionSiteId,'Выполнение запроса по вставке нового производства: '.$q_head.' '.$q_body,self::LOG_LEVEL_DEBUG,$elkonLogLevel);	
				
				$this->getDbLinkMaster()->query('BEGIN');						
				$this->getDbLinkMaster()->query($q_head.' '.$q_body);

				if($updateLastProduction){			
					$this->getDbLinkMaster()->query(sprintf(
						'UPDATE production_sites
						SET last_elkon_production_id=%d
						WHERE id=%d',
						$max_production_id,
						$productionSiteId
					));
				}
				$this->getDbLinkMaster()->query('COMMIT');
			}
			catch(Exception $e){
				$this->getDbLinkMaster()->query('ROLLBACK');
				
				throw $e;
			}
		}
	
	
	}
	
	public function check_production($pm){
		//Получение производства по иду
		$production_site_id = $this->getExtDbVal($pm,'production_site_id');
		$elkon_con = NULL;
		$q_id = $this->getDbLink()->query("SELECT * FROM production_sites_last_production_list");
		while($serv = $this->getDbLink()->fetch_array($q_id)){
			if($production_site_id == $serv['id']){
				$elkon_con = json_decode($serv['elkon_connection']);
				try{
					$this->connect_to_elkon_server($serv['id'],$elkon_con);
				}
				catch(Exception $e){
					$this->log_action($serv['id'],'Ошибка: '.$e->getMessage(),self::LOG_LEVEL_ERROR,$elkon_con->logLevel);
				}
				
				break;
			}
		}
		if(!$elkon_con){
			throw new Exception('Не найдено соединение для завода с Ид='.$production_site_id);
		}
		
		try{
			$productions_data = $this->elkon_get_production_by_id($production_site_id, $elkon_con,$this->getExtDbVal($pm,'production_id'));
			$this->insert_elkon_productions($production_site_id,$productions_data,$elkon_con->logLevel,FALSE);
		}
		catch(Exception $e){
			$this->log_action($production_site_id,'Ошибка: '.$e->getMessage(),self::LOG_LEVEL_ERROR,$elkon_con->logLevel);
			
			throw $e;
		}			
	}
	
	public function check_data($pm){
		
		$res = TRUE;//false if error
		$err_str = NULL;

		$DEF_OPERATOR_USER_ID = 1; 

		//Количестиво полей с материалами: Agrega (Инертные) Su (Вода), Katki (Добавки), Cemento (Цемент)
		$MT_FIELD_CNT = 16;
	
		/** Решаем следующие задачи:
		 * 1) Проверить по нашей базе есть ли незавершенное производство,
		 * 	если есть - проверить ее статус в ELKON и если завершилась - тоже завершить
		 * 2) проверить есть ли в ELKON новое производство (т.е. с ID больше нашего последнего)
		 *	если есть - занести к нам в базу, отметить 
		 */
		$silo_ids = [];
		$concrete_types = [];
		$materials = [];
		$concrete_type_descrs = [];
		$material_descrs = [];
		$veh_descrs = [];
		$productions_for_close = [];		
		
		$q_id = $this->getDbLink()->query("SELECT * FROM production_sites_last_production_list");
		while($serv = $this->getDbLink()->fetch_array($q_id)){
		
			$elkon_con = json_decode($serv['elkon_connection']);
		
			$this->log_action($serv['id'],'Проверка данных завод: '.$serv['name'],self::LOG_LEVEL_NOTE,$elkon_con->logLevel);
		
			try{
				$this->connect_to_elkon_server($serv['id'],$elkon_con);
			}
			catch(Exception $e){
				$this->log_action($serv['id'],'Ошибка: '.$e->getMessage(),self::LOG_LEVEL_ERROR,$elkon_con->logLevel);
				continue;
			}
		
			try{
				$this->connect_to_elkon_server($serv['id'],$elkon_con);
				$max_production_id = isset($serv['last_production_id'])? intval($serv['last_production_id']):0;
				if(isset($serv['production_ids']) && strlen($serv['production_ids'])){
					$production_ids_s = substr($serv['production_ids'],1,strlen($serv['production_ids'])-2);
					$production_ids = explode(',',$production_ids_s);
					foreach($production_ids as $production_id){
						//Незакрытое производство
						if($max_production_id < $production_id){
							$max_production_id = $production_id;
						}
						
						$material_data = $this->elkon_get_materials_on_closed_production($serv['id'],$elkon_con,$production_id);
						if(is_array($material_data) && count($material_data)){
							$this->log_action($serv['id'],'Закрываем производство: '.$production_id,self::LOG_LEVEL_DEBUG,$elkon_con->logLevel);	
						
							$production_dt_end = strtotime($material_data['production_dt_end']);
							if($production_dt_end===FALSE || $production_dt_end===-1){
								$this->log_action($serv['id'],'Ошибка преобразования даты окончания производства:"'.$material_data['production_dt_end'].'", Производство элкон:'.$production_data['id'],self::LOG_LEVEL_ERROR,$elkon_con->logLevel);	
								continue;
							}
							$production_dt_end_db = NULL;		
							FieldSQLDateTime::formatForDb($production_dt_end,$production_dt_end_db);
						
							$this->log_action($serv['id'],'Собираем запрос по списанию материалов',self::LOG_LEVEL_DEBUG,$elkon_con->logLevel);	
												
							$q_head = "INSERT INTO material_fact_consumptions
								(production_site_id,
								upload_date_time,
								upload_user_id,
								date_time,
								concrete_type_production_descr,
								concrete_type_id,
								raw_material_production_descr,
								raw_material_id,
								vehicle_production_descr,
								vehicle_id,
								vehicle_schedule_state_id,
								concrete_quant,
								material_quant,
								material_quant_req,
								cement_silo_id,
								production_id) VALUES ";

							$q_head_cor = "INSERT INTO material_fact_consumption_corrections
								(production_site_id,
							        date_time,
							        user_id,
							        material_id, 
								cement_silo_id,
								production_id,
								elkon_id,
								quant) VALUES ";
						
							$q_body = '';
							$q_body_cor = '';
							$vehicle_id = NULL;
							$shipment_id = NULL;
							$operator_user_id = $DEF_OPERATOR_USER_ID;
							//$vehicle_descr = NULL;
							$veh_sched_on_production_id = NULL;
							$vehicle_schedule_state_id = NULL;
							$concrete_type_id = NULL;
						
							//По каждому материалу
							for($m_ind=1;$m_ind<=$MT_FIELD_CNT;$m_ind++){
								$m_id_pref = 'mat'.$m_ind;
								if(
								 (isset($material_data[$m_id_pref.'_quant']) && ($qt=intval($material_data[$m_id_pref.'_quant'])) )
								 ||
								 (isset($material_data[$m_id_pref.'_quant_req']) && ($qt=intval($material_data[$m_id_pref.'_quant_req'])) )
								){

									//******* Силос (только у цемента!) **********
									$silo_id = 'NULL';
									if($material_data[$m_id_pref.'_cement']=='1'){
										$silo_key = $serv['id'].$material_data[$m_id_pref.'_descr'];
										if(!isset($silo_ids[$silo_key])){
											$ar = $this->getDbLink()->query_first(sprintf(
												"SELECT id FROM cement_silos
												WHERE production_site_id=%d AND production_descr='%s'",
												$serv['id'],
												$material_data[$m_id_pref.'_descr']
											));
											$silo_id = is_null($ar['id'])? 'NULL':$ar['id'];
											$silo_ids[$silo_key] = $silo_id;
										}
										else{
											$silo_id = $silo_ids[$silo_key];
										}
									}
								
									//******* Марка бетона представление **********
									$concrete_type_descr = $material_data['concrete_descr'];
									$concrete_type_descr_db = NULL;		
									if(!isset($concrete_type_descrs[$concrete_type_descr])){
										FieldSQLString::formatForDb($this->getDbLink(),$concrete_type_descr,$concrete_type_descr_db);
										$concrete_type_descrs[$concrete_type_descr] = $concrete_type_descr_db; 
									}
									else{
										$concrete_type_descr_db = $concrete_type_descrs[$concrete_type_descr];
									}
																
									//******* Материал представление **********
									$mat_descr = $material_data[$m_id_pref.'_descr'];
									$mat_descr_db = NULL;		
									if(!isset($material_descrs[$mat_descr])){
										FieldSQLString::formatForDb($this->getDbLink(),$mat_descr,$mat_descr_db);
									}
								
									//******* Материал идентификатор **********
									$mat_id = 'NULL';
									if(!isset($materials[$mat_descr])){
										$ar = $this->getDbLink()->query_first(sprintf(
											"SELECT material_fact_consumptions_add_material(%d,%s,%s) AS material_id",
											$serv['id'],
											$mat_descr_db,
											$production_dt_end_db
										));
										$mat_id = is_null($ar['material_id'])? 'NULL':$ar['material_id'];
										$materials[$mat_descr] = $mat_id;
									}
									else{
										$mat_id = $materials[$mat_descr];
									}
								
									//******* ТС представление **********
									$veh_descr = $material_data['vehicle_descr'];
									$veh_descr_db = NULL;		
									if(!isset($veh_descrs[$veh_descr])){
										FieldSQLString::formatForDb($this->getDbLink(),$veh_descr,$veh_descr_db);
										$veh_descrs[$veh_descr] = $veh_descr_db;
									}
									else{
										$veh_descr_db = $veh_descrs[$veh_descr];
									}
								
									//******* ТС,отгрузка,марка бетона идентификаторы **********
									if(is_null($vehicle_id)){
										$ar = $this->getDbLink()->query_first(sprintf(
											"SELECT											
												p.vehicle_id,
												p.production_vehicle_descr AS vehicle_descr,
												p.vehicle_schedule_state_id,
												p.concrete_type_id,
												p.shipment_id,
												(SELECT
													u_map.user_id
												FROM user_map_to_production AS u_map
												WHERE
													u_map.production_site_id=p.production_site_id
													AND u_map.production_descr=p.production_user
												) AS operator_user_id
											FROM productions AS p
											WHERE p.production_site_id=%d AND p.production_id=%d
											",
											$serv['id'],
											$production_id
										));
										if(is_array($ar) && count($ar) ){
											$vehicle_id = isset($ar['vehicle_id'])? $ar['vehicle_id']:'NULL';
											$shipment_id =  isset($ar['shipment_id'])? $ar['shipment_id']:'NULL';
											$operator_user_id = isset($ar['operator_user_id'])? intval($ar['operator_user_id']):0;
											if(!$operator_user_id){
												$operator_user_id = $DEF_OPERATOR_USER_ID;
											}
											$vehicle_schedule_state_id = isset($ar['vehicle_schedule_state_id'])? $ar['vehicle_schedule_state_id']:'NULL';
											$concrete_type_id = isset($ar['concrete_type_id'])? $ar['concrete_type_id']:'NULL';
										}
										else{
											//нет данного производства в таблице productions
											$vehicle_id = 'NULL';
											$shipment_id = 'NULL';
											$operator_user_id = $DEF_OPERATOR_USER_ID;
											$vehicle_schedule_state_id = 'NULL';
											$concrete_type_id = 'NULL';
										}
									}
								
									//вставка только если есть в производстве (таблица productions)
									if(
									$vehicle_id!='NULL'
									||$vehicle_schedule_state_id!='NULL'
									||$concrete_type_id!='NULL'
									){
										/*
										production_site_id,
										upload_date_time,
										upload_user_id,
										date_time,
										concrete_type_production_descr,
										concrete_type_id,
										raw_material_production_descr,
										raw_material_id,
										vehicle_production_descr,
										vehicle_id,
										vehicle_schedule_state_id,
										concrete_quant,
										material_quant,
										material_quant_req,
										silo_id,
										production_id
										*/
										$q_body.= ($q_body=='')? '':',';
										$q_body.= sprintf(
											"(%d,
											now(),
											%d,
											%s,
											%s,
											%s,
											%s,
											%s,
											%s,
											%s,
											%s,
											%f,
											%f,
											%f,
											%s,
											%d)",
										$serv['id'],
										$operator_user_id,
										$production_dt_end_db,
										$concrete_type_descr_db,
										$concrete_type_id,
										$mat_descr_db,
										$mat_id,
										$veh_descr_db,
										$vehicle_id,
										$vehicle_schedule_state_id,
										floatval($material_data['concrete_quant']),
										floatval($material_data[$m_id_pref.'_quant'])/1000,
										floatval($material_data[$m_id_pref.'_quant_req'])/1000,
										$silo_id,
										$production_id
										);
										
										//correction
										$q_cor = floatval($material_data[$m_id_pref.'_quant_corrected']);
										if($q_cor && $mat_id!='NULL'){
											/*
											production_site_id,
											date_time,
											user_id,
											material_id, 
											cement_silo_id,
											production_id,
											elkon_id,
											quant
											*/
											$q_body_cor.= ($q_body_cor=='')? '':',';
											$q_body_cor.= sprintf(
												"(%d,
												'%s',
												%d,
												%d,
												%s,
												%d,
												%d,
												%f
												)",
												$serv['id'],
												date('Y-m-d H:i:s',strtotime($material_data['correction_dt_end'])),
												$operator_user_id,
												$mat_id,
												$silo_id,
												$production_id,
												$material_data['correction_id'],
												$q_cor/1000
											);
										}
										if($shipment_id != 'NULL'
										&& !array_key_exists('id_'.$production_id,$productions_for_close)
										){
											$productions_for_close['id_'.$production_id] = array(
												'production_id'=>$production_id,
												'shipment_id'=>$shipment_id,
												'operator_user_id'=>$operator_user_id
											);
										}
									}
									else{
										//тут запишем отладочную инфу, что нет производства такого
										$this->log_action($serv['id'],'Нет в таблице productions производства с ИД elkon '.$production_id,self::LOG_LEVEL_DEBUG,$elkon_con->logLevel);
									}															
								}
							}
						
							//Запись данных
							if(strlen($q_body)){							
								try{												
									$this->log_action($serv['id'],'Выполнение запроса по списанию материалов: '.$q_head.' '.$q_body,self::LOG_LEVEL_DEBUG,$elkon_con->logLevel);	
								
									$this->getDbLinkMaster()->query('BEGIN');
									
									$this->getDbLinkMaster()->query(sprintf(
										'DELETE FROM material_fact_consumptions
										WHERE production_site_id=%d AND production_id=%d',
										$serv['id'],
										$production_id
									));
									$this->getDbLinkMaster()->query($q_head.' '.$q_body);
								
									if(strlen($q_body_cor)){
										$cor_exists = $this->getDbLinkMaster()->query_first(sprintf(
											"SELECT TRUE AS cor_exists
											FROM material_fact_consumption_corrections
											WHERE production_site_id=%d AND elkon_id=%d",
											$serv['id'],$material_data['correction_id']
										));
										//correction
										if(!count($cor_exists)||!isset($cor_exists['cor_exists'])||$cor_exists['cor_exists']!='t'){
											$this->getDbLinkMaster()->query($q_head_cor.' '.$q_body_cor);
										}
									}
								
									//Закрытие производства
									$this->getDbLinkMaster()->query(sprintf(
										"UPDATE productions
										SET
											production_dt_end = %s,
											dt_end_set = now()
										WHERE production_id=%d AND production_site_id=%d",
										$production_dt_end_db,
										$production_id,
										$serv['id']
									));
								
									//А если еще не отгружено - отгрузим от имени оператора!
									//ВРЕМЕННО ОТКЛЮЧЕНО!!!
									$sms_res_ok = 0;
									$sms_res_str = '';
									/*
									foreach($productions_for_close as $production_for_close){
										$ar = $this->getDbLinkMaster()->query_first(sprintf(
											"SELECT
												coalesce(shipped,FALSE) AS shipped
											FROM shipments
											WHERE id=%d",
											$production_for_close['shipment_id']
										));
										if(is_array($ar) && count($ar) && $ar['shipped']=='f'){
											Shipment_Controller::setShipped(
												$this->getDbLinkMaster(),
												$this->getDbLink(),
												$production_for_close['shipment_id'],
												$production_for_close['operator_user_id'],
												$sms_res_ok,
												$sms_res_str,
												FALSE
											);
										}
									}
									*/
									$this->getDbLinkMaster()->query('COMMIT');
								}
								catch(Exception $e){
									$this->getDbLinkMaster()->query('ROLLBACK');
									throw $e;
								}
							}
						}					
					}
				}
				
				if(!$max_production_id){
					continue;
				}
				
				//Получение новых производств
				$productions_data = $this->elkon_get_next_productions($serv['id'],$elkon_con,$max_production_id);
				$this->insert_elkon_productions($serv['id'],$productions_data,$elkon_con->logLevel,TRUE);
				/*
				$q_head = "INSERT INTO productions (
					production_id,
					production_dt_start,
					production_user,
					production_vehicle_descr,
					production_site_id,
					concrete_type_id,
					production_concrete_type_descr				
				) VALUES ";												
				$q_body = '';				
				
				$max_production_id = 0;
				foreach($productions_data as $production_data){
				
					$id_db = 0;
					FieldSQLInt::formatForDb($production_data['id'],$id_db);

					$dt_start = strtotime($production_data['dt_start']);
					if($dt_start===FALSE || $dt_start===-1){
						//throw new Exception('Ошибка преобразования даты начала производства:"'.$production_data['dt_start'].'", Производство элкон:'.$production_data['id']);
						$this->log_action($serv['id'],'Ошибка преобразования даты начала производства:"'.$production_data['dt_start'].'"',self::LOG_LEVEL_ERROR,$elkon_con->logLevel);
						continue;
					}
					$dt_start_db = '';
					FieldSQLDateTime::formatForDb($dt_start,$dt_start_db);

					$user_db = '';
					FieldSQLString::formatForDb($this->getDbLink(),$production_data['user_descr'],$user_db);

					$vehicle_descr_db = '';
					FieldSQLString::formatForDb($this->getDbLink(),$production_data['vehicle_descr'],$vehicle_descr_db);

					$concrete_type_descr_db = '';
					FieldSQLString::formatForDb($this->getDbLink(),$production_data['concrete_type_descr'],$concrete_type_descr_db);
				
					//******* Марка бетона идентификатор **********
					$concrete_type_id = 'NULL';
					if(!isset($concrete_types[$production_data['concrete_type_descr']])){
						$ar = $this->getDbLink()->query_first(sprintf("SELECT material_fact_consumptions_add_concrete_type(%s) AS concrete_type_id",$concrete_type_descr_db));
						$concrete_type_id = is_null($ar['concrete_type_id'])? 'NULL':$ar['concrete_type_id'];
						$concrete_types[$production_data['concrete_type_descr']] = $concrete_type_id;
					}
					else{
						$concrete_type_id = $concrete_types[$production_data['concrete_type_descr']];
					}
				
					$q_body.= ($q_body=='')? '':',';
					$q_body.=sprintf(
						"(%d,
						%s,
						%s,
						%s,
						%d,
						%s,%s)",
						$id_db,
						$dt_start_db,
						$user_db,
						$vehicle_descr_db,
						$serv['id'],
						$concrete_type_id,
						$concrete_type_descr_db
					);
					
					if($max_production_id < $id_db){
						$max_production_id = $id_db;
					}
				}
				if(strlen($q_body)){
					try{
						$this->log_action($serv['id'],'Выполнение запроса по вставке нового производства: '.$q_head.' '.$q_body,self::LOG_LEVEL_DEBUG,$elkon_con->logLevel);	
						
						$this->getDbLinkMaster()->query('BEGIN');						
						$this->getDbLinkMaster()->query($q_head.' '.$q_body);
					
						$this->getDbLinkMaster()->query(sprintf(
							'UPDATE production_sites
							SET last_elkon_production_id=%d
							WHERE id=%d',
							$max_production_id,
							$serv['id']
						));
						$this->getDbLinkMaster()->query('COMMIT');
						
					}
					catch(Exception $e){
						$this->getDbLinkMaster()->query('ROLLBACK');
						
						throw $e;
					}
				}
				*/
				
			}
			catch(Exception $e){
				$this->log_action($serv['id'],'Ошибка: '.$e->getMessage(),self::LOG_LEVEL_ERROR,$elkon_con->logLevel);
				
				throw $e;
			}
		}
	}


}
?>