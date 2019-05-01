<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="html"/> 

<!-- Main template-->
<xsl:template match="/">
	<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>	
	<xsl:apply-templates select="document/model[@id='ModelVars']"/>	
	<xsl:apply-templates select="document/model[@id='lab_avg_report']"/>
	<xsl:apply-templates select="document/model[@id='Chart_Model']"/>
</xsl:template>

<!-- Error -->
<xsl:template match="model[@id='ModelServResponse']">
	<xsl:if test="not(row[1]/result='0')">
	<div class="error">
		<xsl:value-of select="row[1]/descr"/>
	</div>
	</xsl:if>
</xsl:template>

<!-- table -->
<xsl:template match="model[@id='lab_avg_report']">
	<table id="{@id}" class="table table-bordered table-responsive table-striped">
		<thead>
			<th field_id="concrete_type_id">Код</th>
			<th field_id="concrete_type_descr">Наименование</th>
			<th field_id="date_descr">Дата</th>
			<th field_id="val">Значение</th>
		</thead>
		<tbody>
		<xsl:apply-templates select="row"/>		
		</tbody>
	</table>
</xsl:template>

<!-- table header -->
<xsl:template match="model[@id='ModelVars']/row">
	<div class="rep_head">
		<div>Период с:<xsl:value-of select="date_from"/> по <xsl:value-of select="date_to"/></div>
		<div>Показатель:<xsl:value-of select="item_type"/></div>
		<div>Дней для средних значений:<xsl:value-of select="cnt"/></div>
		<div>По материалам:<xsl:value-of select="concr_descrs"/></div>
	</div>
</xsl:template>

<!-- header field -->

<!-- table row -->
<xsl:template match="row">
	<tr>
		<td align="center">
			<xsl:value-of select="concrete_type_id"/>
		</td>
		<td align="left">
			<xsl:value-of select="concrete_type_descr"/>
		</td>		
		<td align="center">
			<xsl:value-of select="date_descr"/>
		</td>
		<td align="center">
			<xsl:value-of select="val"/>
		</td>
		
	</tr>
</xsl:template>

<!-- table cell -->
<xsl:template match="row/*">
	<td align="center">
		<xsl:value-of select="node()"/>
	</td>
</xsl:template>

<xsl:template match="model[@id='Chart_Model']">
	<img src="data:{row/mime};base64,{row/img}"></img>
</xsl:template>

</xsl:stylesheet>
