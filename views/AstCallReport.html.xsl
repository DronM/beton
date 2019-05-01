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
			<xsl:apply-templates select="document/model[@id='AstCall_Model']"/>	
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
				<th>Менеджер</th>
				<th>Всего клиентов</th>
				<th title="дата создания в интервале отчета" >Новых клиентов</th>
				<th title="новые клиенты (дата создания в интервале отчета) с отгрузками">Новых покупателей</th>				
				<th title="отношение новых покупателей к новым">Эффективность</th>
				<th title="все клиенты с отгрузками">Покупателей</th>
				<th title="общий объем отгруженного по менеджеру новами клиентами">Объем</th>
				<th title="всего отгружено по менеджеру">Весь объем</th>
			</tr>
		</thead>
	
		<tbody>
			<xsl:apply-templates/>
		</tbody>
		
		<tfoot>
			<tr class="grid_foot">
				<td class="invisible"></td>
				<td>Итого</td>
				<td align="right">
					<xsl:value-of select="sum(row/client_count)"/>
				</td>				
				<td align="right">
					<xsl:value-of select="sum(row/new_client_count)"/>
				</td>				
				<td align="right">
					<xsl:value-of select="sum(row/buyer_count)"/>
				</td>				
				<td></td>
				<td align="right">
					<xsl:value-of select="sum(row/buyer_count_from_all)"/>
				</td>				
				
				<td align="right">
					<xsl:value-of select="sum(row/manager_new_client_quant)"/>
				</td>				
				<td align="right">
					<xsl:value-of select="sum(row/manager_quant)"/>
				</td>				
			</tr>
		</tfoot>
		
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
<xsl:template match="row/manager_id">
	<td class="invisible">
		<xsl:value-of select="node()"/>
	</td>
</xsl:template>

<xsl:template match="row/manager_descr">
	<td align="left">
		<xsl:value-of select="node()"/>
	</td>
</xsl:template>

<xsl:template match="row/*">
	<td align="right">
		<xsl:value-of select="node()"/>
	</td>
</xsl:template>

</xsl:stylesheet>
