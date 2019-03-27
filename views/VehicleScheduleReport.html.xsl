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
			<xsl:apply-templates select="document/model[@id='VehicleScheduleReport_Model']"/>	
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
<xsl:template match="model[@id='VehicleScheduleReport_Model']">
	<table id="VehicleScheduleReport_Model" class="table table-bordered table-responsive table-striped">
		<!-- header -->
		<thead>
		<tr>
			<th>Дата</th>
			<th>пн</th>
			<th>вт</th>
			<th>ср</th>
			<th>чт</th>
			<th>пт</th>
			<th>сб</th>
			<th>вс</th>
		</tr>
		</thead> 
		 
		<!-- vehicles -->
		<tbody>
			<xsl:apply-templates select="row"/>	
		</tbody>
		
	</table>
</xsl:template>

<xsl:template match="model[@id='VehicleScheduleReport_Model']/row">
	<xsl:variable name="day_1">
		<xsl:choose>
			<xsl:when test="shift='1' and dow='1'"><xsl:value-of select="'on_shift'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'no_shift'"/></xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="day_2">
		<xsl:choose>
			<xsl:when test="shift='1' and dow='2'"><xsl:value-of select="'on_shift'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'no_shift'"/></xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="day_3">
		<xsl:choose>
			<xsl:when test="shift='1' and dow='3'"><xsl:value-of select="'on_shift'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'no_shift'"/></xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="day_4">
		<xsl:choose>
			<xsl:when test="shift='1' and dow='4'"><xsl:value-of select="'on_shift'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'no_shift'"/></xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="day_5">
		<xsl:choose>
			<xsl:when test="shift='1' and dow='5'"><xsl:value-of select="'on_shift'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'no_shift'"/></xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="day_6">
		<xsl:choose>
			<xsl:when test="shift='1' and dow='6'"><xsl:value-of select="'on_shift'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'no_shift'"/></xsl:otherwise>			
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="day_7">
		<xsl:choose>
			<xsl:when test="shift='1' and dow='7'"><xsl:value-of select="'on_shift'"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'no_shift'"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<tr>		
		<td><xsl:value-of select="day_descr"/></td>
		<td class="{$day_1}"><xsl:text>&#160;</xsl:text></td>
		<td class="{$day_2}"><xsl:text>&#160;</xsl:text></td>
		<td class="{$day_3}"><xsl:text>&#160;</xsl:text></td>
		<td class="{$day_4}"><xsl:text>&#160;</xsl:text></td>
		<td class="{$day_5}"><xsl:text>&#160;</xsl:text></td>
		<td class="{concat($day_6,' week_end')}"><xsl:text>&#160;</xsl:text></td>
		<td class="{concat($day_7,' week_end')}"><xsl:text>&#160;</xsl:text></td>
	</tr>
</xsl:template>

</xsl:stylesheet>
