<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Order'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>

<xsl:call-template name="add_requirements"/>

require_once(USER_CONTROLLERS_PATH.'Graph_Controller.php');
require_once(USER_CONTROLLERS_PATH.'RawMaterial_Controller.php');
require_once(USER_CONTROLLERS_PATH.'VehicleSchedule_Controller.php');
require_once(USER_CONTROLLERS_PATH.'Shipment_Controller.php');
require_once(USER_CONTROLLERS_PATH.'Weather_Controller.php');

require_once(USER_MODELS_PATH.'OrderMakeList_Model.php');
require_once(USER_MODELS_PATH.'ConcreteType_Model.php');
require_once(USER_MODELS_PATH.'Lang_Model.php');

require_once('common/SMSService.php');
require_once('common/MyDate.php');

require_once(ABSOLUTE_PATH.'functions/Beton.php');

class <xsl:value-of select="@id"/>_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	
	public function send_messages($id,$phone_cel,$quant,$total,
		$date_time,$concrete_type_id,$destination_id,
		$lang_id, $pumpVehicleId, $order_update,$pumpInsert){
		//SMS service		
		if (SMS_ACTIVE&amp;&amp;(strlen($phone_cel)||$pumpVehicleId!='null')){
			$dbLink = $this->getDbLink();
			$dbLinkMaster = $this->getDbLinkMaster();
			
			$sms_service = NULL;
			
			if (strlen($phone_cel)){
				//date + rout time
				$date_time_str = NULL;
				FieldSQLDateTime::formatForDb($date_time,$date_time_str);
				$ar = $dbLink->query_first(sprintf(
				"SELECT %s::timestamp + coalesce(time_route,'00:00'::time) AS date_time
				FROM destinations WHERE id=%d",
				$date_time_str,$destination_id)
				);
				if ($ar){
					$date_time = strtotime($ar['date_time']);
				}
				$lang_id = intval($lang_id);
				$lang_id = ($lang_id==0)? 1:$lang_id;
				$ar = $dbLink->query_first(sprintf(
				"SELECT pattern AS text
				FROM sms_patterns
				WHERE sms_type='order'::sms_types AND lang_id=%d",
				$lang_id));
				if (!is_array($ar) || count($ar)==0){
					throw new Exception('Шаблон для SMS не найден!');
				}
				$text = str_replace('[quant]',$quant,$ar['text']);
				$total_repl= ($total)? ' стоимость:'.$total:'';
				$text = str_replace('[total]',$total_repl,$text);
				$text = str_replace('[time]',date('H:i',$date_time),$text);
				$text = str_replace('[date]',date('d/m/y',$date_time),$text);
				$text = str_replace('[day_of_week]',MyDate::getRusDayOfWeek($date_time),$text);
				
				$is_dest = (strpos($text,'[dest]')&gt;=0);
				$is_concr = (strpos($text,'[concrete]')&gt;=0);
				if ($is_dest || $is_concr){
					$q = 'SELECT ';
					if ($is_dest){
						$q.='(SELECT name FROM destinations WHERE id='.$destination_id.') AS dest';
					}
					if ($is_concr){
						if ($is_dest){
							$q.=',';
						}
						$q.='(SELECT name FROM concrete_types WHERE id='.$concrete_type_id.') AS concrete';
					}
					$ar = $dbLink->query_first($q);
					foreach($ar as $key=>$val){
						$text = str_replace(sprintf('[%s]',$key),$val,$text);
					}
				}
			}
			//throw new Exception($text);
			try{
				$sms_id = NULL;
				$sms_id_pump = NULL;
				
				if (strlen($phone_cel)){
					$sms_service = new SMSService(SMS_LOGIN, SMS_PWD);
					$sms_id_resp = $sms_service->send($phone_cel,$text,SMS_SIGN,SMS_TEST);				
					FieldSQLString::formatForDb($this->getDbLink(),$sms_id_resp,$sms_id);								
				}
				
				//насоснику
				if ($pumpVehicleId!='null'){
					$pump_sms_ar = $this->getDbLink()->query_first(sprintf(
					"SELECT * FROM %s
					WHERE order_id=%d",
					($pumpInsert)? 'sms_pump_order_ins':'sms_pump_order_upd', 
					$id
					));
					if (is_array($pump_sms_ar)&amp;&amp;count($pump_sms_ar)){
						if (is_null($sms_service)){
							$sms_service = new SMSService(SMS_LOGIN, SMS_PWD);
						}					
						$sms_id_resp_pump = $sms_service->send($pump_sms_ar['phone_cel'],$pump_sms_ar['message'],SMS_SIGN,SMS_TEST);
						FieldSQLString::formatForDb($this->getDbLink(),$sms_id_resp_pump,$sms_id_pump);									
						
						//ответственному
						$tel_id = $this->pumpActionRespTels( ( ($pumpInsert)? 'order_for_pump_ins':'order_for_pump_upd') );
						while($tel = $this->getDbLink()->fetch_array($tel_id)){
							$sms_service->send($tel['phone_cel'],$pump_sms_ar['message'],SMS_SIGN,SMS_TEST);
						}															
					}
				}
				
				$q = '';
				
				if ($order_update&amp;&amp;(!is_null($sms_id)||!is_null($sms_id_pump))){
					$q = sprintf("UPDATE sms_service
					SET
						sms_id_order = %s,
						order_sms_time=%s,
						sms_id_pump = %s,
						pump_sms_time=%s						
					WHERE order_id=%d",
					(is_null($sms_id))? 'NULL':$sms_id,(is_null($sms_id))? 'NULL':"'".date('Y-m-d H:i:s')."'",
					(is_null($sms_id_pump))? 'NULL':$sms_id_pump,(is_null($sms_id_pump))? 'NULL':"'".date('Y-m-d H:i:s')."'",
					$id);
				}
				else if (!$order_update&amp;&amp;(!is_null($sms_id)||!is_null($sms_id_pump))){
					$q = sprintf("INSERT INTO sms_service
					(order_id,shipment_id,
					sms_id_order,order_sms_time,
					sms_id_pump,pump_sms_time)
					VALUES (%d,0,%s,%s,%s,%s)",
					$id,
					(is_null($sms_id))? 'NULL':$sms_id,(is_null($sms_id))? 'NULL':"'".date('Y-m-d H:i:s')."'",
					(is_null($sms_id_pump))? 'NULL':$sms_id_pump,(is_null($sms_id_pump))? 'NULL':"'".date('Y-m-d H:i:s')."'"
					);
				}
				
				if (!is_null($sms_id)||!is_null($sms_id_pump)){
					$dbLinkMaster->query($q);
				}
				$sms_res_str = '';
				$sms_res_ok = 1;
			}
			catch (Exception $e){
				$sms_res_str = $e->getMessage();
				$sms_res_ok = 0;
			}
		}
		else{
			$sms_res_str = 'Сервис SMS выключен.';
			$sms_res_ok = 0;
		}
		
		$this->addModel(new ModelVars(
			array('id'=>'SMSSend',
				'values'=>array(
					new Field('sent',DT_INT,
						array('value'=>$sms_res_ok))
					,					
					new Field('resp',DT_STRING,
						array('value'=>$sms_res_str))
					)
				)
			)
		);		
	}
	
	public function insert($pm){
	
		if($_SESSION['role_id']!='owner'||!$pm->getParamValue('user_id')){
			$pm->setParamValue('user_id',$_SESSION['user_id']);
		}
	
		Graph_Controller::clearCacheOnDate($this->getDbLink(),$pm->getParamValue("date_time"));
		
		
		$pm->addParam(new FieldExtInt('ret_id',array('value'=>1)));
		$id_ar = parent::insert($pm);

		$this->send_messages(
			$id_ar['id'],
			$pm->getParamValue('phone_cel'),
			$pm->getParamValue('quant'),
			($pm->getParamValue('pay_cash')=='true')?
				$pm->getParamValue('total'):0,
			$pm->getParamValue('date_time'),
			$pm->getParamValue('concrete_type_id'),
			$pm->getParamValue('destination_id'),
			$pm->getParamValue('lang_id'),
			$pm->getParamValue("pump_vehicle_id"),
			FALSE,
			TRUE
		);

	}
	
	public function update($pm){
	
		$pm->setParamValue('last_modif_user_id',$_SESSION['user_id']);
	
		$dbLink = $this->getDbLink();
		$ar = $dbLink->query_first(sprintf(
			"SELECT
				o.date_time,
				o.quant,
				o.pay_cash,
				CASE WHEN o.pay_cash THEN o.total ELSE 0 END AS total,
				o.unload_speed,
				o.phone_cel,
				o.concrete_type_id,
				o.destination_id,
				o.lang_id,
				COALESCE(o.pump_vehicle_id::text,'null') AS pump_vehicle_id,
				COALESCE(
					(SELECT SUM(sh.quant)&gt;0
					FROM shipments sh
					WHERE sh.order_id=o.id
					),
				FALSE
				) AS shipped
			FROM orders AS o
			WHERE o.id=%d",
			$this->getExtDbVal($pm,'old_id')
		));
		if (is_array($ar)){
			$old_date_time = strtotime($ar['date_time']);
			$new_date_time = $pm->getParamValue("date_time");
			
			$rebuild_chart = (
				 (floatval($this->getExtDbVal($pm,'quant'))!=floatval($ar['quant']))
				||(intval($this->getExtDbVal($pm,'unload_speed'))!=intval($ar['unload_speed']))
			);
			if ($rebuild_chart){
				Graph_Controller::clearCacheOnDate($dbLink,$old_date_time);
			}
			
			if ($new_date_time!=$old_date_time){
				Graph_Controller::clearCacheOnDate($dbLink,$new_date_time);
			}			
			
			$new_pump_vehicle_id = $this->getExtVal($pm,'pump_vehicle_id');
			
			$pump_sms_ar = NULL;
			//если был насос,а сейчас нет или замена насоса - запомним старые данные для удаления насоса
			if ($ar['pump_vehicle_id'] &amp;&amp; $new_pump_vehicle_id &amp;&amp; $new_pump_vehicle_id!=$ar['pump_vehicle_id']){
				$pump_sms_ar = $this->getDbLink()->query_first(sprintf(
					"SELECT
						*
					FROM sms_pump_order_del
					WHERE order_id=%d",
					$this->getExtDbVal($pm,'old_id'))
				);	
			}						
		}	
		
		$resend_sms = (
		$ar['shipped']=='f'
		&amp;&amp;
		( ($this->getExtVal($pm,'quant') &amp;&amp; $this->getExtVal($pm,'quant')!=$ar['quant'])
		||($this->getExtVal($pm,'phone_cel') &amp;&amp; $this->getExtVal($pm,'phone_cel')!=$ar['phone_cel'])
		||($this->getExtVal($pm,'concrete_type_id') &amp;&amp; $this->getExtVal($pm,'concrete_type_id')!=$ar['concrete_type_id'])
		||($this->getExtVal($pm,'destination_id') &amp;&amp; $this->getExtVal($pm,'destination_id')!=$ar['destination_id'])
		||($this->getExtVal($pm,'lang_id') &amp;&amp; $this->getExtVal($pm,'lang_id')!=$ar['lang_id'])
		||($new_date_time &amp;&amp; $new_date_time!=$old_date_time)
		||($new_pump_vehicle_id &amp;&amp; $new_pump_vehicle_id!=$ar['pump_vehicle_id'])
		)
		);
		//
		parent::update($pm);
		
		if ($resend_sms){
			//changed phone or date_time
			$destination_id = ($pm->getParamValue('destination_id'))? $this->getExtDbVal($pm,'destination_id'):$ar['destination_id'];
			
			$phone_cel = ($pm->getParamValue('phone_cel'))? $this->getExtDbVal($pm,'phone_cel'):$ar['phone_cel'];			
			
			$lang_id = ($pm->getParamValue('lang_id'))? $this->getExtDbVal($pm,'lang_id'):$ar['lang_id'];			
			
			$concrete_type_id = ($pm->getParamValue('concrete_type_id'))? $this->getExtDbVal($pm,'concrete_type_id'):$ar['concrete_type_id'];
			
			$pump_vehicle_id = ($pm->getParamValue('pump_vehicle_id'))? $this->getExtDbVal($pm,'pump_vehicle_id'):$ar['pump_vehicle_id'];
			
			$quant = ($pm->getParamValue('quant'))? $this->getExtDbVal($pm,'quant'):$ar['quant'];
			
			$total = 0;
			$pay_cash = $pm->getParamValue("pay_cash");
			if (
				(isset($pay_cash)&amp;&amp;$pay_cash=='true')
				||
				(!isset($pay_cash)&amp;&amp;$ar['pay_cash']=='t')
			){
				$total = $this->getExtDbVal($pm,'total');
				$total = (isset($total))? $total:$ar['total'];
			}
			
			$date_time = ($pm->getParamValue('date_time'))? $this->getExtVal($pm,"date_time"):$old_date_time;
			
			/** Тип СМС для насосника insert/update
			 * update только если был насос и он же остался (т.е. сейчас передали путую строку)
			 * во всех остальных случаях - insert если вообще надо отправлять насоснику
			 * что определяется в $pump_vehicle_id
			 */
			$pumpInsert = !($ar['pump_vehicle_id']!='null'&amp;&amp;$pm->getParamValue('pump_vehicle_id')=='');
			
			$this->send_messages(
				$this->getExtDbVal($pm,"old_id"),
				$phone_cel,$quant,$total,$date_time,
				$concrete_type_id,$destination_id,
				$lang_id,$pump_vehicle_id,TRUE,$pumpInsert);
				
		}
		
		/* Послать на удаление насоснику если был насос а сейчас нет, или сейчас другой */
		if (is_array($pump_sms_ar) &amp;&amp; count($pump_sms_ar)){
			$sms_service = new SMSService(SMS_LOGIN, SMS_PWD);
			$sms_service->send($pump_sms_ar['phone_cel'],$pump_sms_ar['message'],SMS_SIGN,SMS_TEST);
			
			//Ответственному
			$tel_id = $this->pumpActionRespTels('order_for_pump_del');
			while($tel = $this->getDbLink()->fetch_array($tel_id)){
				$sms_service->send($tel['phone_cel'],$pump_sms_ar['message'],SMS_SIGN,SMS_TEST);
			}			
		}
	}
	
	private function pumpActionRespTels($action){
		return $this->getDbLink()->query(sprintf(
			"SELECT
				u.phone_cel
			FROM sms_pattern_user_phones AS u_tels
			LEFT JOIN users AS u ON u.id=u_tels.user_id
			WHERE sms_pattern_id=(SELECT id FROM sms_patterns WHERE sms_type='%s')
			AND u.phone_cel IS NOT NULL",
			$action
		));		
	}
	
	public function delete($pm){
		/* SMS насоснику */
		$pump_sms_ar = $this->getDbLink()->query_first(sprintf(
			"SELECT
				sms_pump_order_del.*
			FROM sms_pump_order_del
			WHERE order_id=%d",
			$this->getExtDbVal($pm,'id'))
		);	
		if (is_array($pump_sms_ar)&amp;&amp;count($pump_sms_ar)){
			$sms_service = new SMSService(SMS_LOGIN, SMS_PWD);
			$sms_service->send($pump_sms_ar['phone_cel'],$pump_sms_ar['message'],SMS_SIGN,SMS_TEST);
			
			//Ответственному
			$tel_id = $this->pumpActionRespTels('order_for_pump_del');
			while($tel = $this->getDbLink()->fetch_array($tel_id)){
				$sms_service->send($tel['phone_cel'],$pump_sms_ar['message'],SMS_SIGN,SMS_TEST);
			}
		}
	
		Graph_Controller::clearCacheOnOrderId($this->getDbLink(),$pm->getParamValue('id'));
		parent::delete($pm);
	}
	
	public function get_make_orders_list($pm){
		$model = new OrderMakeList_Model($this->getDbLink());
		$this->modelGetList($model,$pm);		
	}

	public function get_make_orders_form($pm){
	
		$dt = (!$pm->getParamValue('date'))? time() : ($this->getExtVal($pm,'date')+Beton::shiftStartTime());
		$date_from = Beton::shiftStart($dt);
		$date_to = Beton::shiftEnd($date_from);
		
		$db_link = $this->getDbLink();
		
		//list
		$model = new OrderMakeList_Model($db_link);
		
		$this->addNewModel(sprintf(
			"SELECT * FROM orders_make_list WHERE date_time BETWEEN '%s' AND '%s'",
			date('Y-m-d H:i:s',$date_from),
			date('Y-m-d H:i:s',$date_to)
		),'OrderMakeList_Model'
		);
		
		//chart
		$db_link_master = $this->getDbLinkMaster();
		$date_for_db = "'".date('Y-m-d',$date_from)."'";
		$this->addModel(Graph_Controller::getPlantLoadModel($db_link,$db_link_master,$date_from,$date_to));
		
		//mat_totals
		$this->addModel(RawMaterial_Controller::getTotalsModel($db_link,$date_for_db));

		//Assigning		
		$this->addModel(Shipment_Controller::getAssigningModel($db_link));
		
		//Vehicles		
		$this->addModel(VehicleSchedule_Controller::getMakeListModel($db_link,$date_for_db));
		
		//features
		$this->addModel(VehicleSchedule_Controller::getFeatureListModel($db_link,$date_for_db));
		
		//weather
		//$this->addModel(Weather_Controller::getCurrentModel($db_link,$this->getDbLinkMaster()));
		
		//init date
		$this->addModel(new ModelVars(
			array('id'=>'InitDate',
				'values'=>array(
					new Field('dt',DT_DATETIME,
						array('value'=>date('Y-m-d H:i:s',$date_from)))
				)
			)
		));		
	}
	
	public function get_make_orders_for_lab_list($pm){
		$this->addNewModel("SELECT * FROM lab_orders_list",'get_make_orders_for_lab_list');
	}
	
	public function get_avail_spots($pm){
		
		$model = new ModelSQL($this->getDbLinkMaster(),array('id'=>'OrderAvailSpots_Model'));
		$model->setSelectQueryText(sprintf(
		"SELECT *
		FROM available_spots_for_order_dif_speed(%s,%f,%f)",
		$this->getExtDbVal($pm,'date'),
		$this->getExtDbVal($pm,'quant'),
		$this->getExtDbVal($pm,'speed')
		));
		
		$model->select(false,null,null,
			null,null,null,null,null,TRUE);
		//
		$this->addModel($model);				
		
	}
	public function complete_descr($pm){
		
		$name_cond = strlen($this->getExtVal($pm,'descr'))?
			sprintf("AND lower(o.descr) LIKE lower(%s)||'%%'",
				$this->getExtDbVal($pm,'descr')
			) : "";
		
		$this->addNewModel(sprintf(
		"SELECT DISTINCT ON (o.descr)
			o.descr,
			o.phone_cel,
			langs_ref(lg) AS langs_ref,
			clients_ref(cl) AS clients_ref
		FROM orders AS o
		LEFT JOIN clients cl ON cl.id=o.client_id
		LEFT JOIN langs lg ON lg.id=o.lang_id
		WHERE o.client_id=%d %s
		ORDER BY o.descr,o.date_time DESC",
		$this->getExtDbVal($pm,'client_id'),
		$name_cond
		),
		'OrderDescr_Model');
	}
	public function get_comment($pm){
		$ar=$this->getDbLink()->query_first(sprintf(
		"SELECT
			comment_text
		FROM orders WHERE id=%d",
		$this->getExtDbVal($pm,'order_id')
		));
		
		if ($ar &amp;&amp; count($ar)==1){
			throw new Exception($ar['comment_text']);
		}
		else{
			throw new Exception('Документ не найден');
		}
	}
	
	public function fields_from_client_order($pm){
		$this->addNewModel(sprintf(
		"SELECT
			ct.id AS concrete_type_id,
			ct.name AS concrete_type_descr,
			o.quant,
			format_cel_phone(o.tel::text) AS tel,
			o.name AS client_descr,
			cl.id AS client_id,
			o.total,
			o.dest AS dest_descr,
			CASE
				WHEN o.pump THEN 'pump'::unload_types
				ELSE 'none'::unload_types
			END AS pump,			
			o.comment_text
			
		FROM orders_from_clients AS o
		LEFT JOIN concrete_types AS ct ON ct.name=o.concrete_type
		LEFT JOIN clients AS cl ON cl.name=o.name
		WHERE o.id=%d",
		$this->getExtDbVal($pm,'client_order_id')
		)
		,"fields_from_client_order");
	}
	
	public function set_payed($pm){
		$this->getDbLinkMaster()->query(sprintf(
			"UPDATE orders
			SET payed=TRUE
			WHERE id=%d",
			$this->getExtDbVal($pm,'id')
		));	
	}	
	
}
<![CDATA[?>]]>
</xsl:template>

</xsl:stylesheet>
