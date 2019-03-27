<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'OrderPump'"/>
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

class <xsl:value-of select="@id"/>_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">
	private function upsert($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();
		$this->getDbLinkMaster()->query(sprintf(
		"SELECT order_pumps_set((%d,%s,%s)::order_pumps)",
			$params->getDbVal('old_order_id'),
			$params->getDbVal('viewed'),
			$params->getDbVal('comment')		
		));
	}

	public function insert($pm){
		$this->upsert($pm);
	}
	public function update($pm){
		$this->upsert($pm);
	}	
</xsl:template>

</xsl:stylesheet>