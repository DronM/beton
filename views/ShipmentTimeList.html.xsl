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
			<xsl:apply-templates select="document/model[@id='ShipmentTimeList_Model']"/>	
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
<xsl:template match="model[@id='ShipmentTimeList_Model']">
	<table id="ShipmentTimeList_Model" class="table table-bordered table-responsive table-striped">
		<!-- header -->
		<thead>
		<tr>
			<th>№</th>
			<th>Завод</th>
			<th>Клиент</th>
			<th>Объект</th>
			<th>ТС</th>
			<th>Водитель</th>
			<th>Объем</th>
			<th>Назначение</th>
			<th>Отгрузка</th>
			<th>Норма погрузки (мин.)</th>
			<th>Опоздание диспетчера (мин.)</th>			
			<th>Опоздание оператора (мин.)</th>
			<th>Опоздание общее (мин.)</th>								
		</tr>
		</thead> 
		 
		<!-- vehicles -->
		<tbody>
			<xsl:apply-templates/>
		</tbody>
		
	</table>
</xsl:template>

<!-- table row -->
<xsl:template match="row">
	<tr>
		<td align="center">
			<xsl:value-of select="id"/>
		</td>
		<td align="left">
			<xsl:value-of select="production_site_descr"/>
		</td>
		<td align="left">
			<xsl:value-of select="client_descr"/>
		</td>
		<td align="left">
			<xsl:value-of select="destination_descr"/>
		</td>
		<td align="center">
			<xsl:value-of select="vehicle_descr"/>
		</td>
		<td align="left">
			<xsl:value-of select="driver_descr"/>
		</td>
		<td align="right">
			<xsl:value-of select="quant"/>
		</td>		
		<td align="center">
			<xsl:value-of select="assign_date_time_descr"/>
		</td>
		<td align="center">
			<xsl:value-of select="ship_date_time_descr"/>
		</td>
		<td align="right">
			<xsl:value-of select="ship_time_norm"/>
		</td>	
		<td align="right">
			<xsl:value-of select="dispatcher_fail_min"/>
		</td>
		<td align="right">
			<xsl:value-of select="operator_fail_min"/>
		</td>
		<td align="right">
			<xsl:value-of select="total_fail_min"/>
		</td>
	</tr>
</xsl:template>

</xsl:stylesheet>
