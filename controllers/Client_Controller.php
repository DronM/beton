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

/**
 * THIS FILE IS GENERATED FROM TEMPLATE build/templates/controllers/Controller_php.xsl
 * ALL DIRECT MODIFICATIONS WILL BE LOST WITH THE NEXT BUILD PROCESS!!!
 */



require_once(FRAME_WORK_PATH.'basic_classes/ParamsSQL.php');

class Client_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL){
		parent::__construct($dbLinkMaster);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtString('name'
				,array('required'=>TRUE,
				'alias'=>'Наименование'
			));
		$pm->addParam($param);
		$param = new FieldExtText('name_full'
				,array(
				'alias'=>'Полное наименование'
			));
		$pm->addParam($param);
		$param = new FieldExtString('phone_cel'
				,array('required'=>FALSE,
				'alias'=>'Сотовый телефон'
			));
		$pm->addParam($param);
		$param = new FieldExtText('manager_comment'
				,array(
				'alias'=>'Комментарий'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('client_type_id'
				,array(
				'alias'=>'Вид контрагента'
			));
		$pm->addParam($param);
		
				$param = new FieldExtEnum('client_kind',',','buyer,acc,else'
				,array(
				'alias'=>'Тип контрагента'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('client_come_from_id'
				,array(
				'alias'=>'Источник обращения'
			));
		$pm->addParam($param);
		$param = new FieldExtInt('manager_id'
				,array(
				'alias'=>'Менеджер'
			));
		$pm->addParam($param);
		$param = new FieldExtDate('create_date'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('email'
				,array('required'=>FALSE));
		$pm->addParam($param);
		$param = new FieldExtString('inn'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('Client_Model');

			
		/* update */		
		$pm = new PublicMethod('update');
		
		$pm->addParam(new FieldExtInt('old_id',array('required'=>TRUE)));
		
		$pm->addParam(new FieldExtInt('obj_mode'));
		$param = new FieldExtInt('id'
				,array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		$param = new FieldExtString('name'
				,array(
			
				'alias'=>'Наименование'
			));
			$pm->addParam($param);
		$param = new FieldExtText('name_full'
				,array(
			
				'alias'=>'Полное наименование'
			));
			$pm->addParam($param);
		$param = new FieldExtString('phone_cel'
				,array(
			
				'alias'=>'Сотовый телефон'
			));
			$pm->addParam($param);
		$param = new FieldExtText('manager_comment'
				,array(
			
				'alias'=>'Комментарий'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('client_type_id'
				,array(
			
				'alias'=>'Вид контрагента'
			));
			$pm->addParam($param);
		
				$param = new FieldExtEnum('client_kind',',','buyer,acc,else'
				,array(
			
				'alias'=>'Тип контрагента'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('client_come_from_id'
				,array(
			
				'alias'=>'Источник обращения'
			));
			$pm->addParam($param);
		$param = new FieldExtInt('manager_id'
				,array(
			
				'alias'=>'Менеджер'
			));
			$pm->addParam($param);
		$param = new FieldExtDate('create_date'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('email'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('inn'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			
				'alias'=>'Код'
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('Client_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('Client_Model');

			
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
		
		$this->setListModelId('ClientList_Model');
		
			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('ClientDialog_Model');		

			
		/* complete  */
		$pm = new PublicMethod('complete');
		$pm->addParam(new FieldExtString('pattern'));
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('ic'));
		$pm->addParam(new FieldExtInt('mid'));
		$pm->addParam(new FieldExtString('name'));		
		$this->addPublicMethod($pm);					
		$this->setCompleteModelId('Client_Model');

			
		$pm = new PublicMethod('complete_for_order');
		
				
	$opts=array();
			
		$pm->addParam(new FieldExtString('name',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('ic',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('mid',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('union');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('main_client_id',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('client_ids',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('set_duplicate_valid');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('tel',$opts));
	
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('client_ids',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_duplicates_list');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('from',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtInt('count',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('ord_fields',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('ord_directs',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('insert_from_order');
		
				
	$opts=array();
	
		$opts['length']=100;
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('name',$opts));
	
			
		$this->addPublicMethod($pm);

		
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
				clients.inn AS inn,
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
		if (isset($val)&&$val!=''){			
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
				for ($i=0;$i<$cnt;$i++){
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
?>