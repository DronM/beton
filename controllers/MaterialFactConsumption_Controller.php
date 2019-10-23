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



require_once('common/ExcelReader/Excel/reader.php');

class MaterialFactConsumption_Controller extends ControllerSQL{

	const ER_UPLOAD = 'Ошибка загрузки файла данных';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			

		/* insert */
		$pm = new PublicMethod('insert');
		$param = new FieldExtInt('production_site_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('upload_date_time'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('upload_user_id'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtString('concrete_type_production_descr'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('concrete_type_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('raw_material_production_descr'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('raw_material_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtString('vehicle_production_descr'
				,array('required'=>TRUE));
		$pm->addParam($param);
		$param = new FieldExtInt('vehicle_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtInt('vehicle_schedule_state_id'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('concrete_quant'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('material_quant'
				,array());
		$pm->addParam($param);
		$param = new FieldExtFloat('material_quant_req'
				,array());
		$pm->addParam($param);
		
		$pm->addParam(new FieldExtInt('ret_id'));
		
		
		$this->addPublicMethod($pm);
		$this->setInsertModelId('MaterialFactConsumption_Model');

			
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
		$param = new FieldExtDateTimeTZ('upload_date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('upload_user_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtDateTimeTZ('date_time'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('concrete_type_production_descr'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('concrete_type_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('raw_material_production_descr'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('raw_material_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtString('vehicle_production_descr'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('vehicle_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtInt('vehicle_schedule_state_id'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('concrete_quant'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('material_quant'
				,array(
			));
			$pm->addParam($param);
		$param = new FieldExtFloat('material_quant_req'
				,array(
			));
			$pm->addParam($param);
		
			$param = new FieldExtInt('id',array(
			));
			$pm->addParam($param);
		
		
			$this->addPublicMethod($pm);
			$this->setUpdateModelId('MaterialFactConsumption_Model');

			
		/* delete */
		$pm = new PublicMethod('delete');
		
		$pm->addParam(new FieldExtInt('id'
		));		
		
		$pm->addParam(new FieldExtInt('count'));
		$pm->addParam(new FieldExtInt('from'));				
		$this->addPublicMethod($pm);					
		$this->setDeleteModelId('MaterialFactConsumption_Model');

			
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
		
		$this->setListModelId('MaterialFactConsumptionList_Model');
		
			
		$pm = new PublicMethod('get_rolled_list');
		
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

			
		/* get_object */
		$pm = new PublicMethod('get_object');
		$pm->addParam(new FieldExtString('mode'));
		
		$pm->addParam(new FieldExtInt('id'
		));
		
		
		$this->addPublicMethod($pm);
		$this->setObjectModelId('MaterialFactConsumptionList_Model');		

			
		$pm = new PublicMethod('upload_production_file');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtInt('production_site_id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtText('production_file',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	

	public function get_rolled_list($pm){
		$link = $this->getDbLink();
		
		$list_model_name = $this->getListModelId();
		$list_model = new $list_model_name($this->getDbLink());
		$where = $this->conditionFromParams($pm,$list_model);
		
		$cond = '';
		$oblig_cond = 'NOT coalesce(t_map.order_id,0)=0';
		if($where){
			$where_fields = $where->getFieldIterator();
			while($where_fields->valid()){
				$field = $where_fields->current();
				$cond.=($cond=='')? '':' '.$field['cond'].' ';
				if (!is_null($field['expression'])){
					$cond.= $field['expression'];
				}
				else{
					$pat = ($field['caseInsen'])?
						$where::PAT_CASE_INSEN:$where::PAT_CASE_SEN;
					$f_val = ($field['field']->getSQLExpression())?
							$field['field']->getSQLExpression():
							$field['field']->getValueForDb();
					if ($field['signe']=='LIKE' && strlen($f_val) && $f_val[0]!="'"){
						$f_val = "'".$f_val."'";
					}
					$field['field']->setTableName('t');
					$f_sql = $field['field']->getSQLNoAlias(FALSE);
					$cond.= sprintf($pat,
						$f_sql . ( ($field['signe']=='LIKE')? '::text':'' ),
						$field['signe'],
						$f_val
					);				
				}
				
				$where_fields->next();
			}
			$cond.= 'AND '.$oblig_cond;
		}
		else{
			$cond = $oblig_cond;
		}
		$cond = 'WHERE '.$cond;
		
		$mat_model = new ModelSQL($link,array('id'=>'MaterialFactConsumptionMaterialList_Model'));
		$mat_model->addField(new FieldSQLString($link,null,null,"raw_material_production_descr"));
		$mat_model->query(sprintf(
			"SELECT DISTINCT ON (t.raw_material_production_descr,t_map.order_id)
				t.raw_material_production_descr,
				t_map.raw_materials_ref
			FROM material_fact_consumptions AS t
			LEFT JOIN raw_material_map_to_production_list AS t_map ON t_map.production_descr=t.raw_material_production_descr
			%s
			ORDER BY t_map.order_id",
			$cond
		),
		TRUE);
		$this->addModel($mat_model);			
	
		$this->setListModelId("MaterialFactConsumptionRolledList_Model");
		parent::get_list($pm);
	}

	public function get_list($pm){
		$link = $this->getDbLink();
		
		$list_model_name = $this->getListModelId();
		$list_model = new $list_model_name($this->getDbLink());
		$where = $this->conditionFromParams($pm,$list_model);
		
		$mat_model = new ModelSQL($link,array('id'=>'MaterialFactConsumptionHeader_Model'));
		$mat_model->addField(new FieldSQLString($link,null,null,"raw_material_production_descr"));
		$mat_model->query(sprintf(
			"SELECT
				DISTINCT raw_material_production_descr
			FROM material_fact_consumptions
			%s
			ORDER BY raw_material_production_descr",
			$where? $where->getSQL():''
		),
		TRUE);
		$this->addModel($mat_model);			
		
		parent::get_list($pm);
	}

	//http://localhost/beton_new/?t=MaterialFactConsumptionUpload&v=Child
	public function upload_production_file($pm){
		
		$data_file = OUTPUT_PATH.DIRECTORY_SEPARATOR.uniqid();
		if (
		!$_FILES['production_file']
		|| !$_FILES['production_file']['tmp_name']
		|| !count($_FILES['production_file']['tmp_name'])
		//|| !move_uploaded_file($_FILES['production_file']['tmp_name'][0],$data_file)
		){
			throw new Exception(self::ER_UPLOAD);
		}
		
		//file processing
		$data = new Spreadsheet_Excel_Reader();
		$data->setOutputEncoding('utf-8');
		$data->read($_FILES['production_file']['tmp_name'][0]);
		
		$fl = OUTPUT_PATH.'excel_data.txt';
		if(file_exists($fl)){
			unlink($fl);
		}
		
		$HEAD_ROW = 2;//header row
		$MAT_COL_FROM = 9;//
		$DATA_ROW_FROM = 4;//
		
		$COL_CHECK = 2;
		$COL_DATE = 3;
		$COL_CONCRETE_TYPE = 5;
		$COL_TIME = 6;
		$COL_QUANT_V = 7;
		$COL_VEHICLE = 8;
		
		$link = $this->getDbLinkMaster();
		
		$link->query('BEGIN');
		try{
			$materials = [];
			$concrete_types = [];
			$vehicles = [];
			
			//materials
			$col = $MAT_COL_FROM;		
			while($col<$data->sheets[0]['numCols']){
				$descr_s = $data->sheets[0]['cells'][$HEAD_ROW][$col];
				$descr = '';
				FieldSQLString::formatForDb($link,$descr_s,$descr);
				$ar = $link->query_first(sprintf('SELECT material_fact_consumptions_add_material(%s) AS material_id',$descr));
				$materials[$descr_s] = is_null($ar['material_id'])? 'NULL':$ar['material_id'];
				$col+= 3;
			}
			
			$errors = FALSE;
			//data
			for ($row = $DATA_ROW_FROM; $row <= $data->sheets[0]['numRows']; $row++) {
				$check  = trim((string) $data->sheets[0]['cells'][$row][$COL_CHECK]);
				if(!strlen($check)){
					break;
				}
				
				$concrete_type_descr = $link->escape_string($data->sheets[0]['cells'][$row][$COL_CONCRETE_TYPE]);
				$quant_v = floatval($link->escape_string($data->sheets[0]['cells'][$row][$COL_QUANT_V]));
				$vehicle_descr = $link->escape_string($data->sheets[0]['cells'][$row][$COL_VEHICLE]);
				
				//build date time
				$data_dt = "'".date('Y-m-d',$data->sheets[0]['cellsInfo'][$row][$COL_DATE]['raw']-24*60*60).' '.trim($data->sheets[0]['cells'][$row][$COL_TIME])."'";
				
				if(!isset($concrete_types[$concrete_type_descr])){
					$ar = $link->query_first(sprintf("SELECT material_fact_consumptions_add_concrete_type('%s') AS concrete_type_id",$concrete_type_descr));
					$concrete_types[$concrete_type_descr] = is_null($ar['concrete_type_id'])? 'NULL':$ar['concrete_type_id'];
				}
				if(!isset($vehicles[$vehicle_descr])){
					$ar = $link->query_first(sprintf("SELECT material_fact_consumptions_add_vehicle('%s') AS vehicle_id",$vehicle_descr));
					$vehicles[$vehicle_descr] = is_null($ar['vehicle_id'])? 'NULL':$ar['vehicle_id'];
				}
				
				//materials
				$col = $MAT_COL_FROM;		
				foreach($materials as $mat_descr=>$mat_id){
					$mat_quant = floatval((string) $data->sheets[0]['cells'][$row][$col]);
					$mat_quant_req = floatval((string) $data->sheets[0]['cells'][$row][$col+1]);
					$col+= 3;
					
					$mat_id = is_null($mat_id)? 'NULL':$mat_id;
					
					if(!$errors){
						$errors = is_null($mat_id) || is_null($concrete_type_id) || is_null($vehicle_id);
					}
					
					//to database
					$link->query(
						sprintf("SELECT material_fact_consumptions_add(ROW(
							nextval(pg_get_serial_sequence('material_fact_consumptions', 'id')),
							%d,
							now(),
							%d,
							%s::timestamp,
							'%s',
							%s,
							'%s',
							%s,
							'%s',
							%s,
							NULL,
							%f,
							%f,
							%f
							)::material_fact_consumptions)",
								$this->getExtDbVal($pm,"production_site_id"),
								$_SESSION['user_id'],
								$data_dt,
								$concrete_type_descr,
								$concrete_types[$concrete_type_descr],
								$mat_descr,
								$mat_id,
								$vehicle_descr,
								$vehicles[$vehicle_descr],							
								$quant_v,
								$mat_quant,
								$mat_quant_req
							)
					);
				}
			}
			
			$link->query('COMMIT');
		}
		catch(Exception $e){
			$link->query('ROLLBACK');
			throw $e;
		}
		
		if($errors){
			throw new Exception('Файл загружен, но есть несопоставленные данные!');
		}
	}


}
?>