<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="html"/> 

<xsl:key name="materials" match="row" use="material_id/."/>
<xsl:key name="concrete_types" match="row" use="concrete_type_id/."/>
<xsl:key name="concrete_types_materials" match="row" use="concat(concrete_type_id/.,'|',material_id/.)"/>

<!-- Main template-->
<xsl:template match="/">
	<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>	
	<xsl:apply-templates select="document/model[@id='MaterialAvgConsumptionOnCtp_Model']"/>		
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
<xsl:template match="model[@id='MaterialAvgConsumptionOnCtp_Model']">
	<xsl:variable name="model_id" select="@id"/>	
	<table id="{$model_id}" class="table table-bordered table-responsive table-striped">
		<thead>
			<tr>
				<th rowspan="4">Марка бетона</th>
				<th rowspan="4">Объем,м3</th>
				<xsl:for-each select="//row[generate-id() =
				generate-id(key('materials',material_id/.)[1])]">				
					<xsl:sort select="material_ord/."/>
					<th colspan="12" align="center">
						<xsl:value-of select="material_name/."/>
					</th>
				</xsl:for-each>
			</tr>
			<tr>
				<xsl:for-each select="//row[generate-id() =
				generate-id(key('materials',material_id/.)[1])]">				
					<xsl:sort select="material_ord/."/>
			
					<th colspan="4">Подбор</th>
					<th colspan="4">Факт</th>
					<th colspan="4">Отклонение</th>
				</xsl:for-each>	
			</tr>
			<tr>
				<xsl:for-each select="//row[generate-id() =
				generate-id(key('materials',material_id/.)[1])]">				
					<xsl:sort select="material_ord/."/>
			
					<th colspan="2">Количество</th>
					<th colspan="2">Сумма</th>

					<th colspan="2">Количество</th>
					<th colspan="2">Сумма</th>

					<th colspan="2">Количество</th>
					<th colspan="2">Сумма</th>
				</xsl:for-each>	
			</tr>
			<tr>
				<xsl:for-each select="//row[generate-id() =
				generate-id(key('materials',material_id/.)[1])]">				
					<xsl:sort select="material_ord/."/>
			
					<th>Всего</th>
					<th>На м3</th>
					<th>Всего</th>
					<th>На м3</th>
				
					<th>Всего</th>
					<th>На м3</th>
					<th>Всего</th>
					<th>На м3</th>

					<th>Всего</th>
					<th>На м3</th>
					<th>Всего</th>
					<th>На м3</th>
				</xsl:for-each>	
			</tr>
			
		</thead>
	
		<tbody>
			<xsl:for-each select="//row[generate-id() =
			generate-id(key('concrete_types',concrete_type_id/.)[1])]">
				<xsl:sort select="concrete_type_name/."/>
				<xsl:variable name="concrete_type_id" select="concrete_type_id/."/>
				<xsl:variable name="row_class">
					<xsl:choose>
						<xsl:when test="position() mod 2">odd</xsl:when>
						<xsl:otherwise>even</xsl:otherwise>													
					</xsl:choose>
				</xsl:variable>
				<tr class="{$row_class}">					
					<td><xsl:value-of select="concrete_type_name/."/></td>					
					
					<td align="right"><xsl:value-of select="concrete_quant/."/></td>
					
					<xsl:for-each select="//row[generate-id() =
					generate-id(key('materials',material_id/.)[1])]">
						<xsl:sort select="material_ord/."/>
						<xsl:variable name="concr_row" select="key('concrete_types_materials',concat($concrete_type_id,'|',material_id/.))"/>
						
						<td align="right"><xsl:value-of select="$concr_row/norm_quant/."/></td>
						<td align="right"><xsl:value-of select="$concr_row/norm_quant_per_m3/."/></td>

						<td align="right"><xsl:value-of select="$concr_row/norm_cost/."/></td>
						<td align="right"><xsl:value-of select="$concr_row/norm_cost_per_m3/."/></td>

						<!-- -->
						<td align="right"><xsl:value-of select="$concr_row/material_quant/."/></td>
						<td align="right"><xsl:value-of select="$concr_row/material_quant_per_m3/."/></td>

						<td align="right"><xsl:value-of select="$concr_row/material_cost/."/></td>
						<td align="right"><xsl:value-of select="$concr_row/material_cost_per_m3/."/></td>
						
						<!-- -->
						<td align="right"></td>
						<td align="right"></td>

						<td align="right"></td>
						<td align="right"></td>
						
					</xsl:for-each>
					
				</tr>
			</xsl:for-each>
		</tbody>
	</table>
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
