<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Destination'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('common/geo/yandex.php');
require_once(FRAME_WORK_PATH.'basic_classes/CondParamsSQL.php');

class <xsl:value-of select="@id"/>_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}

	public function get_coords_on_name($pm){
		$addr = array();
		$inf = array();
		$addr['city'] = 'область+Тюменская,город+Тюмень,'.$this->getExtVal($pm,'name');
		get_inf_on_address($addr,$inf);
		$model = new Model(array('id'=>'Coords_Model'));
		$model->addField(new Field('lon_lower',DT_STRING));
		$model->addField(new Field('lon_upper',DT_STRING));
		$model->addField(new Field('lat_lower',DT_STRING));
		$model->addField(new Field('lat_upper',DT_STRING));
		$model->insert();
		$model->lon_lower = $inf['lon_lower'];
		$model->lon_upper = $inf['lon_upper'];
		$model->lat_lower = $inf['lat_lower'];
		$model->lat_upper = $inf['lat_upper'];
		$this->addModel($model);
	}
	
	public function at_dest_avg_time($pm){
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		$this->addNewModel(sprintf('SELECT * FROM at_dest_avg_time(%s,%s)',
		$cond->getValForDb('date_time','ge',DT_DATETIME),
		$cond->getValForDb('date_time','le',DT_DATETIME)),
		'at_dest_avg_time');
	}
	public function route_to_dest_avg_time($pm){
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		$this->addNewModel(sprintf('SELECT * FROM route_to_dest_avg_time(%s,%s)',
		$cond->getValForDb('date_time','ge',DT_DATETIME),
		$cond->getValForDb('date_time','le',DT_DATETIME)),
		'route_to_dest_avg_time');
	}
	
	
	public function complete_dest($pm){
		if($pm->getParamValue('name_pat')){
			$this->addNewModel(sprintf(
			"SELECT
				dest.*
			FROM destination_list_view AS dest
			WHERE lower(dest.name) LIKE lower(%s)||'%%'",
			$this->getExtDbVal($pm,'name_pat')
			),
			'DestinationList_Model');
		}
		else if($pm->getParamValue('client_id')){
			$this->addNewModel(sprintf(
			"SELECT DISTINCT ON (o.destination_id)
				dest.*
			FROM orders AS o
			LEFT JOIN destination_list_view dest ON dest.id=o.destination_id
			WHERE o.client_id=%d
			ORDER BY o.destination_id,o.date_time DESC",
			$this->getExtDbVal($pm,'client_id')
			),
			'DestinationList_Model');
		}
	}
}
<![CDATA[?>]]>
</xsl:template>

</xsl:stylesheet>
