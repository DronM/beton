<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="html"/> 

<!--
match - Defines the nodes to which the key will be applied
use - The value of the key for each of the nodes
-->
<xsl:key name="days" match="row" use="day/."/>
<xsl:key name="vehicles" match="row" use="plate/."/>
<xsl:key name="vehicles_days" match="row" use="concat(plate/.,'|',day/.)"/>

<!-- Main template-->
<xsl:template match="/">
	<xsl:choose>
		<xsl:when test="not(document/model[@id='ModelServResponse']/row[1]/result='0')">
		<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>	
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="document/model[@id='get_schedule_report_all']"/>	
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
<xsl:template match="model[@id='get_schedule_report_all']">
	<table id="get_schedule_report_all" class="table table-bordered table-responsive table-striped">
		<!-- header -->
		<thead>
		<tr>
			<th>№</th>
			<th>ТС</th>
			<th>Владелец</th>
			<xsl:for-each select="//row[generate-id() =
			generate-id(key('days',day/.)[1])]">				
				<th align="center">
					<xsl:value-of select="substring(day_descr/.,1,2)"/>
					<span class="dow_descr"><xsl:value-of select="dow_descr/."/></span>
				</th>
			</xsl:for-each>
		</tr>
		</thead> 
		 
		<!-- vehicles -->
		<tbody>
		<xsl:for-each select="//row[generate-id() =
		generate-id(key('vehicles',plate/.)[1])]">
			<xsl:sort select="owner/."/>
			<xsl:if test="day_no_shift/.='false'">
			<xsl:variable name="plate" select="plate/."/>
			<xsl:variable name="row_class">
				<xsl:choose>
					<xsl:when test="position() mod 2">
						<xsl:value-of select="'odd'"/>
					</xsl:when>								
					<xsl:otherwise>
						<xsl:value-of select="'even'"/>
					</xsl:otherwise>													
				</xsl:choose>
			</xsl:variable>
			<tr class="{$row_class}">
				<td align="center"><xsl:value-of select="position()"/></td>
				<td align="center"><xsl:value-of select="$plate"/></td>
				<td align="center"><xsl:value-of select="owner/."/></td>
				<xsl:for-each select="//row[generate-id() =
				generate-id(key('days',day/.)[1])]">
					<xsl:variable name="day_class">
						<xsl:choose>
						<!--key('vehicles_days',concat(plate/.,'|',day/.))-->
							<xsl:when test="key('vehicles_days',concat($plate,'|',day/.))">
								<xsl:value-of select="'on_shift'"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'no_shift'"/>
							</xsl:otherwise>
						</xsl:choose>					
					</xsl:variable>
				
					<td class="{$day_class}" align="center">
						<xsl:text>&#160;</xsl:text>
					</td>
				</xsl:for-each>											
			</tr>	
			</xsl:if>
		</xsl:for-each>			
		</tbody>
		
	</table>
</xsl:template>

</xsl:stylesheet>
