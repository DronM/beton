<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'VehicleOwner'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('common/MyDate.php');
require_once(ABSOLUTE_PATH.'functions/Beton.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	public function get_tot_report($pm){
		$vown_id = 0;
		if($_SESSION['role_id']=='vehicle_owner'){
			$vown_id = intval($_SESSION['global_vehicle_owner_id']);
		}
		
		$dt = (!$pm->getParamValue('date'))? MyDate::StartMonth(time()) : $this->getExtVal($pm,'date');
		$dt+= Beton::shiftStartTime();
		$date_from = Beton::shiftStart($dt);
		$date_to = Beton::shiftEnd(MyDate::EndMonth($dt)-24*60*60+Beton::shiftStartTime());
		$date_from_db = "'".date('Y-m-d H:i:s',$date_from)."'";
		$date_to_db = "'".date('Y-m-d H:i:s',$date_to)."'";
		
		$q = "WITH
			ships AS (
				SELECT
					sum(cost) AS cost,
					sum(cost_for_driver) AS cost_for_driver,
					sum(demurrage_cost) AS demurrage_cost
				FROM shipments_for_veh_owner_list AS t
				WHERE
					".($vown_id? sprintf("t.vehicle_owner_id=%d AND ",$vown_id):"")."
					t.ship_date_time BETWEEN ".$date_from_db." AND ".$date_to_db."
			)
			,pumps AS (
				SELECT
					sum(t.pump_cost) AS cost
				FROM shipments_pump_list t
				WHERE
					".($vown_id? sprintf("t.pump_vehicle_owner_id=%d AND ",$vown_id):"")."
					t.date_time  BETWEEN ".$date_from_db." AND ".$date_to_db."
			)
			,
			client_ships AS (
				SELECT
					sum(t.cost_concrete) AS cost_concrete,
					sum(t.cost_shipment) AS cost_shipment,
					sum(t.cost_other_owner_pump) AS cost_other_owner_pump
				FROM shipments_for_client_veh_owner_list t
				WHERE	
					".($vown_id? sprintf("t.vehicle_owner_id=%d AND ",$vown_id):"")."
					t.ship_date  BETWEEN ".$date_from_db." AND ".$date_to_db."
			)
		SELECT
			(SELECT coalesce(cost,0.00) FROM ships) AS ship_cost,
			(SELECT coalesce(cost_for_driver,0.00) FROM ships) AS ship_for_driver_cost,
			(SELECT coalesce(demurrage_cost,0.00) FROM ships) AS ship_demurrage_cost,
			(SELECT coalesce(cost,0.00) FROM pumps) AS pumps_cost,
			(SELECT coalesce(cost_concrete,0.00) FROM client_ships) AS client_ships_concrete_cost,
			(SELECT coalesce(cost_other_owner_pump,0.00) FROM client_ships) AS client_ships_other_owner_pump_cost,
			(SELECT coalesce(cost_shipment,0.00) FROM client_ships) AS client_ships_shipment_cost";
		$this->addNewModel($q,'VehicleOwnerTotReport_Model');
	}

</xsl:template>

</xsl:stylesheet>
