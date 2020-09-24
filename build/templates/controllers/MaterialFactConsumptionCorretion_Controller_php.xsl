<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'MaterialFactConsumptionCorretion'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>
class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>

<xsl:template name="extra_methods">

	/*
	 * Это упрощенный ввод корректировки для оператора через детальную таблицу производства
	 */
	function operator_insert_correction($pm){
		/*
		ТАК НЕЛЬЗЯ, т.к. material_fact_consumption_list содржит агрегированные данные!!!
		$this->getDbLinkMaster()->query(sprintf(
			"INSERT INTO material_fact_consumption_corrections
			(production_site_id,
			date_time,
			user_id,
			material_id,
			cement_silo_id,
			production_id,
			quant,
			comment_text
			)
			(SELECT
				t.production_site_id,
				now(),
				%d,
				t.raw_material_id,
				t.cement_silo_id,
				t.production_id,
				%f - t.material_quant,
				%s
			FROM material_fact_consumptions AS t
			WHERE t.id=%d)",
		$_SESSION['user_id'],		
		$this->getExtDbVal($pm,'quant'),
		$this->getExtDbVal($pm,'comment_text'),
		$this->getExtDbVal($pm,'material_fact_consumption_id')
		));
		*/
						
		$silo_set = ($pm->getParamValue('cement_silo_id')&amp;&amp;$pm->getParamValue('cement_silo_id')!='null');
		
		$ar = $this->getDbLinkMaster()->query_first(sprintf(
			"SELECT id FROM material_fact_consumption_corrections
			WHERE
				production_site_id=%d
				AND elkon_id=0
				AND material_id=%d
				AND cement_silo_id %s
				AND production_id=%d"
			,$this->getExtDbVal($pm,'production_site_id')
			,$this->getExtDbVal($pm,'material_id')
			,$silo_set? '='.$this->getExtDbVal($pm,'cement_silo_id'):' IS NULL'
			,$this->getExtDbVal($pm,'production_id')
		));
	
		if(!is_array($ar) || !count($ar) || !isset($ar['id'])){
			$this->getDbLinkMaster()->query(sprintf(
				"INSERT INTO material_fact_consumption_corrections
				(production_site_id,
				elkon_id,
				date_time,
				user_id,
				material_id,
				cement_silo_id,
				production_id,
				quant,
				comment_text
				)
				VALUES(
				%d,
				0,
				now(),
				%d,
				%d,
				%s,
				%d,
				%f,
				%s
				)",
			$this->getExtDbVal($pm,'production_site_id'),
			$_SESSION['user_id'],
			$this->getExtDbVal($pm,'material_id'),
			$silo_set? $this->getExtDbVal($pm,'cement_silo_id'):'NULL',
			$this->getExtDbVal($pm,'production_id'),
			$this->getExtDbVal($pm,'cor_quant'),
			$this->getExtDbVal($pm,'comment_text')
			));
		}
		else{
			//update
			$this->getDbLinkMaster()->query(sprintf(
				"UPDATE material_fact_consumption_corrections
				SET
					quant = %f,
					comment_text = %s
				WHERE
					id=%d"
				,$this->getExtDbVal($pm,'cor_quant')
				,$this->getExtDbVal($pm,'comment_text')
				,$ar['id']
			));
			
		}
	}
	
	/**
	 * Добавление нового материала в производство, когда элкон не зафиксировал
	 * 2 действия:
	 * 1) Добавить новый материал в material_fact_consumptions БЕЗ количества, просто чтобы было
	 * 2) Добавить корректировку
	 */
	function operator_add_material_to_production($pm){
		//
		$silo_set = ($pm->getParamValue('cement_silo_id')&amp;&amp;$pm->getParamValue('cement_silo_id')!='null');
		$this->getDbLinkMaster()->query('BEGIN');
		try{
			// 1)
			$this->getDbLinkMaster()->query(sprintf(
				"WITH prod_data AS (
					SELECT
						pr.production_site_id,
						pr.production_id,
						pr.production_dt_end,
						pr.concrete_type_id,
						pr.production_vehicle_descr,
						pr.vehicle_id,
						pr.vehicle_schedule_state_id,
						pr.concrete_quant						
					FROM productions pr
					WHERE pr.production_site_id=%d AND pr.production_id=%d
				)
				INSERT INTO material_fact_consumptions
				(production_site_id,
				production_id,
				cement_silo_id,
				raw_material_id,
				material_quant, material_quant_req,
				date_time, upload_date_time,
				upload_user_id,
				concrete_type_production_descr,
				raw_material_production_descr,
				vehicle_production_descr,
				vehicle_id,
				vehicle_schedule_state_id,
				concrete_quant,concrete_type_id)
				SELECT
					prod_data.production_site_id,
					prod_data.production_id,
					%s,
					%d,
					0,0,
					prod_data.production_dt_end,
					now(),
					%d,
					(SELECT
						ct.production_descr
					FROM concrete_type_map_to_production AS ct
					WHERE ct.concrete_type_id=prod_data.concrete_type_id
					LIMIT 1
					),
					coalesce(
						(SELECT
							mt.production_descr
						FROM raw_material_map_to_production AS mt
						WHERE
							mt.raw_material_id=%d
							AND mt.production_site_id=prod_data.production_site_id
							AND mt.date_time&lt;=prod_data.production_dt_end
						ORDER BY mt.date_time DESC
						LIMIT 1
						),
						(SELECT
							mt.production_descr
						FROM raw_material_map_to_production AS mt
						WHERE
							mt.raw_material_id=%d
							AND mt.production_site_id IS NULL
							AND mt.date_time&lt;=prod_data.production_dt_end
						ORDER BY mt.date_time DESC
						LIMIT 1
						)
					),
					prod_data.production_vehicle_descr,
					prod_data.vehicle_id,
					prod_data.vehicle_schedule_state_id,
					prod_data.concrete_quant,
					prod_data.concrete_type_id
				FROM prod_data"
				,$this->getExtDbVal($pm,'production_site_id')
				,$this->getExtDbVal($pm,'production_id')
				,$silo_set? $this->getExtDbVal($pm,'cement_silo_id'):'NULL'
				,$this->getExtDbVal($pm,'material_id')				
				,$_SESSION['user_id']
				,$this->getExtDbVal($pm,'material_id')
				,$this->getExtDbVal($pm,'material_id')
			));
			
			// 2)
			$this->operator_insert_correction($pm);
		
			$this->getDbLinkMaster()->query('COMMIT');		
		}
		catch (Exception $e){
			$this->getDbLinkMaster()->query('ROLLBACK');		
			throw $e;
		}		
	}
	
</xsl:template>

</xsl:stylesheet>
