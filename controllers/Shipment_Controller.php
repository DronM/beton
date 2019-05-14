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


require_once('models/ShipmentRep_Model.php');
require_once('models/ShipmentOperator_Model.php');
require_once('models/ShipmentForOrderList_Model.php');
require_once('models/ShipmentPumpList_Model.php');
require_once('models/ShipmentTimeList_Model.php');

require_once('controllers/Graph_Controller.php');
require_once('common/SMSService.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQL.php');


require_once('common/barcode.php');
require_once('common/barcodegen.1d-php5.v5.2.1/class/BCGFontFile.php');
require_once('common/barcodegen.1d-php5.v5.2.1/class/BCGColor.php');
require_once('common/barcodegen.1d-php5.v5.2.1/class/BCGDrawing.php');
require_once('common/barcodegen.1d-php5.v5.2.1/class/BCGean13.barcode.php');
//require_once('common/barcodegen.1d-php5.v5.2.1/class/BCGcodabar.barcode.php');
//require_once('common/barcodegen.1d-php5.v5.2.1/class/BCGcode128.barcode.php');

class Shipment_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtDateTime('date_time'
				,array(
				'alias'=>'Дата'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('order_id'
				,array('required'=>TRUE,
				'alias'=>'Заявка'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('vehicle_schedule_id'
				,array('required'=>TRUE,
				'alias'=>'Экипаж'
			));
		$pm->addParam($param);
		$param = new FieldExtFloat('quant'
				,array(
				'alias'=>'Количество'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
				'alias'=>'Автор'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('production_site_id'
				,array('required'=>FALSE,
				'alias'=>'Завод'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('client_mark'
				,array(
				'alias'=>'Баллы'
			));
		$pm->addParam($param);
		$param = new FieldExtTime('demurrage'
				,array(
				'alias'=>'Простой'
			));
		$pm->addParam($param);
		$param = new FieldExtBool('blanks_exist'
				,array(
				'alias'=>'Наличие бланков'
			));
		$pm->addParam($param);
		$param = new FieldExtBool('owner_agreed'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('owner_agreed_date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('acc_comment'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Shipment_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		$param = new FieldExtDateTime('date_time'
				,array(
			
				'alias'=>'Дата'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('order_id'
				,array(
			
				'alias'=>'Заявка'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('vehicle_schedule_id'
				,array(
			
				'alias'=>'Экипаж'
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('quant'
				,array(
			
				'alias'=>'Количество'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			
				'alias'=>'Автор'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('production_site_id'
				,array(
			
				'alias'=>'Завод'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('client_mark'
				,array(
			
				'alias'=>'Баллы'
			));
			$pm->addParam($param);
		$param = new FieldExtTime('demurrage'
				,array(
			
				'alias'=>'Простой'
			));
			$pm->addParam($param);
		$param = new FieldExtBool('blanks_exist'
				,array(
			
				'alias'=>'Наличие бланков'
			));
			$pm->addParam($param);
		$param = new FieldExtBool('owner_agreed'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('owner_agreed_date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('acc_comment'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Shipment_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Shipment_Model');

			
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
		
		$this->setListModelId('ShipmentList_Model');
		
			
		$pm = new PublicMethod('get_list_for_order');
		
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

			
		$pm = new PublicMethod('get_pump_list');
		
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

			
		$pm = new PublicMethod('get_shipment_date_list');
		
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

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ShipmentDialog_Model');		

			
		$pm = new PublicMethod('get_assigned_vehicle_list');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_operator_list');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtDate('date',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_shipped');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('unset_shipped');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('shipment_report');
		
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
					
		$pm->addParam(new FieldExtString('grp_fields',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('agg_fields',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('shipment_invoice');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('templ',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('inline',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_time_list');
		
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

			
		$pm = new PublicMethod('set_blanks_exist');
		
				
	$opts=array();
	
		$opts['length']=13;				
		$pm->addParam(new FieldExtString('barcode',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_shipped');
		
				
	$opts=array();
	
		$opts['length']=500;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('comment_text',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_assigned');
		
		$this->addPublicMethod($pm);

		
	}
	public function shipment_report($pm){
		$model = new ShipmentRep_Model($this->getDbLink());
		
		$from = null; $count = null;
		$limit = $this->limitFromParams($pm,$from,$count);
		$calc_total = ($count>0);
		if ($from){
			$model->setListFrom($from);
		}
		if ($count){
			$model->setRowsPerPage($count);
		}
		
		$order = $this->orderFromParams($pm,$model);
		$where = $this->conditionFromParams($pm,$model);
		$fields = $this->fieldsFromParams($pm);		
		$grp_fields = $this->grpFieldsFromParams($pm);		
		$agg_fields = $this->aggFieldsFromParams($pm);		
			
		$model->select(false,$where,$order,
			$limit,$fields,$grp_fields,$agg_fields,
			$calc_total,TRUE);
		//
		$this->addModel($model);		
	}
	public function insert($pm){
		$pm->setParamValue("user_id",$_SESSION['user_id']);
		parent::insert($pm);
	}
	
	public function delete($pm){
		Graph_Controller::clearCacheOnShipId($this->getDbLink(),$pm->getParamValue("id"));
		parent::delete($pm);
	}
	public function shipment_invoice($pm){
		$link = $this->getDbLink();
		$model = new ModelSQL($link,array("id"=>"ShipmentInvoice_Model"));
		$model->addField(new FieldSQL($link,null,null,"number",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"month_str",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"day",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"year",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"time",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"client_descr",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"client_tel",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"concrete_type_descr",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"quant",DT_FLOAT));
		$model->addField(new FieldSQL($link,null,null,"destination_descr",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"driver_descr",DT_STRING));
		$model->addField(new FieldSQL($link,null,null,"vehicle_descr",DT_STRING));
				
		$model->setSelectQueryText(
		sprintf(
		"SELECT order_num(o) AS number,
			get_month_rus(sh.date_time::date) AS month_str,
			EXTRACT(DAY FROM sh.date_time::date) AS day,
			EXTRACT(YEAR FROM sh.date_time::date) AS year,
			CASE WHEN
				date_part('hour',sh.date_time) < 10 THEN 
				'0' || date_part('hour',sh.date_time)::text
				ELSE date_part('hour',sh.date_time)::text
			END || '-' ||
			CASE WHEN
				date_part('minute',sh.date_time) < 10 THEN 
				'0' || date_part('minute',sh.date_time)::text
				ELSE date_part('minute',sh.date_time)::text
			END AS time,
			ct.name AS concrete_type_descr,
			cl.name_full AS client_descr,
			format_cel_phone(o.phone_cel) AS client_tel,
			sh.quant AS quant,
			dest.name AS destination_descr,
			dr.name AS driver_descr,
			coalesce(vh.make || ' ','') || vh.plate AS vehicle_descr
		FROM shipments AS sh
		LEFT JOIN orders AS o ON o.id = sh.order_id
		LEFT JOIN concrete_types AS ct ON ct.id = o.concrete_type_id
		LEFT JOIN destinations AS dest ON dest.id = o.destination_id
		LEFT JOIN clients AS cl ON cl.id = o.client_id
		LEFT JOIN vehicle_schedules AS vs ON vs.id = sh.vehicle_schedule_id
		LEFT JOIN drivers AS dr ON dr.id = vs.driver_id
		LEFT JOIN vehicles AS vh ON vh.id = vs.vehicle_id
		WHERE sh.id=%d"
		,$this->getExtDbVal($pm,'id')
		));
		
		$model->select(false,null,null,
			null,null,null,null,null,TRUE);
		//
		$this->addModel($model);			
		
		//barcode
		$shipment_id = $this->getExtVal($pm,'id');
		$barcode_descr = '0'.$shipment_id.substr('000000000000',1,12-strlen($shipment_id)-1);
		$barcode_descr = $barcode_descr.EAN_check_sum($barcode_descr,13);
		//**** Генерация баркода ****
		$colorFont = new BCGColor(0, 0, 0);
		$colorBack = new BCGColor(255, 255, 255);		
		
		$code = new BCGean13(); // Or another class name from the manual
		//$code = new BCGcodabar();
		
		$code->setScale(1); // Resolution
		$code->setThickness(30); // Thickness
		$code->setForegroundColor($colorFont); // Color of bars
		$code->setBackgroundColor($colorBack); // Color of spaces
		$code->setFont(0); // Font (or 0) $font
		$code->parse($barcode_descr); // Text
		$drawing = new BCGDrawing('', $colorBack);
		$drawing->setBarcode($code);
		$drawing->draw();
		ob_start();
		$drawing->finish(BCGDrawing::IMG_FORMAT_PNG);
		$contents = ob_get_contents();
		ob_end_clean();
		//**** Генерация баркода ****
		
		$fields = array();		
		array_push($fields,new Field('descr',DT_STRING,array('value'=>$barcode_descr)));
		array_push($fields,new Field('mime',DT_STRING,array('value'=>'image/png')));
		array_push($fields,new Field('img',DT_STRING,array('value'=>base64_encode($contents))));
		
		$this->addModel(new ModelVars(
			array('id'=>'Barcode_Model',
				'values'=>$fields)
			)
		);
		
	}
	
	public function set_blanks_exist($pm){
		$barcode = $pm->getParamValue("barcode");
		$shipment_id = 0;
		if (strlen($barcode)==13 && substr($barcode,0,1)=='0'){
			//by barcode
			$shipment_id = intval(substr($barcode,1,11));
		}
		else if (strlen($barcode)==12 && substr($barcode,0,1)=='0'){
			//by barcode
			$shipment_id = intval(substr($barcode,1,10));
		}		
		else{
			//by shipment id
			$shipment_id = intval($barcode);
		}
		
		if (!$shipment_id){
			throw new Exception('Документ '.$barcode.' не найден!');
		}
		
		
		$ar = $this->getDbLinkMaster()->query_first(
			sprintf(
			"UPDATE shipments
			SET
				blanks_exist=true
			WHERE id=%d
			RETURNING id",
			$shipment_id)
		);
		if (!is_array($ar) || !count($ar)){
			throw new Exception('Документ '.$barcode.' не найден!');
		}
		
	}
	
	public function get_operator_list($pm){
	
		$dt = (!$pm->getParamValue('date'))? time() : ($this->getExtVal($pm,'date')+Beton::shiftStartTime());
		$date_from = Beton::shiftStart($dt);
		$date_to = Beton::shiftEnd($date_from);
		$date_from_db = "'".date('Y-m-d H:i:s',$date_from)."'";
		$date_to_db = "'".date('Y-m-d H:i:s',$date_to)."'";
	
		$operator_cond = '';
		$extra_cols_str = '';
		if($_SESSION['role_id']=='operator' && isset($_SESSION['production_site_id']) ){
			$operator_cond = sprintf(' AND sh.production_site_id=%d',$_SESSION['production_site_id']);
		}
		else{
			$extra_cols_str =
			",shipment_time_norm(sh.quant::numeric) AS ship_norm_min
			,(CASE
				WHEN sh.shipped THEN
					EXTRACT(EPOCH FROM
						sh.ship_date_time-
						(SELECT
							vss.date_time
						FROM vehicle_schedule_states AS vss
						WHERE vss.shipment_id=sh.id
						AND vss.state='assigned'
						)
					)/60
				ELSE 0
			END)::int AS ship_fact_min
			,CASE
				WHEN sh.shipped THEN
					(EXTRACT(EPOCH FROM
						sh.ship_date_time-
						(SELECT
							vss.date_time
						FROM vehicle_schedule_states AS vss
						WHERE vss.shipment_id=sh.id
						AND vss.state='assigned'
						)
					)/60)::int - 
					shipment_time_norm(sh.quant::numeric)
				ELSE 0
			END AS ship_bal_min";
		}
		
		$this->addNewModel(sprintf(
		"WITH ships AS (
		SELECT
			sh.id,
			clients_ref(cl) AS clients_ref,
			destinations_ref(dest) AS destinations_ref, 
			concrete_types_ref(ct) AS concrete_types_ref, 
			vehicles_ref(v)::text AS vehicles_ref, 
			drivers_ref(d) AS drivers_ref,
			sh.date_time,
			sh.quant,
			sh.shipped,
			sh.ship_date_time,
			o.comment_text,
			sh.production_site_id,
			production_sites_ref(ps) AS production_sites_ref,
			users_ref(op_u) AS operators_ref
			%s
		FROM shipments AS sh
		LEFT JOIN orders o ON o.id = sh.order_id
		LEFT JOIN clients cl ON cl.id = o.client_id
		LEFT JOIN vehicle_schedules vs ON vs.id = sh.vehicle_schedule_id
		LEFT JOIN drivers d ON d.id = vs.driver_id
		LEFT JOIN vehicles v ON v.id = vs.vehicle_id
		LEFT JOIN destinations dest ON dest.id = o.destination_id
		LEFT JOIN concrete_types ct ON ct.id = o.concrete_type_id
		LEFT JOIN production_sites ps ON ps.id = sh.production_site_id
		LEFT JOIN users AS op_u ON op_u.id=sh.operator_user_id
		WHERE (sh.shipped = FALSE OR (sh.ship_date_time BETWEEN %s AND %s))".$operator_cond."
		)
		--Все неотгруженные
		(SELECT sh.*
		FROM ships AS sh
		WHERE (sh.shipped = FALSE)".$operator_cond."
		ORDER BY sh.date_time)
	
		UNION ALL
	
		--Все отгруженные за сегодня
		(SELECT sh.*
		FROM ships AS sh
		WHERE (sh.shipped = TRUE)".$operator_cond."
		ORDER BY sh.ship_date_time DESC)",
		$extra_cols_str,
		$date_from_db,
		$date_to_db
		),
		"OperatorList_Model"
		);
		
		//totals
		$this->addNewModel(sprintf(
		"SELECT
			coalesce((SELECT sum(quant) FROM shipments WHERE ship_date_time BETWEEN %s AND %s AND shipped),0) AS quant_shipped,
			coalesce((SELECT sum(quant) FROM orders WHERE date_time BETWEEN %s AND %s),0) AS quant_ordered",
		$date_from_db,
		$date_to_db,
		$date_from_db,
		$date_to_db		
		),
		'OperatorTotals_Model');
	}
	
	public function set_shipped($pm){
		$id = $pm->getParamValue("id");	
		$this->getDbLinkMaster()->query(
			sprintf(
			"UPDATE shipments SET
				shipped=TRUE,
				operator_user_id=%d
			WHERE id=%d",
			$_SESSION["user_id"],
			$this->getExtDbVal($pm,"id")
			)
		);
		
		Graph_Controller::clearCacheOnShipId($this->getDbLink(),$id);		
			
		//SMS service
		if (SMS_ACTIVE) {
			$dbLink = $this->getDbLink();
			$ar = $dbLink->query_first(sprintf(
			"SELECT
				orders.id AS order_id,
				orders.phone_cel,
				shipments.quant,
				concrete_types.name AS concrete,
				d.name AS d_name,
				coalesce(d.phone_cel,'') AS d_phone,
				v.plate AS v_plate,
				(SELECT pattern FROM sms_patterns
					WHERE sms_type='ship'::sms_types
					AND lang_id= orders.lang_id
				) AS text	
			FROM orders
			LEFT JOIN shipments ON shipments.order_id=orders.id
			LEFT JOIN concrete_types ON concrete_types.id=orders.concrete_type_id
			LEFT JOIN vehicle_schedules AS vs ON vs.id=shipments.vehicle_schedule_id
			LEFT JOIN drivers AS d ON d.id=vs.driver_id
			LEFT JOIN vehicles AS v ON v.id=vs.vehicle_id									
			WHERE shipments.id=%d"
			,$this->getExtDbVal($pm,"id"))
			);
			
			if (strlen($ar['phone_cel'])){
				$text = $ar['text'];
				$text = str_replace('[quant]',$ar['quant'],$text);
				$text = str_replace('[concrete]',$ar['concrete'],$text);
				$text = str_replace('[car]',$ar['v_plate'],$text);
				
				$driver = $ar['d_name'];
				$d_phone = $ar['d_phone'];
				$d_phone = str_replace('_','',$d_phone);
				$driver.= ($d_phone!='' && strlen($d_phone)==15)? ' '.$d_phone:'';				
				$text = str_replace('[driver]',$driver,$text);
				try{
					$sms_service = new SMSService(SMS_LOGIN, SMS_PWD);
					$sms_id_resp = $sms_service->send($ar['phone_cel'],$text,SMS_SIGN,SMS_TEST);
					$sms_id = NULL;
					FieldSQLString::formatForDb($this->getDbLink(),$sms_id_resp,$sms_id);
					$this->getDbLinkMaster()->query(sprintf(
					"UPDATE sms_service SET
						shipment_id=%d,
						sms_id_shipment=%s,
						shipment_sms_time='%s'
					WHERE order_id=%d",
						$this->getExtDbVal($pm,"id"),
						$sms_id,
						date('Y-m-d H:i:s'),
						$ar['order_id'])
					);
					
					$sms_res_str = '';
					$sms_res_ok = 1;
				}
				catch (Exception $e){
					$sms_res_str = $e->getMessage();
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
		}
	}
	public function unset_shipped(){
		$pm = $this->getPublicMethod("unset_shipped");
		$dbLink = $this->getDbLink();
		$id = $this->getExtDbVal($pm,"id");			
		
		$ar = $dbLink->query_first(
			sprintf("SELECT ship_date_time
			FROM shipments WHERE id=%d",
				$id)
			);
		if (is_array($ar)){
			Graph_Controller::clearCacheOnDate(
				$dbLink,strtotime($ar['ship_date_time']));		
		}	
				
		$this->getDbLinkMaster()->query(
			sprintf("UPDATE shipments SET
				shipped=false
			WHERE id=%d",$id)
		);
	}
	public function get_list_for_order(){
		$this->modelGetList(new ShipmentForOrderList_Model($this->getDbLink()),
			$this->getPublicMethod('get_list_for_order')
		);
	}
	public function get_pump_list($pm){
		$this->modelGetList(new ShipmentPumpList_Model($this->getDbLink()),$pm);
	}
	public function get_shipment_date_list($pm){
		$this->modelGetList(new ShipmentDateList_Model($this->getDbLink()),$pm);
	}
	public function get_time_list($pm){
		/*
		$where = $this->conditionFromParams($pm,$model);
		if(!$where){
			$date_from = Beton::shiftStart(time());
			$date_to = Beton::shiftEnd($date_from);		
		}
		else{
			$date_from = $where->getFieldsById('ship_date_time','>=');
			if(!isset($date_from)){
			
			}
			
			$date_to = $where->getFieldsById('ship_date_time','<=');
		}
		*/
		$this->modelGetList(new ShipmentTimeList_Model($this->getDbLink()),$pm);
	}
	public static function getAssigningModel($dbLink){
		$model = new ModelSQL($dbLink,array('id'=>'AssignedVehicleList_Model'));
		$model->query("SELECT * FROM assigned_vehicles_list",TRUE);
		return $model;	
	
	}
	
	public function get_assigned_vehicle_list($pm){
		$this->addModel(self::getAssigningModel($this->getDbLink()));
	}
	
	public function delete_shipped($pm){
	}
	public function delete_assigned($pm){
	}
	
}
?>