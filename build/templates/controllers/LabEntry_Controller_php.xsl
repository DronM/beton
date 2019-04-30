<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'LabEntry'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>
require_once(FRAME_WORK_PATH.'basic_classes/CondParamsSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');

include("common/pChart2.1.3/class/pData.class.php");
include("common/pChart2.1.3/class/pDraw.class.php");
include("common/pChart2.1.3/class/pImage.class.php");

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}
	public function modelGetList(ModelSQL $model,$pm=null){
		$this->beforeSelect();
		if (is_null($pm)){
			$pm = $this->getPublicMethod(ControllerDb::METH_GET_LIST);		
		}
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
		$id_ar = $where->getFieldsById('id','IS NOT');
		if (is_array($id_ar) &amp;&amp; count($id_ar)){
			if ($id_ar[0]->getValue()==0){
				$where->deleteField('id','IS NOT');
			}
			else{
				$id_ar[0]->setValue(NULL);
			}
		}
		$fields = $this->fieldsFromParams($pm);		
		$grp_fields = $this->grpFieldsFromParams($pm);		
		$agg_fields = $this->aggFieldsFromParams($pm);		
			
		$browse_mode = $pm->getParamValue('browse_mode');
		if (!isset($browse_mode)){
			$browse_mode = BROWSE_MODE_VIEW;
		}
		$model->setBrowseMode($browse_mode);
			
		$is_insert = ($browse_mode==BROWSE_MODE_INSERT);
		$model->select($is_insert,$where,$order,
			$limit,$fields,$grp_fields,$agg_fields,
			$calc_total,TRUE);
		//
		$this->addModel($model);
		
		$this->afterSelect();	
	}
	public function lab_report($pm){
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		$this->addNewModel(sprintf('SELECT * FROM lab_entry_report(%s,%s)',
		$cond->getValForDb('date_time','ge',DT_DATETIME),
		$cond->getValForDb('date_time','le',DT_DATETIME)),
		'lab_report');
	}
	public function item_report($pm){
		//report conditions
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		//
		$item_types = array(
			'ok'=>array('ind'=>0,'descr'=>'OK'),
			'weight'=>array('ind'=>1,'descr'=>'вес'),
			'p7'=>array('ind'=>2,'descr'=>'p7'),
			'p28'=>array('ind'=>3,'descr'=>'p28'),
			'cnt'=>array('ind'=>4,'descr'=>'Кол-во')
			);
		$k = $cond->getVal('item_type','e',DT_STRING);
		if (!array_key_exists($k,$item_types)){
			throw new Exception('Item not found '.$k);
		}
		
		//head
		$this->addModel(new ModelVars(
			array('values'=>array(
				new Field('date_from',DT_STRING,
					array('value'=>$cond->getVal('date_time','ge'))),
				new Field('date_to',DT_STRING,
					array('value'=>$cond->getVal('date_time','le'))),
				new Field('cnt',DT_STRING,
					array('value'=>$cond->getVal('cnt','e'))),
				new Field('item_type',DT_STRING,
					array('value'=>$item_types[$k]['descr'])),			
				)			
			))
			);
		
		//data		
		$this->addNewModel(sprintf('SELECT * FROM lab_item_report(%s,%s,%d,%d)',
		$cond->getValForDb('date_time','ge',DT_DATETIME),
		$cond->getValForDb('date_time','le',DT_DATETIME),
		$cond->getValForDb('cnt','e',DT_INT),
		$item_types[$k]['ind']
		),
		'lab_report');
	}
	public function item_on_rate_period_report($pm){
		//report conditions
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		//
		$item_types = array(
			'ok'=>array('ind'=>0,'descr'=>'OK'),
			'weight'=>array('ind'=>1,'descr'=>'вес'),
			'p7'=>array('ind'=>2,'descr'=>'p7'),
			'p28'=>array('ind'=>3,'descr'=>'p28'),
			'cnt'=>array('ind'=>4,'descr'=>'Кол-во')
			);
		$k = $cond->getVal('item_type','e',DT_STRING);
		if (!array_key_exists($k,$item_types)){
			throw new Exception('Item not found '.$k);
		}
		
		//head
		$this->addModel(new ModelVars(
			array('values'=>array(
				new Field('date_from',DT_STRING,
					array('value'=>$cond->getVal('date_time','ge'))),
				new Field('date_to',DT_STRING,
					array('value'=>$cond->getVal('date_time','le'))),
				new Field('cnt',DT_STRING,
					array('value'=>$cond->getVal('cnt','e'))),
				new Field('item_type',DT_STRING,
					array('value'=>$item_types[$k]['descr'])),			
				)			
			))
			);
		
		//data		
		$this->addNewModel(sprintf('SELECT * FROM lab_item_on_rate_period_report(%s,%s,%d,%d)',
		$cond->getValForDb('date_time','ge',DT_DATETIME),
		$cond->getValForDb('date_time','le',DT_DATETIME),
		$cond->getValForDb('cnt','e',DT_INT),
		$item_types[$k]['ind']
		),
		'lab_report');
	}
	
	private function insert_update($pm,$insert){
		$link = $this->getDbLinkMaster();
		$params = new ParamsSQL($pm,$link);
		$params->addAll();
		$pref = (!$insert)? 'old_':'';
		
		$link->query(sprintf(
		"SELECT lab_entry_update(
			%d,%s,%s,%s,%s)",
			$params->getParamById($pref.'shipment_id'),
			$params->getParamById('samples'),
			$params->getParamById('materials'),
			$params->getParamById('ok2'),
			$params->getParamById('time')
		));
	}
	public function insert($pm){
		$this->insert_update($pm,TRUE);
	}
	public function update($pm){
		$this->insert_update($pm,FALSE);
	}	
	public function lab_entry30_days($pm){
		$this->addNewModel('SELECT * FROM lab_entry_30days_2',
		'lab_entry30_days');
	}	
	public function lab_vehicle_list($pm){
		$this->addNewModel('SELECT * FROM lab_cur_vehicle_list',
		'lab_vehicle_list');
	}	
	public function lab_orders_list($pm){
		$this->addNewModel('SELECT * FROM lab_orders_list',
		'lab_orders_list');

	}	
	
	public function lab_avg_report_data($cond,&amp;$concrTypes=NULL){
		$item_type = $cond->getVal('item_type','e',DT_STRING);
		$item_types = array('ok','weight','p7','p28','cnt');
		if (!in_array($item_type,$item_types)){
			throw new Exception('Не определен показатель!');
		}
		
		$link = $this->getDbLink();
		$q_id = $link->query('SELECT id,name FROM concrete_types_for_lab_list');
		$concr_types = '';
		$concr_descrs = '';
		while ($ar=$link->fetch_array($q_id)){
			$id = 'concrete_type_id_'.$ar['id'];
			if ($cond->getVal($id,'in',DT_BOOL)=='true'){
				$concr_types.=($concr_types=='')? '':',';
				$concr_types.=$ar['id'];
				
				$concr_descrs.=($concr_descrs=='')? '':', ';
				$concr_descrs.=$ar['name'];
				
				if (!is_null($concrTypes)){
					$concrTypes[$ar['id']] = array(
						'name'=>$ar['name'],
						'vals'=>array()
					);
				}
			}
		}
		
		if ($concr_types==''){
			throw new Exception('Не выбрана ни одна марка!');
		}
		
		//head
		/*
		$this->addModel(new ModelVars(
			array('values'=>array(
				new Field('date_from',DT_STRING,
					array('value'=>$cond->getVal('date_time','ge'))),
				new Field('date_to',DT_STRING,
					array('value'=>$cond->getVal('date_time','le'))),
				new Field('cnt',DT_STRING,
					array('value'=>$cond->getVal('cnt','e'))),
				new Field('concr_descrs',DT_STRING,
					array('value'=>$concr_descrs)),			
				)			
			))
		);		
		*/
		return sprintf(
		"SELECT
			concrete_type_id,
			concrete_type_descr,
			shipment_date AS date,
			date8_descr(shipment_date) AS date_descr,
			ROUND(%s,2) AS val
		FROM lab_avg_vals_report(%s,%s,%d,%s)",
		$item_type,
		$cond->getValForDb('date_time','ge',DT_DATETIME),
		$cond->getValForDb('date_time','le',DT_DATETIME),
		$cond->getValForDb('cnt','e',DT_INT),
		'ARRAY['.$concr_types.']'
		);
	}
	private function lab_avg_report_table($cond){
		$q = $this->lab_avg_report_data($cond);
		$this->addNewModel($q,'lab_avg_report');
	}
	
	private function lab_avg_report_chart($cond){
		$concr_types = array();
		$q = $this->lab_avg_report_data($cond,$concr_types);
		
		$MyData = new pData();
		$chart_dates = array();
		$max_val = 0;
		
		$l = $this->getDbLink();
		$q_id = $l->query($q);
		
		while ($ar=$l->fetch_array($q_id)){
			array_push(
				$concr_types[
					$ar['concrete_type_id']
				]['vals'],
				$ar['val']
			);
			array_push($chart_dates,$ar['date']);
			if ($max_val&lt;$ar['val']){
				$max_val = $ar['val'];
			}			
		}
		
		foreach($concr_types as $concr_type){
			$MyData->addPoints($concr_type['vals'],$concr_type['name']);
			$MyData->setSerieWeight($concr_type['name'],1); 
		}
		$MyData->setAxisName(0,"показатели");		
		$MyData->addPoints($chart_dates,"Даты");
		$MyData->setAbscissa("Даты");
		$MyData->setXAxisName("дата");
		//$MyData->setXAxisDisplay(AXIS_FORMAT_DATE,"d/m/Y");
		/* Create the pChart object */
		$myPicture = new pImage(1099,500,$MyData);

		/* Turn of AAliasing */
		$myPicture->Antialias = TRUE;
		/* Draw the border */
		$myPicture->drawRectangle(0,0,1100,499,array("R"=>0,"G"=>0,"B"=>0));

		$myPicture->setFontProperties(array("FontName"=>FONT_FILE,"FontSize"=>6));
		
		$myPicture->drawText(30,20,
			$cond->getVal('date_time','ge').'-'.$cond->getVal('date_time','le'),
			array("FontSize"=>12));
		
		/* Define the chart area */
		$myPicture->setGraphArea(25,15,1180,450);//170
		/* Draw the scale */
		//$scaleSettings = array("XMargin"=>0,"YMargin"=>0,"Floating"=>TRUE,"GridR"=>200,"GridG"=>200,"GridB"=>200,"DrawSubTicks"=>TRUE,"CycleBackground"=>TRUE);
		//$myPicture->drawScale($scaleSettings);
		$AxisBoundaries = array(0=>array("Min"=>0,"Max"=>$max_val+20));
		$ScaleSettings  = array("Mode"=>SCALE_MODE_MANUAL,
			"ManualScale"=>$AxisBoundaries,
			"DrawSubTicks"=>TRUE,"DrawArrows"=>TRUE,
			"ArrowSize"=>6
			);//"LabelSkip"=>1
		$myPicture->drawScale($ScaleSettings); 		

		/* Draw the step chart */
		//$myPicture->drawStepChart();
		$Config = array("BreakVoid"=>FALSE);
		$myPicture->drawLineChart($Config);
		//array("DisplayColor"=>DISPLAY_MANUAL,"DisplayR"=>0,"DisplayG"=>0,"DisplayB"=>0)

		/* Write the chart legend */
		$myPicture->drawLegend(590,17,array("Style"=>LEGEND_NOBORDER,"Mode"=>LEGEND_HORIZONTAL));

		/* Render the picture (choose the best way) */
		ob_start();
		$myPicture->stroke();
		$contents = ob_get_contents();
		ob_end_clean();				
		
		$this->addModel(new ModelVars(
			array('name'=>'image',
				'id'=>'Chart_Model',
				'values'=>array(
					new Field('mime',DT_STRING,
						array('value'=>'image/png')),				
					new Field('img',DT_STRING,
						array('value'=>base64_encode($contents)))
					)
				)
			)
		);
		
		//$myPicture->render('d:\test.jpg');
		
	}	
	public function lab_avg_report($pm){
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		if ($cond->getVal('report_type','e')=='table'){
			$this->lab_avg_report_table($cond);
		}
		else if ($cond->getVal('report_type','e')=='chart'){
			$this->lab_avg_report_chart($cond);
		}
		else{
			throw new Exception("Unknown report type!");
		}
	}
	
}
<![CDATA[?>]]>	
</xsl:template>

</xsl:stylesheet>