<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" 
 xmlns:html="http://www.w3.org/TR/REC-html40"
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:fo="http://www.w3.org/1999/XSL/Format">

<xsl:output method="html"/> 

<xsl:decimal-format name="num_money" decimal-separator="," grouping-separator=" "/>
<xsl:decimal-format name="num_quant" decimal-separator="," grouping-separator=" "/>

<xsl:key name="materials" match="row" use="material_id/."/>
<xsl:key name="concrete_types" match="row" use="concrete_type_id/."/>
<xsl:key name="concrete_types_materials" match="row" use="concat(concrete_type_id/.,'|',material_id/.)"/>

<xsl:template name="format_money">
	<xsl:param name="val"/>
	
	<xsl:choose>
		<xsl:when test="$val='0' or string(number($val))='NaN'">
			<xsl:text>&#160;</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="format-number($val,'### ###,00','num_money')"/>
		</xsl:otherwise>		
	</xsl:choose>
</xsl:template>

<xsl:template name="format_quant">
	<xsl:param name="val"/>
	<xsl:choose>
		<xsl:when test="$val='0' or string(number($val))='NaN'">
			<xsl:text>&#160;</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="format-number( round(10000*$val) div 10000 ,'##0,0000','num_quant')"/>
		</xsl:otherwise>		
	</xsl:choose>
</xsl:template>

<!-- Main template-->
<xsl:template match="/">
	<xsl:apply-templates select="document/model[@id='ModelServResponse']"/>	
	<xsl:apply-templates select="document/model[@id='MaterialAvgConsumptionOnCtp_Model']"/>
	<xsl:apply-templates select="document/model[@id='MaterialBalanceCorretion_Model']"/>				
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
	
	<div>
		<h3>Итоговая таблица</h3>
		<div id="RepMaterialAvgConsumptionOnCtp:exportTot"/>
		<div id="RepMaterialAvgConsumptionOnCtp:printTot"/>		
		
		<table id="RepMaterialAvgConsumptionOnCtp:gridTot" class="table table-bordered table-responsive table-striped">
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
						<th colspan="4">Отклонение (+ излишки/- не хватило)</th>
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
					
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_quant">
								<xsl:with-param name="val" select="concrete_quant/."/>
							</xsl:call-template>
						</td>
					
						<xsl:for-each select="//row[generate-id() =
						generate-id(key('materials',material_id/.)[1])]">
							<xsl:sort select="material_ord/."/>
							<xsl:variable name="concr_row" select="key('concrete_types_materials',concat($concrete_type_id,'|',material_id/.))"/>
						
							<!-- Подбор -->
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_quant">
									<xsl:with-param name="val" select="$concr_row/norm_quant/."/>
								</xsl:call-template>								
							</td>
							
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_quant">
									<xsl:with-param name="val" select="$concr_row/norm_quant_per_m3/."/>
								</xsl:call-template>								
							</td>
							
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_money">
									<xsl:with-param name="val" select="$concr_row/norm_cost/."/>
								</xsl:call-template>																									
							</td>
						
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_money">
									<xsl:with-param name="val" select="$concr_row/norm_cost_per_m3/."/>
								</xsl:call-template>																																
							</td>

							<!-- Факт -->
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_quant">
									<xsl:with-param name="val" select="$concr_row/material_quant/."/>
								</xsl:call-template>								
							</td>
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_quant">
									<xsl:with-param name="val" select="$concr_row/material_quant_per_m3/."/>
								</xsl:call-template>								
							</td>

							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_money">
									<xsl:with-param name="val" select="$concr_row/material_cost/."/>
								</xsl:call-template>																									
							</td>
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_money">
									<xsl:with-param name="val" select="$concr_row/material_cost_per_m3/."/>
								</xsl:call-template>
							</td>
						
							<!-- Отклонение -->
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_quant">
									<xsl:with-param name="val" select="$concr_row/norm_quant/.-$concr_row/material_quant/."/>
								</xsl:call-template>																									
							</td>
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_quant">
									<xsl:with-param name="val" select="$concr_row/norm_quant_per_m3/.-$concr_row/material_quant_per_m3/."/>
								</xsl:call-template>																									
							</td>
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_money">
									<xsl:with-param name="val" select="$concr_row/norm_cost/.-$concr_row/material_cost/."/>
								</xsl:call-template>																									
							</td>
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_money">
									<xsl:with-param name="val" select="$concr_row/norm_cost_per_m3/.-$concr_row/material_cost_per_m3/."/>
								</xsl:call-template>																									
							</td>
						
						</xsl:for-each>
					
					</tr>
				</xsl:for-each>
			</tbody>
		
			<tfoot>
				<tr>
					<td>Итого
					</td>
					
					<td align="right" nowrap="nowrap">
						<xsl:call-template name="format_quant">
							<xsl:with-param name="val" select="sum(//row[generate-id()=generate-id(key('concrete_types',concrete_type_id/.)[1])]/concrete_quant/node())"/>
						</xsl:call-template>															
					</td>
					<!-- по материалам -->
					<xsl:for-each select="//row[generate-id() =
					generate-id(key('materials',material_id/.)[1])]">
						<xsl:sort select="material_ord/."/>
				
						<xsl:variable name="material_id" select="material_id/."/>
				
						<!-- Подбор -->
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_quant">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/norm_quant/.)"/>
							</xsl:call-template>															
						</td>
						
						<td></td>
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_money">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/norm_cost/.)"/>
							</xsl:call-template>						
						</td>
						<td></td>
					
						<!-- Факт -->
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_quant">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/material_quant/.)"/>
							</xsl:call-template>																						
						</td>
						<td></td>
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_money">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/material_cost/.)"/>
							</xsl:call-template>												
						</td>
						<td></td>

						<!-- Отклонение -->
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_quant">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/norm_quant/.)-sum(//row[material_id/.=$material_id]/material_quant/.)"/>
							</xsl:call-template>																								
						</td>
						<td></td>
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_money">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/norm_cost/.)-sum(//row[material_id/.=$material_id]/material_cost/.)"/>
							</xsl:call-template>																		
						</td>
						<td></td>
					
					</xsl:for-each>				
				</tr>
			</tfoot>
		</table>
	</div>
		
	<div>
		<h3>Стоимость 1м3</h3>
		<div id="RepMaterialAvgConsumptionOnCtp:exportConcrTypeCost"/>
		<div id="RepMaterialAvgConsumptionOnCtp:printConcrTypeCost"/>		
		
		<table id="RepMaterialAvgConsumptionOnCtp:gridConcrTypeCost" class="table table-bordered table-responsive table-striped">
			<thead>
				<tr>
					<th rowspan="2">Марка
					</th>
					<th colspan="{count(//row[generate-id() = generate-id(key('materials',material_id/.)[1])])+1}">Подбор
					</th>
					<th colspan="{count(//row[generate-id() = generate-id(key('materials',material_id/.)[1])])+1}">Факт
					</th>
					<th rowspan="2">Отклонение (+ излишки/- не хватило)
					</th>
				</tr>
				<tr>
					<!-- Подбор по материалам -->
					<xsl:for-each select="//row[generate-id() = generate-id(key('materials',material_id/.)[1])]">
						<xsl:sort select="material_ord/."/>
				
						<xsl:variable name="material_id" select="material_id/."/>
						<th align="center">
							<xsl:value-of select="material_name/."/>
						</th>
						
					</xsl:for-each>
					<th align="center">Итого
					</th>
					<!-- Факт по материалам -->
					<xsl:for-each select="//row[generate-id() = generate-id(key('materials',material_id/.)[1])]">
						<xsl:sort select="material_ord/."/>
				
						<xsl:variable name="material_id" select="material_id/."/>
						<th align="center">
							<xsl:value-of select="material_name/."/>
						</th>
						
					</xsl:for-each>
					<th align="center">Итого
					</th>
					
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
					
						<!-- Подбор -->
						<xsl:for-each select="//row[generate-id() = generate-id(key('materials',material_id/.)[1])]">
							<xsl:sort select="material_ord/."/>
					
							<xsl:variable name="concr_row" select="key('concrete_types_materials',concat($concrete_type_id,'|',material_id/.))"/>
						
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_money">
									<xsl:with-param name="val" select="number($concr_row/norm_cost_per_m3/.)"/>
								</xsl:call-template>																						
							</td>
					
						</xsl:for-each>					
						<td align="right" nowrap="nowrap" style="font-weight:bolder;">
							<xsl:call-template name="format_money">							
								<xsl:with-param name="val" select="sum(//row[concrete_type_id/.=$concrete_type_id]/norm_cost/.) div concrete_quant/."/>
							</xsl:call-template>							
						</td>

						<!-- Факт -->
						<xsl:for-each select="//row[generate-id() = generate-id(key('materials',material_id/.)[1])]">
							<xsl:sort select="material_ord/."/>
					
							<xsl:variable name="concr_row" select="key('concrete_types_materials',concat($concrete_type_id,'|',material_id/.))"/>
						
							<td align="right" nowrap="nowrap">
								<xsl:call-template name="format_money">
									<xsl:with-param name="val" select="number($concr_row/material_cost_per_m3/.)"/>
								</xsl:call-template>																						
							</td>
					
						</xsl:for-each>					
						<td align="right" nowrap="nowrap" style="font-weight:bolder;">
							<xsl:call-template name="format_money">							
								<xsl:with-param name="val" select="sum(//row[concrete_type_id/.=$concrete_type_id]/material_cost/.) div concrete_quant/."/>
							</xsl:call-template>							
						</td>
						
						<!-- Отклонение -->
						<td align="right" nowrap="nowrap" style="font-weight:bolder;">
							<xsl:call-template name="format_money">
								<xsl:with-param name="val" select="(sum(//row[concrete_type_id/.=$concrete_type_id]/norm_cost/.) div concrete_quant/.) - (sum(//row[concrete_type_id/.=$concrete_type_id]/material_cost/.) div concrete_quant/.)"/>
							</xsl:call-template>																														
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</div>	
	
	<!-- Стоимость материалов-->	
	<div>
		<h3>Стоимость материалов</h3>
		<div id="RepMaterialAvgConsumptionOnCtp:exportMatCost"/>
		<div id="RepMaterialAvgConsumptionOnCtp:printMatCost"/>		
		
		<table id="RepMaterialAvgConsumptionOnCtp:gridMatCost" class="table table-bordered table-responsive table-striped">
			<thead>
				<tr>
					<td>Материал
					</td>
					<td>Подбор
					</td>
					<td>Факт
					</td>
					<td>Отклонение (+ излишки/- не хватило)
					</td>			
				</tr>	
			</thead>
			<tbody>
				<xsl:for-each select="//row[generate-id() =
				generate-id(key('materials',material_id/.)[1])]">
					<xsl:sort select="material_ord/."/>
				
					<xsl:variable name="material_id" select="material_id/."/>
				
					<xsl:variable name="row_class">
						<xsl:choose>
							<xsl:when test="position() mod 2">odd</xsl:when>
							<xsl:otherwise>even</xsl:otherwise>													
						</xsl:choose>
					</xsl:variable>
					<tr class="{$row_class}">					
						<td><xsl:value-of select="material_name/."/></td>					
					
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_money">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/norm_cost/.)"/>
							</xsl:call-template>
						</td>
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_money">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/material_cost/.)"/>
							</xsl:call-template>																														
						</td>
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_money">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/norm_cost/.)-sum(//row[material_id/.=$material_id]/material_cost/.)"/>
							</xsl:call-template>																														
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
			<tfoot>
				<tr>
					<td>Итого</td>
					<td align="right" nowrap="nowrap">
						<xsl:call-template name="format_money">
							<xsl:with-param name="val" select="sum(//row/norm_cost/.)"/>
						</xsl:call-template>
					</td>
					<td align="right" nowrap="nowrap">
						<xsl:call-template name="format_money">
							<xsl:with-param name="val" select="sum(//row/material_cost/.)"/>
						</xsl:call-template>																														
					</td>
					<td align="right" nowrap="nowrap">
						<xsl:call-template name="format_money">
							<xsl:with-param name="val" select="sum(//row/norm_cost/.)-sum(//row/material_cost/.)"/>
						</xsl:call-template>																														
					</td>
				</tr>
			</tfoot>
		</table>	
	</div>
	
	<!-- Объем материалов-->	
	<div>
		<h3>Объем материалов</h3>
		<div id="RepMaterialAvgConsumptionOnCtp:exportMatQuant"/>
		<div id="RepMaterialAvgConsumptionOnCtp:printMatQuant"/>		
		
		<table id="RepMaterialAvgConsumptionOnCtp:gridMatQuant" class="table table-bordered table-responsive table-striped">
			<thead>
				<tr>
					<td>Материал
					</td>
					<td>Подбор
					</td>
					<td>Факт
					</td>
					<td>Отклонение (+ излишки/- не хватило)
					</td>			
				</tr>	
			</thead>
			<tbody>
				<xsl:for-each select="//row[generate-id() =
				generate-id(key('materials',material_id/.)[1])]">
					<xsl:sort select="material_ord/."/>
				
					<xsl:variable name="material_id" select="material_id/."/>
				
					<xsl:variable name="row_class">
						<xsl:choose>
							<xsl:when test="position() mod 2">odd</xsl:when>
							<xsl:otherwise>even</xsl:otherwise>													
						</xsl:choose>
					</xsl:variable>
					<tr class="{$row_class}">					
						<td><xsl:value-of select="material_name/."/></td>					
					
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_quant">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/norm_quant/.)"/>
							</xsl:call-template>																													
						</td>
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_quant">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/material_quant/.)"/>
							</xsl:call-template>																													
						</td>
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_quant">
								<xsl:with-param name="val" select="sum(//row[material_id/.=$material_id]/norm_quant/.)-sum(//row[material_id/.=$material_id]/material_quant/.)"/>
							</xsl:call-template>																														
						</td>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>	
	</div>
	
</xsl:template>

<xsl:template match="model[@id='MaterialBalanceCorretion_Model']">
	<xsl:variable name="model_id" select="@id"/>	
	
	<div>
		<h3>Корректировка остатков материалов (обнуление)</h3>
		<div id="RepMaterialAvgConsumptionOnCtp:exportBalanceCorrect"/>
		<div id="RepMaterialAvgConsumptionOnCtp:printBalanceCorrect"/>
		
		<table id="RepMaterialAvgConsumptionOnCtp:gridBalanceCorrect" class="table table-bordered table-responsive table-striped">
			<thead>
				<tr>
					<th>Материал</th>
					<th>Количество</th>
					<th>Цена</th>
					<th>Сумма</th>
				</tr>	
			</thead>
			<tbody>
				<xsl:for-each select="row">
					<xsl:variable name="row_class">
						<xsl:choose>
							<xsl:when test="position() mod 2">odd</xsl:when>
							<xsl:otherwise>even</xsl:otherwise>													
						</xsl:choose>
					</xsl:variable>
				
					<tr class="{$row_class}">
						<td><xsl:value-of select="material_name"/></td>
												
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_quant">
								<xsl:with-param name="val" select="quant"/>
							</xsl:call-template>																														
						</td>
						
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_money">
								<xsl:with-param name="val" select="total div quant"/>
							</xsl:call-template>																														
						</td>
						
						<td align="right" nowrap="nowrap">
							<xsl:call-template name="format_money">
								<xsl:with-param name="val" select="total"/>
							</xsl:call-template>																														
						</td>
						
					</tr>
				</xsl:for-each>
			</tbody>		
			
			<tfoot>
				<tr>
					<td colspan="3">Итого</td>
					<td align="right" nowrap="nowrap">
						<xsl:call-template name="format_money">
							<xsl:with-param name="val" select="sum(row/total)"/>
						</xsl:call-template>
					</td>
				</tr>
			
			</tfoot>		
			
		</table>	
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
