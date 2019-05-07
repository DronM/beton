<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'Client'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');

class <xsl:value-of select="@id"/>_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);<xsl:apply-templates/>
	}
	public function union($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();		
		
		$client_ids = $params->getVal('client_ids');
		//validation
		$ids_ar = split(',',$client_ids);
		foreach($ids_ar as $id){
			if (!ctype_digit($id)){
				throw new Exception('Not int found!');
			}
		}
		
		$this->getDbLinkMaster()->query(sprintf(
		//throw new Exception(sprintf(
			"SELECT clients_union(%d,ARRAY[%s])",
			$params->getParamById('main_client_id'),
			$client_ids
		));
	}
	public function get_duplicates_list($pm){
		$this->addNewModel("SELECT * FROM client_duplicates_list",
			'get_duplicates_list'
		);
	}
	public function set_duplicate_valid($pm){
		$params = new ParamsSQL($pm,$this->getDbLink());
		$params->addAll();		
		
		$client_ids = $params->getVal('client_ids');
		$tel = $params->getDbVal('tel');
		
		//validation
		$ids_ar = split(',',$client_ids);
		foreach($ids_ar as $id){
			if (!ctype_digit($id)){
				throw new Exception('Not int found!');
			}
		}
		$l = $this->getDbLinkMaster();
		foreach($ids_ar as $id){
			$l->query(sprintf(
				"INSERT INTO client_valid_duplicates
				(tel,client_id)
				VALUES (%s,%d)",
				$tel,
				$id
			));
		}
	}
	public function insert($pm){
		if (!$pm->getParamValue('manager_id')){
			$pm->setParamValue('manager_id',$_SESSION['user_id']);
		}
		parent::insert($pm);
	}
	
	public function insert_from_order($pm){
		$res = $this->getDbLink()->query_first(sprintf("SELECT id FROM clients WHERE name=%s",$this->getExtDbVal($pm,"name")));
		if(!is_array($res) || !count($res)){
			$res = $this->getDbLink()->query_first(sprintf("INSERT INTO clients (name,name_full) VALUES (%s,%s) RETURNING id",
			$this->getExtDbVal($pm,"name"),
			$this->getExtDbVal($pm,"name")
			));
		}
		$this->addModel(new ModelVars(
			array('id'=>'Client_Model',
				'values'=>array(
					new Field('id',DT_INT,
						array('value'=>$res['id'])
					)
				)
			)
		));		
	}
	
	public function complete_for_order($pm){
	
		$this->addNewModel(sprintf(
			"SELECT
				clients.id,
				clients.name,
				last_order.descr,
				last_order.phone_cel,
				concrete_types_ref(ct) AS concrete_types_ref,
				destinations_ref(dest) AS destinations_ref,
				last_order.quant,
				last_order.date_time
			FROM clients
			LEFT JOIN (
				SELECT
					o.descr AS descr,
					o.phone_cel,
					o.concrete_type_id,
					o.destination_id,
					o.quant,
					o.date_time,
					s.client_id
				FROM orders AS o
				LEFT JOIN (
					SELECT
						max(orders.date_time) AS date_time,
						orders.client_id
					FROM orders
					GROUP BY orders.client_id
				) s ON s.client_id=o.client_id AND s.date_time=o.date_time	
			) AS last_order ON last_order.client_id=clients.id
			LEFT JOIN concrete_types AS ct ON ct.id=last_order.concrete_type_id
			LEFT JOIN destinations AS dest ON dest.id=last_order.destination_id
			WHERE lower(clients.name) LIKE lower(%s)||'%%'
			LIMIT 5",
			$this->getExtDbVal($pm,'name')
			),
			'OrderClient_Model'
		);	
	}
	
	/* !!!ПЕРЕКРЫТИЕ МЕТОДА!!! */
	public function conditionFromParams($pm,$model){
		$where = null;
		$val = $pm->getParamValue('cond_fields');
		if (isset($val)&amp;&amp;$val!=''){			
			$condFields = explode(',',$val);
			$cnt = count($condFields);			
			if ($cnt>0){		
				$val = $pm->getParamValue('cond_sgns');
				$condSgns = (isset($val))? explode(',',$val):array();
				$val = $pm->getParamValue('cond_vals');				
				$condVals = (isset($val))? explode(',',$val):array();				
				$val = $pm->getParamValue('cond_ic');
				$condInsen = (isset($val))? explode(',',$val):array();
				$sgn_keys_ar = explode(',',COND_SIGN_KEYS);
				$sgn_ar = explode(',',COND_SIGNS);
				if (count($condVals)!=$cnt){
					throw new Exception('Количество значений условий не совпадает с количеством полей!');
				}
				$where = new ModelWhereSQL();
				for ($i=0;$i&lt;$cnt;$i++){
					if (count($condSgns)>$i){
						$ind = array_search($condSgns[$i],$sgn_keys_ar);
					}
					else{
						//default param
						$ind = array_search('e',$sgn_keys_ar);
					}
					if ($ind>=0){
						//Добавлено
						if ($condFields[$i]=='tel'){
							$field = clone $model->getFieldById('id');
							$ic = false;
							$tel_db = NULL;
							$ext_class = new FieldExtString($condFields[$i]);
							$val_validated = $ext_class->validate($condVals[$i]);
							FieldSQLString::formatForDb($this->getDbLink(),$val_validated,$tel_db);							
							$field->setSQLExpression(sprintf(
								"(SELECT t.client_id FROM client_tels t WHERE t.tel=%s)",
								$tel_db
								)								
							);
						}
						else{
							$field = clone $model->getFieldById($condFields[$i]);
							$ext_class = str_replace('SQL','Ext',get_class($field));
							$ext_field = new $ext_class($field->getId());
						
							$ext_field->setValue($condVals[$i]);
							$field->setValue($ext_field->getValue());
							//echo 'ind='.$i.' val='.$ext_field->getValue();
							if (count($condInsen)>$i){
								$ic = ($condInsen[$i]=='1');
							}
							else{
								$ic = false;
							}
						}
						$where->addField($field,
							$sgn_ar[$ind],NULL,$ic);
					}
				}
			}
		}
		return $where;
	}
	
}
<![CDATA[?>]]>
</xsl:template>

</xsl:stylesheet>
