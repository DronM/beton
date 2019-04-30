<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'EmployeeWorkTimeSchedule'"/>
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
require_once('common/MyDate.php');

class <xsl:value-of select="@id"/>_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	public function get_list($pm){
		$db_link = $this->getDbLink();
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		if($cond->paramExists('day','ge') &amp;&amp; $cond->paramExists('day','le')){
			$date_from = $cond->getVal('day','ge');
			$date_to = $cond->getVal('day','le');
		}
		else{
			$date_from = date('Y-m-d',MyDate::StartMonth(time()));
			$date_to = date('Y-m-d',MyDate::EndMonth(time()));
		}					
		
		//init date
		$this->addModel(new ModelVars(
			array('id'=>'InitDate',
				'values'=>array(
					new Field('dt',DT_DATETIME,
						array('value'=>$date_from))
				)
			)
		));		
		
		$this->addNewModel(sprintf(
		"SELECT * FROM employee_work_time_schedules_list('%s','%s')",
		$date_from,
		$date_to
		),
		'EmployeeWorkTimeScheduleList_Model');
	}
</xsl:template>

</xsl:stylesheet>
