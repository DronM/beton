<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="html.xsl"/>

<!-- -->
<xsl:variable name="TEMPLATE_ID" select="'About'"/>
<!-- -->

<xsl:template match="/">
	<xsl:apply-templates select="metadata/serverTemplates/serverTemplate[@id=$TEMPLATE_ID]"/>
</xsl:template>

<xsl:template match="serverTemplate">
<xsl:comment>
This file is generated from the template build/templates/tmpl/html.xsl
All direct modification will be lost with the next build.
Edit template instead.
</xsl:comment>
<div id="}">
	<div class="row">
		<label class="control-label }5">
		</label>
		<div class="}4">
		</div>
	</div>
	<div class="row">
		<label class="control-label }5">
		</label>
		<div class="}4">
		</div>
	</div>

	<div class="row">
		<label class="control-label }5">
		</label>
		<div class="}4">
		</div>
	</div>

	<div class="row">
		<label class="control-label }5">
		</label>
		<div class="}4">
		</div>
	</div>
	
	<div class="row">
		<label class="control-label }5">
		</label>
		<div class="}4">
		</div>
	</div>
	<div class="row">
		<label class="control-label }5">
		</label>
		<div class="}4">
		</div>
	</div>
	<div class="row">
		<label class="control-label }5">
		</label>
		<div class="}4">
		</div>
	</div>
</div>
</xsl:template>

</xsl:stylesheet>
