<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="html"/> 


<!-- Main template-->
<xsl:template match="/">
	<xsl:choose>
		<xsl:when test="not(document/model[@id='ModelServResponse']/row[1]/result='0')">
		<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>	
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="document/model[@id='driver_cheat_report']"/>	
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- Error -->
<xsl:template match="model[@id='ModelServResponse']">
	<div class="error">
		<xsl:value-of select="row[1]/descr"/>
	</div>
</xsl:template>

<!-- table -->
<xsl:template match="model">
	<xsl:variable name="model_id" select="@id"/>	
	<table id="{@model_id}" class="table table-bordered table-responsive table-striped">
		<thead>
			<tr>
				<th class="invisible"></th>
				<th>ТС</th>
				<th class="invisible"></th>
				<th>Водитель</th>
				<th class="invisible"></th>
				<th>Объект</th>
				<th>Дата поездки на объект</th>
				<th>Дата поездки по самовывозу</th>
			</tr>
		</thead>
	
		<tbody>
			<xsl:apply-templates/>
		</tbody>
	</table>
</xsl:template>

<!-- table header -->

<!-- header field -->

<!-- table row -->
<xsl:template match="row">
	<tr>
		<xsl:apply-templates/>
	</tr>
</xsl:template>

<!-- table cell -->
<xsl:template match="row/*">
	<td align="center">
		<xsl:value-of select="node()"/>
	</td>
</xsl:template>

</xsl:stylesheet>
