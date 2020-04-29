<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">
 
<xsl:import href="ModelsToHTML.html.xsl"/>
<xsl:import href="functions.xsl"/>

<xsl:template match="/">
	<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>
	<xsl:apply-templates select="document/model[@id='Head_Model']"/>
	<xsl:apply-templates select="document/model[@id='MaterialActionList_Model']"/>				
</xsl:template>

<!-- Head -->
<xsl:template match="model[@id='Head_Model']">
	<h3>Отчет по материалам за период <xsl:value-of select="row/period_descr"/></h3>
	
</xsl:template>

<xsl:template match="model[@id='MaterialActionList_Model']">
	<xsl:variable name="model_id" select="@id"/>
	
	<table id="{$model_id}" class="tabel table-bordered table-striped">
		<thead>
			<tr align="center">
				<td>Материал</td>
				<td>Начальный остаток</td>
				<td>Приход</td>
				<td>Расход</td>
				<td>Конечный остаток</td>
			</tr>
		</thead>
	
		<tbody>
			<xsl:apply-templates/>
		</tbody>
		
	</table>
</xsl:template>

<xsl:template match="row">
	<tr>
		<td><xsl:value-of select="material_name"/></td>		
		<td align="right">
			<xsl:call-template name="format_quant">
				<xsl:with-param name="val" select="quant_start"/>
			</xsl:call-template>																									
		</td>				
		<td align="right">
			<xsl:call-template name="format_quant">
				<xsl:with-param name="val" select="quant_deb"/>
			</xsl:call-template>																									
		</td>				
		<td align="right">
			<xsl:call-template name="format_quant">
				<xsl:with-param name="val" select="quant_kred"/>
			</xsl:call-template>																									
		</td>				
		<td align="right">
			<xsl:call-template name="format_quant">
				<xsl:with-param name="val" select="quant_end"/>
			</xsl:call-template>																									
		</td>				
		
	</tr>
</xsl:template>

</xsl:stylesheet>
