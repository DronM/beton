<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'ProductionComment'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>
class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public function insert($pm){
		$this->getDbLinkMaster()->query(sprintf(
			"INSERT INTO production_comments
			(production_site_id,production_id,material_id,comment_text,date_time,user_id)
			VALUES
			(%d,%d,%d,%s,now(),%d)
			ON CONFLICT (production_site_id,production_id,material_id) DO UPDATE SET
				comment_text = %s,
				date_time = now(),
				user_id = %d"
			,$this->getExtDbVal($pm,'production_site_id')
			,$this->getExtDbVal($pm,'production_id')
			,$this->getExtDbVal($pm,'material_id')
			,$this->getExtDbVal($pm,'comment_text')
			,$_SESSION['user_id']
			
			,$this->getExtDbVal($pm,'comment_text')
			,$_SESSION['user_id']
		));
		$inserted_id_ar = [
			'production_site_id'=>$this->getExtVal($pm,'production_site_id')
			,'production_id' => $this->getExtVal($pm,'production_id')
			,'material_id'=>$this->getExtVal($pm,'material_id')
		];
		$this->addInsertedIdModel($inserted_id_ar);
	}

</xsl:template>

</xsl:stylesheet>
