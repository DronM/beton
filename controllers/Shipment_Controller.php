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


require_once(USER_MODELS_PATH.'ShipmentRep_Model.php');
require_once(USER_MODELS_PATH.'ShipmentOperator_Model.php');
require_once(USER_MODELS_PATH.'ShipmentForOrderList_Model.php');
require_once(USER_MODELS_PATH.'ShipmentPumpList_Model.php');
require_once(USER_MODELS_PATH.'ShipmentTimeList_Model.php');

require_once(USER_CONTROLLERS_PATH.'Graph_Controller.php');

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
		$param = new FieldExtInterval('demurrage'
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
		$param = new FieldExtText('acc_comment_shipment'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('owner_pump_agreed'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('owner_pump_agreed_date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('pump_cost'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('pump_cost_edit'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('ship_cost'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('ship_cost_edit'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('pump_for_client_cost'
				,array());
		$pm->addParam($param);
		$param = new FieldExtBool('pump_for_client_cost_edit'
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
		$param = new FieldExtInterval('demurrage'
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
		$param = new FieldExtText('acc_comment_shipment'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('owner_pump_agreed'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('owner_pump_agreed_date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('pump_cost'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('pump_cost_edit'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('ship_cost'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('ship_cost_edit'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('pump_for_client_cost'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtBool('pump_for_client_cost_edit'
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
		
			
		$pm = new PublicMethod('get_list_for_veh_owner');
		
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

			
		$pm = new PublicMethod('get_list_for_client_veh_owner');
		
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

			
		$pm = new PublicMethod('get_pump_list_for_veh_owner');
		
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
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('production_site_id',$opts));
	
			
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
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('shipment_id',$opts));
	
				
	$opts=array();
	
		$opts['length']=500;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('comment_text',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('delete_assigned');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('shipment_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('owner_set_agreed');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('shipment_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('owner_set_agreed_all');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('owner_set_pump_agreed');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('shipment_id',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('owner_set_pump_agreed_all');
		
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_shipped_vihicles_list');
		
		$this->addPublicMethod($pm);

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('id'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('OrderList_Model');

		
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
		$barcode_descr = '0'.substr('000000000000',1,12-strlen($shipment_id)-1).$shipment_id;
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
		$operator_cond_tot = '';
		$operator_with = '';
		$extra_cols_str = '';
		if($_SESSION['role_id']=='operator'){
			$operator_with = sprintf('prod_site AS (SELECT u.production_site_id FROM users u WHERE u.id=%d),',$_SESSION['user_id']);
			$operator_cond = ' AND sh.production_site_id=(SELECT prod_site.production_site_id FROM prod_site)';
			$operator_cond_tot = sprintf(' AND sh.production_site_id=(SELECT u.production_site_id FROM users u WHERE u.id=%d)',$_SESSION['user_id']);
			$extra_join = '';
		}
		else{
			$extra_cols_str =
			",shipment_time_norm(sh.quant::numeric) AS ship_norm_min
			,(CASE
				WHEN sh.shipped THEN
					EXTRACT(EPOCH FROM
						sh.ship_date_time-vs2.date_time
					)/60
				ELSE 0
			END)::int AS ship_fact_min
			,CASE
				WHEN sh.shipped THEN
					(EXTRACT(EPOCH FROM
						sh.ship_date_time-vs2.date_time
					)/60)::int - 
					shipment_time_norm(sh.quant::numeric)
				ELSE 0
			END AS ship_bal_min";
			$extra_join = "LEFT JOIN (SELECT t.shipment_id,t.date_time FROM vehicle_schedule_states t WHERE t.state='assigned' GROUP BY t.shipment_id,t.date_time) vs2 ON vs2.shipment_id = sh.id";
		}
		
		$q = sprintf(
		"WITH
		%s
		ships AS (
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
			users_ref(op_u) AS operators_ref,
			(SELECT json_agg(row_to_json(productions)) FROM productions WHERE productions.shipment_id=sh.id) AS production_list
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
		%s
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
		$operator_with,
		$extra_cols_str,
		$extra_join,
		$date_from_db,
		$date_to_db
		);
		$m = new ModelSQL($this->getDbLink(),array('id'=>"OperatorList_Model"));
		$m->setCalcHash(TRUE);
		$m->query($q,TRUE);
		$this->addModel($m);
		
		//totals
		$this->addNewModel(sprintf(
		"SELECT
			coalesce((SELECT sum(sh.quant) FROM shipments AS sh WHERE sh.ship_date_time BETWEEN %s AND %s AND sh.shipped".$operator_cond_tot."),0) AS quant_shipped,
			coalesce((SELECT sum(quant) FROM orders WHERE date_time BETWEEN %s AND %s),0) AS quant_ordered",
		$date_from_db,
		$date_to_db,
		$date_from_db,
		$date_to_db		
		),
		'OperatorTotals_Model');
		
		//production site(s)
		if($_SESSION['role_id']=='operator'){
			$prod_site_q = sprintf(
				'SELECT ps.name
				FROM production_sites ps
				WHERE ps.id=(SELECT u.production_site_id FROM users u WHERE u.id=%d)',
				$_SESSION['user_id']
			);
		}
		else{
			$prod_site_q = 'SELECT ps.name FROM production_sites ps';
		}
		$this->addNewModel($prod_site_q,'OperatorProductionSite_Model');				
	}
	
	public static function sendShipSMS($dbLinkMaster,$dbLink,$idForDb,$smsResOk,$smsResStr,$interactiveMode){
		//SMS service
		if (SMS_ACTIVE) {
			//Может не быть изменений order_id на слейве после update!!!
			$ar = $dbLinkMaster->query_first(sprintf(
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
			WHERE shipments.id=%d",
			$idForDb
			));
			
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
				
				if($interactiveMode){
					try{
						$sms_service = new SMSService(SMS_LOGIN, SMS_PWD);
						$sms_id_resp = $sms_service->send($ar['phone_cel'],$text,SMS_SIGN,SMS_TEST);
						$sms_id = NULL;
						FieldSQLString::formatForDb($dbLink,$sms_id_resp,$sms_id);
						$dbLinkMaster->query(sprintf(
						"UPDATE sms_service SET
							shipment_id=%d,
							sms_id_shipment=%s,
							shipment_sms_time='%s'
						WHERE order_id=%d",
							$idForDb,
							$sms_id,
							date('Y-m-d H:i:s'),
							$ar['order_id'])
						);
					
						$smsResStr = '';
						$smsResOk = 1;
					}
					catch (Exception $e){
						$smsResStr = $e->getMessage();
						$smsResOk = 0;
					}				
				}
				else{
					//Отложенная отправка - по-новому (используется из автоотгрузки Production_Controller)
					$dbLinkMaster->query(sprintf(
						"INSERT INTO sms_for_sending
						(tel,body,sms_type)
						VALUES (%s,%s,'ship')",
						$ar['phone_cel'],
						$text
					));					
				}
			}
		}	
	
	}
	
	public static function setShipped($dbLinkMaster,$dbLink,$idForDb,$operatorUserId,$smsResOk,$smsResStr,$interactiveMode){
		$dbLinkMaster->query(
			sprintf(
			"UPDATE shipments SET
				shipped=TRUE,
				operator_user_id=%d
			WHERE id=%d",
			$_SESSION["user_id"],
			$idForDb
			)
		);
		
		Graph_Controller::clearCacheOnShipId($dbLink,$idForDb);		
		
		self::sendShipSMS($dbLinkMaster,$dbLink,$idForDb,$smsResOk,$smsResStr,$interactiveMode);	
	}
	
	public function set_shipped($pm){
		$sms_res_ok = 0;
		$sms_res_str = '';
		
		self::setShipped(
			$this->getDbLinkMaster(),
			$this->getDbLink(),
			$this->getExtDbVal($pm,"id"),
			$_SESSION["user_id"],
			$sms_res_ok,
			$sms_res_str,
			TRUE
		);
		
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
	
	
		/*
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
		*/
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

	private function get_list_query(){
		return 
			"SELECT
				shipments.id,
				shipments.ship_date_time,
				shipments.quant,
		
				shipments_cost(dest,o.concrete_type_id,o.date_time::date,shipments,TRUE) AS cost,
		
				shipments.shipped,
				concrete_types_ref(concr) AS concrete_types_ref,
				o.concrete_type_id,		
				v.owner,
		
				vehicles_ref(v) AS vehicles_ref,
				vs.vehicle_id,
		
				drivers_ref(d) AS drivers_ref,
				vs.driver_id,
		
				destinations_ref(dest) As destinations_ref,
				o.destination_id,
		
				clients_ref(cl) As clients_ref,
				o.client_id,
		
				shipments_demurrage_cost(shipments.demurrage::interval) AS demurrage_cost,
				shipments.demurrage,
		
				shipments.client_mark,
				shipments.blanks_exist,
		
				users_ref(u) As users_ref,
				o.user_id,
		
				production_sites_ref(ps) AS production_sites_ref,
				shipments.production_site_id,
		
				vehicle_owners_ref(v_own) AS vehicle_owners_ref,
		
				shipments.acc_comment,
				v_own.id AS vehicle_owner_id,
		
				shipments_pump_cost(shipments,o,dest,pvh,TRUE) AS pump_cost,
		
				pump_vehicles_ref(pvh,pvh_v) AS pump_vehicles_ref,
				pvh.vehicle_id AS pump_vehicle_id,
				pvh_v.vehicle_owner_id AS pump_vehicle_owner_id,
				shipments.owner_agreed,
				shipments.owner_agreed_date_time,
				shipments.owner_pump_agreed,
				shipments.owner_pump_agreed_date_time,
		
				vehicle_owners_ref(pvh_own) AS pump_vehicle_owners_ref,
		
				CASE
					WHEN coalesce(dest.special_price,FALSE) THEN coalesce(dest.price,0)
					ELSE
					coalesce(
						(SELECT sh_p.price
						FROM shipment_for_owner_costs sh_p
						WHERE sh_p.date<=o.date_time::date AND sh_p.distance_to>=dest.distance
						ORDER BY sh_p.date DESC,sh_p.distance_to ASC
						LIMIT 1
						),			
					coalesce(dest.price,0))			
				END AS ship_price,
		
				coalesce(shipments.ship_cost_edit,FALSE) AS ship_cost_edit,
				coalesce(shipments.pump_cost_edit,FALSE) AS pump_cost_edit
		
			FROM shipments
			LEFT JOIN orders o ON o.id = shipments.order_id
			LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
			LEFT JOIN clients cl ON cl.id = o.client_id
			LEFT JOIN vehicle_schedules vs ON vs.id = shipments.vehicle_schedule_id
			LEFT JOIN destinations dest ON dest.id = o.destination_id
			LEFT JOIN drivers d ON d.id = vs.driver_id
			LEFT JOIN vehicles v ON v.id = vs.vehicle_id
			LEFT JOIN users u ON u.id = shipments.user_id
			LEFT JOIN production_sites ps ON ps.id = shipments.production_site_id
			LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id
			LEFT JOIN pump_vehicles pvh ON pvh.id = o.pump_vehicle_id
			LEFT JOIN vehicles pvh_v ON pvh_v.id = pvh.vehicle_id
			LEFT JOIN vehicle_owners pvh_own ON pvh_own.id = pvh_v.vehicle_owner_id";	
	}

	private function get_list_for_veh_owner_query(){
		return 
			"SELECT
				shipments.id,
				shipments.ship_date_time,
				shipments.quant,
				shipments_cost(dest,o.concrete_type_id,o.date_time::date,sh,TRUE) AS cost,
				concrete_types_ref(concr) AS concrete_types_ref,
				o.concrete_type_id,				
				vehicles_ref(v) AS vehicles_ref,
				vs.vehicle_id,
				destinations_ref(dest) AS destinations_ref,
				o.destination_id,
				shipments_demurrage_cost(shipments.demurrage::interval) AS demurrage_cost,
				shipments.demurrage,
				vehicle_owners_ref(v_own) AS vehicle_owners_ref,		
				shipments.acc_comment,
				v_own.id AS vehicle_owner_id,		
				shipments.owner_agreed,
				shipments.owner_agreed_date_time
				coalesce(shipments.ship_cost_edit,FALSE) AS ship_cost_edit		
			FROM shipments
			LEFT JOIN orders o ON o.id = sh.order_id
			LEFT JOIN concrete_types concr ON concr.id = o.concrete_type_id
			LEFT JOIN vehicle_schedules vs ON vs.id = shipments.vehicle_schedule_id
			LEFT JOIN destinations dest ON dest.id = o.destination_id
			LEFT JOIN vehicle_owners v_own ON v_own.id = v.vehicle_owner_id";	
	}

	public function get_list($pm){
		/*
		$model = new ShipmentList_Model($this->getDbLink());
		$is_insert = NULL;
		$where = NULL;
		$order = NULL;
		$limit = NULL;
		$fields = NULL;
		$grp_fields = NULL;
		$agg_fields = NULL;
		$calc_total = NULL;
		$this->setQueryOptionsFromParams($model,$pm,$is_insert,$where,$order,
			$limit,$fields,$grp_fields,$agg_fields,$calc_total
		);	
		
		if(!$order){
			$order = new ModelOrderSQL();
			$order->addField($model->getFieldById('ship_date_time'),'DESC');
		}
		
		$join = NULL;$group = NULL;
		$q = $this->get_list_query();
		$model->addParamsToSelectQuery(
			$q,
			$where,
			$order,
			$limit,
			$join,$group,
			$calc_total
		);
		$model->selectQuery($q,$calc_total,$where,NULL,TRUE);
		
		//
		$this->addModel($model);
		*/
		$this->modelGetList(new ShipmentList_Model($this->getDbLink()),$pm);
	}	

	public function get_list_for_veh_owner($pm){	
		/*
		$model = new ShipmentForVehOwnerList_Model($this->getDbLink());
		$is_insert = NULL;
		$where = NULL;
		$order = NULL;
		$limit = NULL;
		$fields = NULL;
		$grp_fields = NULL;
		$agg_fields = NULL;
		$calc_total = NULL;
		$this->setQueryOptionsFromParams($model,$pm,$is_insert,$where,$order,
			$limit,$fields,$grp_fields,$agg_fields,$calc_total
		);	
		
		if(!$order){
			$order = new ModelOrderSQL();
			$order->addField($model->getFieldById('ship_date_time'),'DESC');
		}
		
		$q = $this->get_list_for_veh_owner_query();
		$join = NULL;$group = NULL;
		$model->addParamsToSelectQuery(
			$q,
			$where,
			$order,
			$limit,
			$join,$group,
			$calc_total
		);
		$model->selectQuery($q,$calc_total,$where,NULL,TRUE);
		
		//
		$this->addModel($model);
		*/
		$this->modelGetList(new ShipmentForVehOwnerList_Model($this->getDbLink()),$pm);
	}
	
	public function get_pump_list($pm){
	
		$this->modelGetList(new ShipmentPumpList_Model($this->getDbLink()),$pm);
	}

	public function get_pump_list_for_veh_owner($pm){
	
		$this->modelGetList(new ShipmentPumpForVehOwnerList_Model($this->getDbLink()),$pm);
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
	public static function getAssigningModel($dbLink,$prodSiteId=0){
		$model = new ModelSQL($dbLink,array('id'=>'AssignedVehicleList_Model'));
		$cond = '';
		if($prodSiteId){
			$cond = sprintf(' WHERE production_site_id=%d',$prodSiteId);
		}
		$model->query("SELECT * FROM assigned_vehicles_list".$cond,TRUE);
		return $model;	
	
	}
	
	public function get_assigned_vehicle_list($pm){
		$this->addModel(self::getAssigningModel($this->getDbLink()),$this->getExtDbVal($pm,'production_site_id'));
		$this->modelGetList(new ShippedVehicleList_Model($this->getDbLink()),$pm);
	}
	
	public function delete_shipped($pm){
		$l = $this->getDbLinkMaster();		
		try{
			$l->query("BEGIN");

			$l->query(
				sprintf(
					"INSERT INTO shipment_cancelations
					(order_id,vehicle_schedule_id,comment_text,user_id,date_time,ship_date_time,assign_date_time,quant)
					(SELECT
						sh.order_id,
						sh.vehicle_schedule_id,
						%s,
						%d,
						now(),
						sh.ship_date_time,
						sh.date_time,
						sh.quant
						
					FROM shipments AS sh
					WHERE sh.id=%d
					)",
					$this->getExtDbVal($pm,"comment_text"),
					$_SESSION['user_id'],					
					$this->getExtDbVal($pm,"shipment_id")
				)
			);

			self::do_delete_shipment($l,$this->getExtDbVal($pm,"shipment_id"));
			
			$l->query("COMMIT");
		}
		catch (Exception $e){
			$l->query("ROLLBACK");
			throw $e;
	
		}
	}
	
	public static function do_delete_shipment($link,$shipmentId){
		
		$link->query(
			sprintf(
				"DELETE FROM vehicle_schedule_states WHERE shipment_id=%d",
				$shipmentId
			)
		);		
		
		$link->query(
			sprintf(
				"DELETE FROM shipments WHERE id=%d",
				$shipmentId
			)
		);		
		
	}
	
	public function delete_assigned($pm){
		$l = $this->getDbLinkMaster();		
		try{
			$l->query("BEGIN");

			self::do_delete_shipment($l,$this->getExtDbVal($pm,"shipment_id"));
			
			$l->query("COMMIT");
		}
		catch (Exception $e){
			$l->query("ROLLBACK");
			throw $e;
		}		
	}

	private function update_owner_agreed_field($shipmentId,$isPump){
	
		if($_SESSION['role_id']=='vehicle_owner'){
			//а можно ли 			
			
			//check
			if($isPump){
				$q = "SELECT
						sh.pump_vehicle_owner_id AS vehicle_owner_id,
						(
							SELECT (now()::date BETWEEN d_from AND d_to) FROM shipment_accord_allowed(sh.date_time::date)	
						) AS acc_allowed
					FROM shipments_pump_list AS sh
					WHERE sh.last_ship_id=%d";			
			}
			else{
				$q = "SELECT
						v.vehicle_owner_id,
						(
							SELECT (now()::date BETWEEN d_from AND d_to) FROM shipment_accord_allowed(sh.ship_date_time::date)
						) AS acc_allowed
					FROM shipments AS sh
					LEFT JOIN vehicle_schedules AS sch ON sch.id=sh.vehicle_schedule_id
					LEFT JOIN vehicles AS v ON v.id=sch.vehicle_id
					WHERE sh.id=%d";
			}			
			$ar = $this->getDbLinkMaster()->query_first(
				sprintf($q,$shipmentId)
			);
			if(!is_array($ar) || !count($ar) || $ar['vehicle_owner_id']!=$_SESSION['global_vehicle_owner_id']
			||$ar['acc_allowed']!='t'
			){
				throw new Exception('Permission denied!');
			}
		}
		else if($_SESSION['role_id']!='owner'){
			throw new Exception('Permission denied!');
		}
		
		$set_field_id = $isPump? 'owner_pump_agreed':'owner_agreed';
		$this->getDbLinkMaster()->query(
			sprintf(
				"UPDATE shipments
				SET
					%s=TRUE,
					%s_date_time=now()
				WHERE id=%d",
				$set_field_id,$set_field_id,				
				$shipmentId
			)
		);
	}
	
	function owner_set_agreed($pm){
		$this->update_owner_agreed_field($this->getExtDbVal($pm,'shipment_id'),FALSE);
	}
	
	function owner_set_pump_agreed($pm){
		$this->update_owner_agreed_field($this->getExtDbVal($pm,'shipment_id'),TRUE);
	}
	
	public function get_list_for_client_veh_owner($pm){	
		$this->modelGetList(new ShipmentForClientVehOwnerList_Model($this->getDbLink()),$pm);
	}

	public function owner_set_agreed_all($pm){	
		$this->getDbLink()->query(
			"UPDATE shipments
				SET
					owner_agreed=TRUE,
					owner_agreed_date_time=now(),
					owner_agreed_auto=FALSE
			FROM (				
			WITH
				mon AS (
					SELECT
						CASE WHEN extract('month' FROM now())=1 THEN 12
							ELSE extract('month' FROM now())-1
						END AS v
				),
				d_from AS (
					SELECT (
						(CASE WHEN (SELECT v FROM mon)=12 THEN extract('year' FROM now())-1 ELSE extract('year' FROM now()) END)::text
						||'-'|| (CASE WHEN (SELECT v FROM mon)<10 THEN '0' ELSE '' END )||(SELECT v FROM mon) ||'-01'
					)::date+
					const_first_shift_start_time_val()
					AS v
				),
				per AS (SELECT	
					(SELECT v FROM d_from) AS d_from,
					get_shift_end(
						((SELECT v FROM d_from) + '1 month'::interval -'1 day'::interval)::date+
						const_first_shift_start_time_val()
					)
					AS d_to
				)
			SELECT shipments.id AS ship_id
			FROM shipments
			WHERE 
				extract('day' FROM now())>const_vehicle_owner_accord_to_day_val()
				AND coalesce(owner_agreed,FALSE)=FALSE
				AND ship_date_time BETWEEN (SELECT d_from FROM per) AND (SELECT d_to FROM per)
			) AS sub
			WHERE sub.ship_id = shipments.id"
		);
	
	}

	public function owner_set_pump_agreed_all($pm){	
		$dbLink->query(
			"UPDATE shipments
				SET
					owner_pump_agreed=TRUE,
					owner_pump_agreed_date_time=now(),
					owner_pump_agreed_auto=TRUE
			FROM (				
			WITH
				mon AS (
					SELECT
						CASE WHEN extract('month' FROM now())=1 THEN 12
							ELSE extract('month' FROM now())-1
						END AS v
				),
				d_from AS (
					SELECT (
						(CASE WHEN (SELECT v FROM mon)=12 THEN extract('year' FROM now())-1 ELSE extract('year' FROM now()) END)::text
						||'-'|| (CASE WHEN (SELECT v FROM mon)<10 THEN '0' ELSE '' END )||(SELECT v FROM mon) ||'-01'
					)::date+
					const_first_shift_start_time_val()
					AS v
				),
				per AS (SELECT	
					(SELECT v FROM d_from) AS d_from,
					get_shift_end(
						((SELECT v FROM d_from) + '1 month'::interval -'1 day'::interval)::date+
						const_first_shift_start_time_val()
					)
					AS d_to
				)
			SELECT shipments.id AS ship_id
			FROM shipments
			WHERE 
				extract('day' FROM now())>const_vehicle_owner_accord_to_day_val()
				AND coalesce(owner_pump_agreed,FALSE)=FALSE
				AND ship_date_time BETWEEN (SELECT d_from FROM per) AND (SELECT d_to FROM per)
			) AS sub
			WHERE sub.ship_id = shipments.id"
		);
	
	}
	
	public function get_shipped_vihicles_list($pm){	
		$this->modelGetList(new ShippedVehicleList_Model($this->getDbLink()),$pm);
	}
	
	public function update($pm){
		parent::update($pm);
		
		if($pm->getParamValue("order_id")){
			//сменили заявку
			$sms_res_ok = 0;
			$sms_res_str = '';
			self::sendShipSMS(
				$this->getDbLinkMaster(),
				$this->getDbLink(),
				$this->getExtDbVal($pm,"old_id"),
				$sms_res_ok,
				$sms_res_str,
				TRUE
			);
			
		}
		
	}
}
?>