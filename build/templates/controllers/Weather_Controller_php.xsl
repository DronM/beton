<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Weather'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once('common/WeatherForeca.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public static function update_data($dbLink,&amp;$content,&amp;$contentDetails,&amp;$updateDate){
		$w = new WeatherForeca();
		$w->getForcast();
		
		$content = 'NULL';
		FieldSQLString::formatForDb($dbLink,$w->getContent(),$content);
		$contentDetails = 'NULL';
		FieldSQLString::formatForDb($dbLink,$w->getContentDetails(),$contentDetails);
		
		$dbLink->query("BEGIN");
		try{
			$ar = $dbLink->query_first(sprintf(
			"SELECT weather_update(%s,%s)",
			$content,
			$contentDetails
			));
			
			$dbLink->query("COMMIT");
			
			$updateDate = $ar['weather_update'];
		}
		catch (Exception $e) {
			$dbLink->query("ROLLBACK");
			throw $e;
		}
	}

	public static function getCurrentModel($dbLink,$dbLinkMaster){
		$ar = $dbLink->query_first(
		"SELECT
			weather.*,
			(round(date_part('epoch',now()::timestamp-weather.update_dt))>=EXTRACT(epoch FROM const_weather_update_interval_sec_val()::interval)) AS need_update
		FROM weather
		LIMIT 1");
		
		$content = '';
		$content_details = '';
		$update_dt = '';
		if(!is_array($ar) || !count($ar) || $ar['need_update']=='t'){
			self::update_data($dbLinkMaster,$content,$content_details,$update_dt);
		}
		else{
			$content = $ar['content'];
			$content_details = $ar['content_details'];
			$update_dt = $ar['update_dt'];
		}
		
		$fields = array();		
		array_push($fields,new Field('content',DT_STRING,array('value'=>$content)));
		array_push($fields,new Field('content_details',DT_STRING,array('value'=>$content_details)));
		array_push($fields,new Field('update_dt',DT_STRING,array('value'=>$update_dt)));				
		
		return new ModelVars(array('id'=>'Weather_Model','values'=>$fields));		
	}
	
	public function get_current($pm){
		$this->addModel(self::getCurrentModel($this->getDbLink(),$this->getDbLinkMaster()));
	}

</xsl:template>

</xsl:stylesheet>
