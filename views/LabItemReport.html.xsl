<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="html"/> 

<xsl:key name="periods" match="row" use="period_date/."/>
<xsl:key name="concrete_types" match="row" use="concrete_type_id/."/>
<xsl:key name="concrete_types_periods" match="row" use="concat(concrete_type_id/.,'|',period_date/.)"/>

<!-- Main template-->
<xsl:template match="/">
	<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>	
	<xsl:apply-templates select="document/model[@id='ModelVars']"/>	
	<xsl:apply-templates select="document/model[@id='lab_report']"/>		
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
<xsl:template match="model[@id='lab_report']">
	<xsl:variable name="model_id" select="@id"/>	
	<table id="{$model_id}" class="table table-bordered table-responsive table-striped">
		<thead>
			<tr>
				<th>Марка бетона</th>
				<xsl:for-each select="//row[generate-id() =
				generate-id(key('periods',period_date/.)[1])]">				
					<xsl:sort select="period_date/."/>
					<th align="center">
						<xsl:value-of select="period/."/>
					</th>
				</xsl:for-each>
			</tr>
		</thead>
	
		<tbody>
			<xsl:for-each select="//row[generate-id() =
			generate-id(key('concrete_types',concrete_type_id/.)[1])]">
				<xsl:sort select="concrete_type_descr/."/>
				<xsl:variable name="concrete_type_id" select="concrete_type_id/."/>
				<xsl:variable name="row_class">
					<xsl:choose>
						<xsl:when test="position() mod 2">odd</xsl:when>
						<xsl:otherwise>even</xsl:otherwise>													
					</xsl:choose>
				</xsl:variable>
				<tr class="{$row_class}">					
					<td><xsl:value-of select="concrete_type_descr/."/></td>					
					<xsl:for-each select="//row[generate-id() =
					generate-id(key('periods',period_date/.)[1])]">
						<xsl:sort select="period_date/."/>
						<xsl:variable name="concr_row" select="key('concrete_types_periods',concat($concrete_type_id,'|',period_date/.))"/>
						<td align="center"><xsl:value-of select="$concr_row/val/."/></td>
					</xsl:for-each>
					
				</tr>
			</xsl:for-each>
		</tbody>
	</table>
</xsl:template>

<!-- table header -->
<xsl:template match="model[@id='ModelVars']/row">
	<div class="rep_head">
		<div>Период с:<xsl:value-of select="date_from"/> по <xsl:value-of select="date_to"/></div>
		<div>Показатель:<xsl:value-of select="item_type"/></div>
		<div>Минимальное количество значений:<xsl:value-of select="cnt"/></div>
	</div>
</xsl:template>

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

<xsl:template match="row/concrete_type_descr">
	<td align="left">
		<xsl:value-of select="node()"/>
	</td>
</xsl:template>

<xsl:template match="row/concrete_type_id">
</xsl:template>

</xsl:stylesheet>
