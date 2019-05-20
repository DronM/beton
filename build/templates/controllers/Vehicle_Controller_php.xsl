<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Vehicle'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>
require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once('common/SMSService.php');
class <xsl:value-of select="@id"/>_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}
	
	public function get_vehicle_statistics($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('date',DT_DATE);
		$this->addNewModel(vsprintf(
			'SELECT * FROM get_vehicle_statistics(%s)',
			$params->getArray()),
			'get_vehicle_statistics'
		);
	}
	public function check_for_broken_trackers(){
		$dbLink = $this->getDbLink();
		$ar = $dbLink->query_first(
			'SELECT * FROM check_for_broken_trackers()'
		);
		if ($ar){			
			$sms_service = new SMSService(SMS_LOGIN, SMS_PWD);
			$sms_id_resp = $sms_service->send($ar['cel_phone'],
				$ar['sms_text'],SMS_SIGN,SMS_TEST);
			$sms_id = NULL;
			FieldSQLString::formatForDb($this->getDbLinkMaster(),$sms_id_resp,$sms_id);
			$dbLink->query(sprintf(
			'INSERT INTO sms_trackers_service (mes_id,mes_text,date_time)
				VALUES(%s,%s,now())',
			$sms_id,$ar['sms_text']
			));
		}
	}
	public function complete_owners($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('owner',DT_STRING);
		$this->addNewModel(vsprintf(
			"SELECT * FROM vehicle_owner_list_view
			WHERE lower(owner) LIKE '%%'||%s||'%%'",
			$params->getArray()),
			'VehicleOwnerList_Model'
		);
	}
	public function complete_features($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('feature',DT_STRING);
		$this->addNewModel(vsprintf(
			"SELECT * FROM vehicle_feature_list_view
			WHERE lower(feature) LIKE '%%'||%s||'%%'",
			$params->getArray()),
			'VehicleFeatureList_Model'
		);	
	}
	public function complete_makes($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('make',DT_STRING);
		$this->addNewModel(vsprintf(
			"SELECT * FROM vehicle_make_list_view
			WHERE lower(make) LIKE '%%'||%s||'%%'",
			$params->getArray()),
			'VehicleMakeList_Model'
		);	
	}
	public function vehicles_with_trackers($pm){
		$this->addNewModel(
			sprintf(
				"SELECT 0 AS id,'*** ВСЕ ***' AS plate
				UNION ALL
				(SELECT id,plate FROM vehicles
				WHERE tracker_id IS NOT NULL AND tracker_id &lt;&gt;''%s
				ORDER BY plate)",
				($_SESSION['role_id']=='vehicle_owner')? sprintf(' AND vehicles.vehicle_owner_id=%d',$_SESSION['global_vehicle_owner_id']):''
			),
			'vehicles_with_trackers'
		);		
	}
	public function get_tracker_inf($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('id',DT_INT);	
		
		$cond = ($_SESSION['role_id']=='vehicle_owner')? sprintf(' AND vehicles.vehicle_owner_id=%d',$_SESSION['global_vehicle_owner_id']):'';
		$this->addNewModel(
			vsprintf(
				"SELECT
				date5_time5_descr(recieved_dt+age(now(),now() at time zone 'UTC')) AS recieved_dt_str
				FROM car_tracking
				LEFT JOIN vehicles ON vehicles.tracker_id=car_tracking.car_id
				WHERE vehicles.id=%d".$cond."
				ORDER BY period DESC LIMIT 1",
				$params->getArray()				
			),
			'get_tracker_inf'
		);		
	}
	
	public function get_current_position($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->setValidated('id',DT_INT);	
		
		$vehicle_id = $this->getExtDbVal($pm,'id');
		if($_SESSION['role_id']=='vehicle_owner'){
			$ar = $this->getDbLink()->query_first(sprintf("SELECT vehicle_owner_id FROM vehicles WHERE id=%d",$vehicle_id));
			if(!is_array($ar) ||!count($ar) || $ar['vehicle_owner_id']!=$_SESSION['global_vehicle_owner_id']){
				throw new Exception('Permission denied!');
			}
		}
		
		//zones
		$cond = ($_SESSION['role_id']=='vehicle_owner')? sprintf(' AND vs.vehicle_id IN (SELECT vv.id FROM vehicles vv WHERE vv.id=%d)',$_SESSION['global_vehicle_owner_id']):'';
		$this->addNewModel(
		vsprintf("SELECT 
			(SELECT replace(replace(st_astext(d.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text)
			FROM destinations AS d
			WHERE d.id=constant_base_geo_zone_id()
			) AS base,	
			
			CASE 		
			WHEN st.state IN ('at_dest'::vehicle_states,'left_for_base'::vehicle_states) THEN
			(SELECT replace(replace(st_astext(d.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text)
				FROM destinations AS d
				WHERE d.id=st.destination_id
			)	
			
			WHEN st.state ='busy'::vehicle_states THEN
			(SELECT replace(replace(st_astext(d.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text)
				FROM destinations AS d
				LEFT JOIN shipments AS sh ON sh.id=st.shipment_id
				LEFT JOIN orders AS o ON o.id=sh.order_id
				WHERE d.id=o.destination_id
			)
			ELSE null
			END AS dest
			
			FROM vehicle_schedule_states AS st
			LEFT JOIN vehicle_schedules AS vs ON vs.id=st.schedule_id
			WHERE vs.vehicle_id=%d AND st.date_time &lt; now()".$cond."
			ORDER BY st.date_time DESC
			LIMIT 1",
			$params->getArray()			
		),
		'zones'
		);
		
		//position
		$this->addNewModel(
			sprintf(
				"SELECT * FROM vehicle_current_pos_all
				WHERE id=%d",
				$vehicle_id
			),
			'get_current_position'
		);
	}
	public function get_current_position_all($pm){
		//zones
		$this->addNewModel(
		"SELECT 
			replace(
				replace(st_astext(d.zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text
			) AS base
		FROM destinations AS d
		WHERE d.id=constant_base_geo_zone_id()",
		'zones');
		
		//position
		if($_SESSION['role_id']=='vehicle_owner'){
			$q = sprintf(
				"SELECT * FROM vehicle_current_pos_all WHERE id IN (SELECT t.id FROM vehicles t WHERE t.vehicle_owner_id=%d)",
				$_SESSION['global_vehicle_owner_id']
			);
		}
		else{
			$q = "SELECT * FROM vehicle_current_pos_all";
		}
		
		$this->addNewModel($q,'get_current_position');		
	}
	
	public function get_track($pm){
		$link = $this->getDbLink();
		
		if($_SESSION['role_id']=='vehicle_owner'){
			$ar = $link->query_first(sprintf("SELECT vehicle_owner_id FROM vehicles WHERE id=%d",$this->getExtDbVal($pm,'id')));
			if(!is_array($ar) ||!count($ar) || $ar['vehicle_owner_id']!=$_SESSION['global_vehicle_owner_id']){
				throw new Exception('Permission denied!');
			}
		}
		
		$this->addNewModel(
		sprintf(
		"SELECT
			(
				SELECT
				replace(replace(st_astext(zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text) AS coords
				FROM destinations
				WHERE id=constant_base_geo_zone_id()
			) AS base,
			NULL AS dest
		UNION ALL
		SELECT
			NULL AS base,
			replace(replace(st_astext(zone), 'POLYGON(('::text, ''::text), '))'::text, ''::text) AS dest
			FROM vehicle_schedule_states AS st
			LEFT JOIN vehicle_schedules AS vs ON vs.id=st.schedule_id
			LEFT JOIN vehicles AS v ON v.id=vs.vehicle_id
			LEFT JOIN destinations AS dest ON dest.id=st.destination_id
			WHERE v.id=%d
			AND st.date_time BETWEEN %s AND %s
			AND st.state='busy'::vehicle_states",
		$this->getExtDbVal($pm,'id'),
		$this->getExtDbVal($pm,'dt_from'),
		$this->getExtDbVal($pm,'dt_to')
		),
		'zones'
		);
		//track
		$this->addNewModel(sprintf(
			"SELECT * FROM vehicle_track_with_stops(%d,%s,%s,%s)",
			$this->getExtDbVal($pm,'id'),
			$this->getExtDbVal($pm,'dt_from'),
			$this->getExtDbVal($pm,'dt_to'),
			$this->getExtDbVal($pm,'stop_dur')
			),
			'track_data'
		);				
	}
	public function get_tool_tip($pm){
		$link = $this->getDbLink();
		
		$ar = $link->query_first(sprintf(
		"SELECT
			date8_time5_descr(current_coord_date_time::timestamp without time zone) AS dt,
			current_coord[1] AS cur_lat,
			current_coord[2] AS cur_lon,		
			coord[1][1] AS lat_min,coord[1][2] AS lat_max,
			coord[2][1] AS lon_min,coord[2][2] AS lon_max,
			descr
		FROM vehicle_current_heading(%d)
		AS (current_coord float[],current_coord_date_time timestamp,
		coord float[],descr text)",
		$this->getExtDbVal($pm,'id')
		));
		$res = '';
		if ($ar){
			$res = '&lt;div&gt;трэкер:'.$ar['dt'].'&lt;/div&gt;';
			if ($ar['descr']=='to_base' ||
			$ar['descr']=='to_dest'){
				$km = 'xx';
				$t = ($ar['descr']=='to_base')? 'до базы:':'до объекта:';
				$res.=sprintf('&lt;div&gt;%s%s км.&lt;/div&gt;',$t,$km);
			}
		}
		echo $res;
	}
	public function get_stops_at_dest($pm){
		$link = $this->getDbLink();
		$model = new ModelSQL($link,array("id"=>"get_stops_at_dest"));
		$model->addField(new FieldSQLDateTime($link,null,null,"date_time",DT_DATETIME));
		$model->addField(new FieldSQLInt($link,null,null,"destination_id",DT_INT));
		$model->addField(new FieldSQLInt($link,null,null,"vehicle_id",DT_INT));
		$model->addField(new FieldSQLString($link,null,null,"stop_dur",DT_TIME));
		
		$where = $this->conditionFromParams($pm,$model);
		$from = null;
		$to = null;
		$destination_id = 0;
		$vehicle_id = 0;
		$vehicle_owner_id = 0;
		$stop_dur = "'00:05'";
		
		foreach($where->fields as $w_field){
			$id = $w_field['field']->getId();
			if ($id=='date_time'){
				if ($w_field['signe']=='&gt;='){
					$from = $w_field['field']->getValueForDb();
				}
				else{
					$to = $w_field['field']->getValueForDb();
				}
			}
			else if ($id=='destination_id'){
				$destination_id = $w_field['field']->getValueForDb();
			}
			else if ($id=='vehicle_id'){
				$vehicle_id = $w_field['field']->getValueForDb();
			}			
			else if ($id=='stop_dur'){
				$stop_dur = $w_field['field']->getValueForDb();
			}			
		}
		
		if($_SESSION['role_id']=='vehicle_owner' &amp;&amp; $vehicle_id){
			$ar = $link->query_first(sprintf("SELECT vehicle_owner_id FROM vehicles WHERE id=%d",$vehicle_id));
			if(!is_array($ar) ||!count($ar) || $ar['vehicle_owner_id']!=$_SESSION['global_vehicle_owner_id']){
				throw new Exception('Permission denied!');
			}
			$vehicle_owner_id = $_SESSION['global_vehicle_owner_id'];
		}
				
		$model->setSelectQueryText(
		sprintf(
		"SELECT * FROM vehicles_at_destination(%s,%s,%d,%d,%s::interval,%d)",
		$from,$to,$destination_id,$vehicle_id,$stop_dur,$vehicle_owner_id));
		
		$model->select(false,null,null,
			null,null,null,null,null,TRUE);
		//
		$this->addModel($model);				
	}	
}
<![CDATA[?>]]>
</xsl:template>

</xsl:stylesheet>
