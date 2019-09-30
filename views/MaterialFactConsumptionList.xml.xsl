<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="xml"/>

<xsl:key name="raw_material_production_descrs" match="document/model[@id='MaterialFactConsumptionList_Model']/row" use="raw_material_production_descr/."/>
<xsl:key name="shipments" match="document/model[@id='MaterialFactConsumptionList_Model']/row" use="concat(date_time/.,'|',production_sites_ref/.)"/>

<!-- Main template-->
<xsl:template match="/">
	<document>
		<xsl:copy-of select="document/model[@id='ModelServResponse']"/>
		<model id="MaterialFactConsumptionList_Model" sysModel="0" rowsPerPage="{document/model[@id='MaterialFactConsumptionList_Model']/@rowsPerPage}" listFrom="0" totalCount="{document/model[@id='MaterialFactConsumptionList_Model']/@totalCount}" browseMode="0" browseId="0">
			<xsl:apply-templates select="document/model[@id='MaterialFactConsumptionList_Model']"/>
		</model>
	</document>
</xsl:template>

<xsl:template match="model[@id='MaterialFactConsumptionList_Model']">
	<xsl:for-each select="//row[generate-id() =
	generate-id(key('shipments',concat(date_time/.,'|',production_sites_ref/.))[1])]">
		<xsl:sort select="date_time/."/>
		<xsl:variable name="total_concrete_quant" select="sum(key('shipments',concat(date_time/.,'|',production_sites_ref/.))/concrete_quant/.)"/>
		<xsl:variable name="date_time" select="date_time/."/>

		<row ind="{position()}">
			<field><xsl:value-of select="$date_time"/>
			</field>
		</row>	
	</xsl:for-each>	
</xsl:template>

</xsl:stylesheet>
