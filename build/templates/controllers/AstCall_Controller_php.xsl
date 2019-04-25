<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'AstCall'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');
require_once(FRAME_WORK_PATH.'basic_classes/Field.php');
require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');
require_once(FRAME_WORK_PATH.'basic_classes/CondParamsSQL.php');
require_once('models/AstCallList_Model.php');

class <xsl:value-of select="@id"/>_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>
<!-- UPDATE ast_calls set client_id=NULL WHERE unique_id='1433835968.45036'
-->
<xsl:template name="extra_methods">
	private function active_call_query($extraCond='',$commonExt=FALSE){		
		//return "SELECT t.* FROM ast_calls_current t LIMIT 1";
	
		return sprintf("SELECT t.* FROM ast_calls_current t
		WHERE t.ext='%s'
			%s LIMIT 1",
			($commonExt)? COMMON_EXT:$_SESSION['tel_ext'],
			$extraCond
		);
	}

	public function active_call_inform($pm){		
		if ($_SESSION['tel_ext']){
			$q = sprintf(
			"UPDATE ast_calls
			SET informed=TRUE
			WHERE unique_id = (SELECT t.unique_id FROM (%s) t)
			RETURNING unique_id,caller_id_num AS num,
				(SELECT cl.name
				FROM clients cl WHERE cl.id=client_id) AS client_descr",
			$this->active_call_query(' AND coalesce(t.informed,FALSE)=FALSE')
			);
			$ar = $this->getDbLinkMaster()->query_first($q);
			
			$m = new ModelVars(array(
				'id'=>'active_call',
				'values'=>array(
				new Field('unique_id',DT_STRING,array('value'=>$ar['unique_id'])),
				new Field('num',DT_STRING,array('value'=>$ar['num'])),
				new Field('client_descr',DT_STRING,array('value'=>$ar['client_descr']))
				)));
			$this->addModel($m);
		}
		$this->addNewModel(
			$this->active_call_query(' AND t.answer_time IS NULL',TRUE),
			'active_call_common'
			);
		
	}
	public function active_call($pm){		
		if ($_SESSION['tel_ext']){
			$q = $this->active_call_query();
			$ar = $this->getDbLink()->query_first($q);
			$this->addNewModel($q,'AstCallCurrent_Model');
			
			if (is_array($ar)&amp;&amp;count($ar)&gt;0){
				if ($ar['client_id']){
					$this->add_client_call_hist($ar['client_id']);
					$this->add_client_ship_hist($ar['client_id']);				
				}
				return $ar['client_id'];
			}			
		}		
	}
	
	protected function add_client_call_hist($clientId){		
		$this->addNewModel(sprintf(
		"SELECT * FROM ast_calls_client_call_history_list
		WHERE client_id=%s
		ORDER BY dt DESC
		LIMIT const_call_history_count_val()",
		$clientId),
		'AstCallClientCallHistoryList_Model');
	}
	
	public function client_call_hist($pm){		
		$this->add_client_call_hist(
			sprintf(
				'(SELECT t.client_id FROM (%s) t)'
				,$this->active_call_query()
			)
		);
	}
	
	public function add_client_ship_hist($clientId){			
		$this->addNewModel(sprintf(
		"SELECT * FROM ast_calls_client_ship_history_list
		WHERE client_id=%s
		ORDER BY date_time DESC
		LIMIT const_call_history_count_val()",
		$clientId),
		'AstCallClientShipHistoryList_Model');
	
	}
	
	public function client_ship_hist($pm){			
		$this->add_client_ship_hist(
			sprintf(
				'(SELECT t.client_id FROM (%s) t)'
				,$this->active_call_query()
			)
		);	
	}
		
	public function update($pm){
		if ($pm->getParamValue('client_id')){
			//дополнительные данные
			
			$l = $this->getDbLinkMaster();
			$l->query("BEGIN");
			try{				
				$p = new ParamsSQL($pm,$this->getDbLink());
				$p->add('contact_name',DT_STRING,$pm->getParamValue('contact_name'));
				$p->add('contact_tel',DT_STRING,$pm->getParamValue('contact_tel'));
				$p->add('client_id',DT_INT,$pm->getParamValue('client_id'));
				$p->add('client_name',DT_STRING,$pm->getParamValue('client_name'));				
				$p->add('client_come_from_id',DT_INT,$pm->getParamValue('client_come_from_id'));
				$p->add('client_type_id',DT_INT,$pm->getParamValue('client_type_id'));
				$p->add('client_kind',DT_STRING,$pm->getParamValue('client_kind'));
				$p->add('manager_comment',DT_STRING,$pm->getParamValue('manager_comment'));
				$p->add('unique_id',DT_STRING,$pm->getParamValue('unique_id'));
			
				/** сверим имя клиента
				 * и имя контакта с базой - если надо обновим
				 */
				$ar = $l->query_first(sprintf(
				"SELECT
					cl.name AS client_name,
					clt.name AS contact_name,
					clt.tel AS contact_tel,
					cl.client_kind AS client_kind,
					cl.client_come_from_id,
					cl.client_type_id
				FROM clients AS cl
				LEFT JOIN client_tels AS clt
					ON clt.client_id=cl.id
					AND clt.tel=format_phone(%s)
				WHERE cl.id=%d",
				$p->getParamById('contact_tel'),
				$p->getParamById('client_id')
				));
				
				if (is_array($ar)&amp;&amp;count($ar)){
					//ПОЛЯ КЛИЕНТА
					$client_upd_fields = '';
					if (strlen($pm->getParamValue('client_name'))&amp;&amp;$ar['client_name']!=$pm->getParamValue('client_name')){
						$client_upd_fields.= ($client_upd_fields=='')? '':',';
						$client_upd_fields.= sprintf('name=%s',$p->getParamById('client_name'));
					}
					if (strlen($pm->getParamValue('client_type_id'))&amp;&amp;$ar['client_type_id']!=$pm->getParamValue('client_type_id')){
						$client_upd_fields.= ($client_upd_fields=='')? '':',';
						$client_upd_fields.= sprintf('client_type_id=%d',$p->getParamById('client_type_id'));
					}
					if (strlen($pm->getParamValue('client_come_from_id'))&amp;&amp;$ar['client_come_from_id']!=$pm->getParamValue('client_come_from_id')){
						$client_upd_fields.= ($client_upd_fields=='')? '':',';
						$client_upd_fields.= sprintf('client_come_from_id=%d',$p->getParamById('client_come_from_id'));
					}
					if (strlen($pm->getParamValue('client_kind'))&amp;&amp;$ar['client_kind']!=$pm->getParamValue('client_kind')){
						$client_upd_fields.= ($client_upd_fields=='')? '':',';
						$client_upd_fields.= sprinbtf('client_kind=%s',$p->getParamById('client_kind'));
					}
					
					if (strlen($client_upd_fields)){						
						$l->query(sprintf(
						"UPDATE clients
						SET %s
						WHERE id=%d",
						$client_upd_fields,
						$p->getParamById('client_id')
						));
					}
					
					//КОНТАКТ
					if ($ar['contact_tel']
					&amp;&amp;strlen($pm->getParamValue('contact_name'))
					&amp;&amp;$ar['contact_name']!=$pm->getParamValue('contact_name')){
						//сменилось имя контакта
						$l->query(sprintf(
						"UPDATE client_tels
						SET name=%s
						WHERE client_id=%d AND tel='%s'",
						$p->getParamById('contact_name'),
						$p->getParamById('client_id'),
						$ar['contact_tel']
						));						
					}
					else if (!$ar['contact_tel']){
						//нет контакта
						$l->query(sprintf(
						"INSERT INTO client_tels
						(client_id,tel,name)
						VALUES (%d,format_phone(%s),%s)",
						$p->getParamById('client_id'),
						$p->getParamById('contact_tel'),
						$p->getParamById('contact_name')
						));
					}					
				}
				
				//КОММЕНТАРИЙ МЕНЕДЖЕРА
				if (strlen($pm->getParamValue('manager_comment'))&amp;&amp;strlen($pm->getParamValue('unique_id'))){
					$l->query(sprintf(
					"UPDATE ast_calls
					SET manager_comment=%s
					WHERE unique_id=%s",
					$p->getParamById('manager_comment'),
					$p->getParamById('unique_id')
					));											
				}
				
				$l->query("COMMIT");
			}
			catch (Exception $e){
				$l->query("ROLLBACK");
				throw new Exception($e->getMessage());
			}
		}
		parent::update($pm);
	}
	public function set_active_call_client_kind($pm){
		$p = new ParamsSQL($pm,$this->getDbLink());
		$p->add('id',DT_STRING,$pm->getParamValue('id'));
		$p->add('kind',DT_STRING,$pm->getParamValue('kind'));
	
		$l = $this->getDbLinkMaster();
		$l->query("BEGIN");
			//Новый клиент
			$ar = $l->query_first(sprintf(
			"INSERT INTO clients
			(name,client_kind)
			VALUES ('Клиент '||
				(SELECT coalesce(max(id),0)+1
				FROM clients),%s)
			RETURNING id",
			$p->getParamById('kind'))
			);
			
			//Контакт клиента
			$l->query(sprintf("INSERT INTO client_tels
			(client_id,tel)
			VALUES (%d,(
				SELECT format_cel_phone(ast.caller_id_num)
				FROM ast_calls ast WHERE ast.unique_id=%s))",
			$ar['id'],
			$p->getParamById('id')
			));
			
		try{
			$l->query("COMMIT");
		}
		catch (Exception $e){
			$l->query("ROLLBACK");
			throw new Exception($e->getMessage());
		}
	}
	public function new_client($pm){
		$p = new ParamsSQL($pm,$this->getDbLink());
		$p->addAll();
		
		$l = $this->getDbLinkMaster();
		$l->query('BEGIN');
		try{
			$client_id = $p->getParamById('client_id');
			if (!$client_id||$client_id=='null'){
				//новый клиент
				$client_name = $p->getParamById('client_name');
				if ($client_name=="''"){
					$client_name = $p->getParamById('contact_name');
				}
				if ($client_name=="''"||$client_name=="null"){
					$ar = $l->query_first("SELECT COALESCE(max(id),0)+1 AS new_id FROM clients");
					$client_name = "'Клиент ".$ar['new_id']."'";
				}
				$ar = $l->query_first(sprintf(
				"INSERT INTO clients
					(name,name_full,manager_comment,
					client_come_from_id,
					client_type_id,client_kind,
					manager_id)
				VALUES
					(%s,%s,
					%s,
					%d,%d,'buyer',
					(SELECT a.user_id
					FROM ast_calls AS a
					WHERE a.unique_id=%s)
					)
				RETURNING id",
				$client_name,$client_name,
				$p->getParamById('client_comment_text'),
				$p->getParamById('client_come_from_id'),
				$p->getParamById('client_type_id'),
				$p->getParamById('ast_call_id')
				));
				$client_id = $ar['id'];
			}
			else{
				//старый клиент
				$ar = $l->query_first(sprintf(
					"SELECT name
					FROM clients WHERE id=%d",
				$client_id
				));
				if (!is_array($ar)||!count($ar)){
					throw new Exception("Не найдне клиент!");
				}
				$client_name = "'".$ar['name']."'";
			}
			
			//Контакт клиента
			$l->query(sprintf(
			"INSERT INTO client_tels
				(client_id,tel,name)
			VALUES (%d,(
				SELECT format_cel_phone(ast.caller_id_num)
				FROM ast_calls ast WHERE ast.unique_id=%s),
				%s)",
			$client_id,
			$p->getParamById('ast_call_id'),
			$p->getParamById('contact_name')
			));
			
			$concrete_type_id = $p->getParamById('concrete_type_id');
			$concrete_type_id = (is_null($concrete_type_id))? 'null':$concrete_type_id;
			$destination_id = $p->getParamById('destination_id');			
			$destination_id = (is_null($destination_id))? 'null':$destination_id;
			
			$l->query(sprintf(
			"INSERT INTO offer
				(client_id,
				unload_type,unload_price,
				concrete_type_id,concrete_price,
				destination_id,destination_price,
				total,quant,comment_text,
				offer_result,date_time,
				ast_call_unique_id
				)
			VALUES (%d,
				%s,%f,
				%s,%f,
				%s,%f,
				%f,%f,%s,
				%s,now()::timestamp,
				%s
			)",
			$client_id,
			$p->getParamById('unload_type'),$p->getParamById('unload_price'),
			$concrete_type_id,$p->getParamById('concrete_type_price'),
			$destination_id,$p->getParamById('destination_price'),
			$p->getParamById('total'),$p->getParamById('quant'),$p->getParamById('comment_text'),
			$p->getParamById('offer_result'),
			$p->getParamById('ast_call_id')
			));			
			
			$l->query(sprintf(
			"UPDATE ast_calls SET client_id=%d
			WHERE unique_id=%s",
			$client_id,
			$p->getParamById('ast_call_id')
			));
			
			$l->query('COMMIT');
		}		
		catch (Exception $e){
			$l->query("ROLLBACK");
			throw new Exception($e->getMessage());
		}
		
		$this->addNewModel(sprintf(
			"SELECT
				%d AS client_id,
				%s AS client_descr",
		$client_id,$client_name),
		'new_client');
		
	}
	public function manager_report($pm){
		$cond = new CondParamsSQL($pm,$this->getDbLink());
		$manager_id = ($cond->paramExists('manager_id','e'))?
			$cond->getValForDb('manager_id','e',DT_INT) : 0;
	
		$this->addNewModel(sprintf(
		"SELECT * FROM ast_calls_report(%s,%s,%d)",
		$cond->getValForDb('date_time','ge',DT_DATETIME),
		$cond->getValForDb('date_time','le',DT_DATETIME),
		$manager_id
		));
	}
	public function get_list($pm){		
		$model = new AstCallList_Model($this->getDbLink());
		$from = null; $count = null;
		$limit = $this->limitFromParams($pm,$from,$count);
		$calc_total = ($count>0);
		if ($from){
			$model->setListFrom($from);
		}
		if ($count){
			$model->setRowsPerPage($count);
		}
		
		$order = $this->orderFromParams($pm,$model);		
		$where = $this->conditionFromParams($pm,$model);
		
		$fields = $this->fieldsFromParams($pm);		
		
		if(isset($where)){
			$new_clients = $where->getFieldsById('new_clients','=');
			if ($new_clients&amp;&amp;count($new_clients)){
				if ($new_clients[0]->getValue()=='t'){
					$start_time_from = $where->getFieldsById('start_time','>=');
					$f = clone $model->getFieldById('create_date');
					$f->setValue($start_time_from[0]->getValue());
					$where->addField($f,'>=');
				
					$start_time_to = $where->getFieldsById('start_time','&lt;=');
					$f = clone $model->getFieldById('create_date');
					$f->setValue($start_time_to[0]->getValue());
					$where->addField($f,'&lt;=');
			
				}
				$where->deleteField('new_clients','=');
			}
		}		
		$model->select(FALSE,
					$where,
					$order,
					$limit,
					$fields,
					NULL,
					NULL,
					$calc_total,TRUE);
		//
		$this->addModel($model);
	}
	
	public function restart_ast($pm){		
		file_put_contents('/tmp/server_cmd','restart_asttodb');
	}
</xsl:template>

</xsl:stylesheet>
