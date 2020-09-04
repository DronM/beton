<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:import href="Controller_php.xsl"/>

<!-- -->
<xsl:variable name="CONTROLLER_ID" select="'MaterialFactConsumption'"/>
<!-- -->

<xsl:output method="text" indent="yes"
			doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" 
			doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>
			
<xsl:template match="/">
	<xsl:apply-templates select="metadata/controllers/controller[@id=$CONTROLLER_ID]"/>
</xsl:template>

<xsl:template match="controller"><![CDATA[<?php]]>
<xsl:call-template name="add_requirements"/>

require_once('common/ExcelReader/Excel/reader.php');

require_once(FRAME_WORK_PATH.'basic_classes/VariantStorageBeton.php');

class <xsl:value-of select="@id"/>_Controller extends <xsl:value-of select="@parentId"/>{

	const ER_UPLOAD = 'Ошибка загрузки файла данных';

	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);<xsl:apply-templates/>
	}	
	<xsl:call-template name="extra_methods"/>
}
<![CDATA[?>]]>
</xsl:template>


<xsl:template name="extra_methods">

	public function get_rolled_list($pm){
		$link = $this->getDbLink();
		
		$list_model_name = $this->getListModelId();
		$list_model = new $list_model_name($this->getDbLink());

		$cond = '';
		if (defined('PARAM_TEMPLATE') &amp;&amp; isset($_REQUEST[PARAM_TEMPLATE])){
			$stvar = VariantStorageBeton::restore($_REQUEST[PARAM_TEMPLATE], $this->getDbLink());
			VariantStorageBeton::applyFilters($stvar,$list_model,$where,$_REQUEST[PARAM_TEMPLATE]);
		}
		else{
			$where = $this->conditionFromParams($pm,$list_model);
		}
		if($where){
			$where->setTableName('t');
		}
		
		$oblig_cond = '';//NOT coalesce(t_map.order_id,0)=0
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
					if ($field['signe']=='LIKE' &amp;&amp; strlen($f_val) &amp;&amp; $f_val[0]!="'"){
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
			if(strlen($oblig_cond)){
				$cond.= ' AND '.$oblig_cond;
			}
			
		}
		else if(strlen($oblig_cond)){
			$cond = $oblig_cond;
		}
		if(strlen($cond)){
			$cond = 'WHERE '.$cond;
		}
		//||' ('||pr_st.name||')'
		$mat_model = new ModelSQL($link,array('id'=>'MaterialFactConsumptionMaterialList_Model'));
		$mat_model->addField(new FieldSQLString($link,null,null,"raw_material_production_descr"));
		$mat_model->query(sprintf(
			"WITH 
			prod_tot AS (
				SELECT sum(concrete_quant) AS v
				FROM productions
				WHERE id IN (
					SELECT prod.id
					FROM material_fact_consumptions AS t
					LEFT JOIN productions AS prod ON prod.production_site_id=t.production_site_id AND prod.production_id=t.production_id
					%s
				)
			)
			SELECT DISTINCT ON (mat.ord,t.production_site_id,t.raw_material_production_descr)
				t.raw_material_production_descr AS raw_material_production_descr,
				materials_ref(mat) AS raw_materials_ref,
				pr_st.name AS production_name,
				t.production_site_id,
				(SELECT v FROM prod_tot) AS concrete_quant,
				sum(t.material_quant+coalesce(t_cor.quant,0)) AS material_quant,
				sum(t.material_quant_req) AS material_quant_req,
				sum(
					CASE
						WHEN coalesce(sh.quant,0)=0 OR coalesce(t.concrete_quant,0)=0 THEN 0
						ELSE coalesce(ra_mat.quant,0)/coalesce(sh.quant,0) * coalesce(t.concrete_quant,0)
					END				
				) AS material_quant_shipped
			FROM material_fact_consumptions AS t
			LEFT JOIN raw_materials AS mat ON mat.id=t.raw_material_id
			LEFT JOIN production_sites AS pr_st ON pr_st.id=t.production_site_id
			LEFT JOIN productions AS prod ON prod.production_site_id=t.production_site_id AND prod.production_id=t.production_id
			LEFT JOIN shipments AS sh ON sh.id=prod.shipment_id
			LEFT JOIN ra_materials AS ra_mat ON ra_mat.doc_type='shipment' AND ra_mat.doc_id=sh.id AND ra_mat.material_id=t.raw_material_id
			LEFT JOIN material_fact_consumption_corrections AS t_cor ON t_cor.production_site_id=t.production_site_id AND t_cor.production_id=t.production_id
						AND t_cor.material_id=t.raw_material_id
						AND t_cor.cement_silo_id=t.cement_silo_id
			%s
			GROUP BY t.raw_material_production_descr,t.production_site_id,mat.ord,mat.*,pr_st.name
			ORDER BY mat.ord,t.production_site_id",
			$cond,
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

	//http://localhost/beton_new/?t=MaterialFactConsumptionUpload&amp;v=Child
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
		
		$production_site_id = $this->getExtDbVal($pm,"production_site_id");
		
		$link->query('BEGIN');
		try{
			$materials = [];
			$concrete_types = [];
			$vehicles = [];
			$silo_ids = [];
			
			//materials
			$col = $MAT_COL_FROM;		
			while($col&lt;$data->sheets[0]['numCols']){
				$descr_s = $data->sheets[0]['cells'][$HEAD_ROW][$col];
				$descr = '';
				FieldSQLString::formatForDb($link,$descr_s,$descr);
				$ar = $link->query_first(sprintf('SELECT material_fact_consumptions_add_material(%s) AS material_id',$descr));
				$materials[$descr_s] = is_null($ar['material_id'])? 'NULL':$ar['material_id'];
				$col+= 3;
			}
			
			$errors = FALSE;
			//data
			for ($row = $DATA_ROW_FROM; $row &lt;= $data->sheets[0]['numRows']; $row++) {
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
					//У нас в программе учет в тоннах!
					$mat_quant = floatval((string) $data->sheets[0]['cells'][$row][$col]) / 1000;
					$mat_quant_req = floatval((string) $data->sheets[0]['cells'][$row][$col+1]) / 1000;
					$col+= 3;
					
					$mat_id = is_null($mat_id)? 'NULL':$mat_id;
					
					if(!$errors){
						$errors = is_null($mat_id) || is_null($concrete_type_id) || is_null($vehicle_id);
					}
					
					$silo_key = $production_site_id.$mat_descr;
					if(!isset($silo_ids[$silo_key])){
						$ar = $link->query_first(sprintf("SELECT id FROM cement_silos WHERE production_site_id=%d AND production_descr='%s'",$production_site_id,$mat_descr));
						$silo_ids[$silo_key] = is_null($ar['id'])? 'NULL':$ar['id'];
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
							%f,
							%d
							)::material_fact_consumptions)",
								$production_site_id,
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
								$mat_quant_req,
								$silo_ids[$silo_key]
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
	
	public function get_report($pm){
	}

	public function insert($pm){
		/**
		 * Имеем такие поля:
		 * production_id
		 * production_site_id
		 * cement_silo_id
		 * raw_material_id
		 * material_quant
		 */
		
		$production_site_id = $this->getExtDbVal($pm,'production_site_id');
		$production_id = $this->getExtDbVal($pm,'production_id');
		$raw_material_id = $this->getExtDbVal($pm,'raw_material_id');
		$material_quant = $this->getExtDbVal($pm,'material_quant');
		
		//Берем данные по производству
		$ar_prod = $this->getDbLink()->query_first(sprintf(
			"SELECT
				t.id
				,t.concrete_type_id AS concrete_type_id
				,ct.name AS concrete_type_production_descr
				,t.vehicle_id AS vehicle_id
				,regexp_replace(vh.plate, '\D','','g') AS vehicle_production_descr
				,t.concrete_quant
				,(SELECT m.name FROM raw_materials AS m WHERE m.id=%d) AS raw_material_production_descr
				,t.vehicle_schedule_state_id
				,t.manual_correction
			FROM productions AS t
			LEFT JOIN concrete_types AS ct ON ct.id=t.concrete_type_id
			LEFT JOIN vehicles AS vh ON vh.id=t.vehicle_id
			WHERE t.production_site_id=%d AND t.production_id=%d"
			,$raw_material_id
			,$production_site_id
			,$production_id
		));
		
		if(!is_array($ar_prod) || !count($ar_prod) || !isset($ar_prod['id'])){
			throw new Exception('Производство не найдено!');
		}
		
		try{
			$this->getDbLinkMaster('BEGIN');

			$this->getDbLinkMaster()->query(
				sprintf(
					"INSERT INTO material_fact_consumptions
					(production_site_id
					,production_id
					,cement_silo_id
					,upload_date_time
					,date_time
					,upload_user_id
					,concrete_type_production_descr
					,concrete_type_id
					,raw_material_production_descr
					,raw_material_id
					,vehicle_production_descr
					,vehicle_id
					,vehicle_schedule_state_id
					,concrete_quant
					,material_quant
					,material_quant_req
					)
					VALUES
					(%d
					,%d
					,%s
					,now()
					,now()
					,%d
					,'%s'
					,%d
					,'%s'
					,%d				
					,'%s'
					,%d
					,%d
					,%f
					,%f
					,%f
					)"
					,$this->getExtDbVal($pm,'production_site_id')
					,$this->getExtDbVal($pm,'production_id')
					,$this->getExtDbVal($pm,'cement_silo_id')
					,$_SESSION['user_id']
					,$ar_prod['concrete_type_production_descr']
					,$ar_prod['concrete_type_id']
					,$ar_prod['raw_material_production_descr']
					,$raw_material_id
					,$ar_prod['vehicle_production_descr']
					,$ar_prod['vehicle_id']
					,$ar_prod['vehicle_schedule_state_id']
					,$ar_prod['concrete_quant']
					,$material_quant
					,$material_quant
				)
			);
			
			if($ar_prod['manual_correction']!='t'){
				$this->getDbLinkMaster()->query(
					sprintf(
						"UPDATE productions
						SET manual_correction = TRUE
						WHERE production_site_id=%d AND production_id=%d"
						,$production_site_id
						,$production_id					
					)
				);
			}
						
			$this->getDbLinkMaster('COMMIT');
		}
		catch(Exception $e){
			$this->getDbLinkMaster('ROLLBACK');
			throw $e;
		}
	}	

</xsl:template>

</xsl:stylesheet>
