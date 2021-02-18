<?php
require_once(FRAME_WORK_PATH.'basic_classes/ControllerSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtEnum.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtText.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDate.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtPassword.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtInterval.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtDateTimeTZ.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSON.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtJSONB.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldExtArray.php');

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */


class MaterialFactConsumptionCorretion_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('production_site_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array());
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time_set'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('material_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('cement_silo_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('production_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('elkon_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('quant'
				,array());
		$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('MaterialFactConsumptionCorretion.insert',$ev_opts);
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('MaterialFactConsumptionCorretion_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('production_site_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time_set'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('material_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('cement_silo_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('production_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('elkon_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('quant'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtText('comment_text'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
			//default event
			$ev_opts = [
				'dbTrigger'=>FALSE
				,'eventParams' =>['id'
				]
			];
			$pm->addEvent('MaterialFactConsumptionCorretion.update',$ev_opts);
			
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('MaterialFactConsumptionCorretion_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
				
		
		//default event
		$ev_opts = [
			'dbTrigger'=>FALSE
			,'eventParams' =>['id'
			]
		];
		$pm->addEvent('MaterialFactConsumptionCorretion.delete',$ev_opts);
		
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('MaterialFactConsumptionCorretion_Model');

			
		/* get_list */
		$pm = new PublicMethod('get_list');
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));
		$pm->addParam(new FieldExtString('cond_fields'));
		$pm->addParam(new FieldExtString('cond_sgns'));
		$pm->addParam(new FieldExtString('cond_vals'));
		$pm->addParam(new FieldExtString('cond_ic'));
		$pm->addParam(new FieldExtString('ord_fields'));
		$pm->addParam(new FieldExtString('ord_directs'));
		$pm->addParam(new FieldExtString('field_sep'));

		$this->addPublicMethod($pm);
		
		$this->setListModelId('MaterialFactConsumptionCorretionList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('MaterialFactConsumptionCorretionList_Model');		

			
		$pm = new PublicMethod('operator_insert_correction');
		
				
	/*Упрощенный ввод корректировки расхода,НО через идентификатор строки фактического расхода вводить нельзя!!! т.к. у нас агрегированные данные, потому через ключи!!!*/

				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('production_site_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('production_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('material_id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('cement_silo_id',$opts));
	
				
	$opts=array();
	
		$opts['length']=19;
		$opts['required']=TRUE;
		$opts['unsigned']=FALSE;				
		$pm->addParam(new FieldExtFloat('cor_quant',$opts));
	
				
	$opts=array();
	
		$opts['length']=500;				
		$pm->addParam(new FieldExtString('comment_text',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('operator_add_material_to_production');
		
				
	/*Добавление нового материала в производство, когда элкон не зафиксировал*/

				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('production_site_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('production_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('material_id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('cement_silo_id',$opts));
	
				
	$opts=array();
	
		$opts['length']=19;
		$opts['unsigned']=FALSE;				
		$pm->addParam(new FieldExtFloat('cor_quant',$opts));
	
				
	$opts=array();
	
		$opts['length']=500;				
		$pm->addParam(new FieldExtText('comment_text',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

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
						
		$silo_set = ($pm->getParamValue('cement_silo_id')&&$pm->getParamValue('cement_silo_id')!='null');
		
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
		$silo_set = ($pm->getParamValue('cement_silo_id')&&$pm->getParamValue('cement_silo_id')!='null');
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
							AND mt.date_time<=prod_data.production_dt_end
						ORDER BY mt.date_time DESC
						LIMIT 1
						),
						(SELECT
							mt.production_descr
						FROM raw_material_map_to_production AS mt
						WHERE
							mt.raw_material_id=%d
							AND mt.production_site_id IS NULL
							AND mt.date_time<=prod_data.production_dt_end
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
	

}
?>