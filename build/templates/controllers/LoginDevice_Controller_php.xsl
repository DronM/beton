<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'LoginDevice'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(USER_CONTROLLERS_PATH.'User_Controller.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public function switch_banned($pm){
		$conn = $this->getDbLinkMaster();
		if ($pm->getParamValue('banned')=='1'){
			try{
				$ar = $conn->query_first(sprintf(
					"SELECT
						session_id
						,pub_key
					FROM logins
					WHERE user_id=%d
					AND md5(headers_j->>'User-Agent')=%s
					AND date_time_out IS NULL"
					,$this->getExtDbVal($pm,'user_id')
					,$this->getExtDbVal($pm,'hash')
				));
				
				if(is_array($ar) &amp;&amp; count($ar) &amp;&amp; isset($ar['session_id'])){
					$conn->query('BEGIN');
					//kill session
					$conn->query(sprintf(
						"DELETE FROM sessions WHERE id='%s'"
						,$ar['session_id']
					));
					
					$conn->query(sprintf(
						"INSERT INTO login_device_bans (user_id,hash) VALUES (%d,%s)"
						,$this->getExtDbVal($pm,'user_id')
						,$this->getExtDbVal($pm,'hash')
					));
					
					$conn->query('COMMIT');
					
					//Send event!!!
					//deleted from logins after delete!!!
					//User_Controller::closeConnection($conn,trim($ar['pub_key']));
				}
			}
			catch(Exception $e){
				$conn->query('ROLLBACK');
				throw new Exception($e);
			}			
		}
		else{
			$conn->query(sprintf(
				"DELETE FROM login_device_bans
				WHERE user_id=%d AND hash=%s"
				,$this->getExtDbVal($pm,'user_id')
				,$this->getExtDbVal($pm,'hash')
			));
		}
	}

</xsl:template>

</xsl:stylesheet>
