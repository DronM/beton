<?php
require_once(FRAME_WORK_PATH.'basic_classes/ModelSQLBeton.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLInt.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLString.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLFloat.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLTime.php');
require_once(FRAME_WORK_PATH.'basic_classes/FieldSQLBool.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelOrderSQL.php');

class Destination_Model extends ModelSQLBeton{
	
	public function __construct($dbLink){
		parent::__construct($dbLink);
		
		
		$this->setDbName('public');
		
		$this->setTableName("destinations");
			
		//*** Field id ***
		$f_opts = array();
		$f_opts['primaryKey'] = TRUE;
		$f_opts['autoInc']=TRUE;
		
		$f_opts['alias']='Код';
		$f_opts['id']="id";
						
		$f_id=new FieldSQLInt($this->getDbLink(),$this->getDbName(),$this->getTableName(),"id",$f_opts);
		$this->addField($f_id);
		//********************
		
		//*** Field name ***
		$f_opts = array();
		
		$f_opts['alias']='Наименование';
		$f_opts['length']=100;
		$f_opts['id']="name";
						
		$f_name=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"name",$f_opts);
		$this->addField($f_name);
		//********************
		
		//*** Field distance ***
		$f_opts = array();
		
		$f_opts['alias']='Расстояние';
		$f_opts['length']=15;
		$f_opts['id']="distance";
						
		$f_distance=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"distance",$f_opts);
		$this->addField($f_distance);
		//********************
		
		//*** Field time_route ***
		$f_opts = array();
		
		$f_opts['alias']='Время';
		$f_opts['id']="time_route";
						
		$f_time_route=new FieldSQLTime($this->getDbLink(),$this->getDbName(),$this->getTableName(),"time_route",$f_opts);
		$this->addField($f_time_route);
		//********************
		
		//*** Field price ***
		$f_opts = array();
		
		$f_opts['alias']='Стоимость';
		$f_opts['id']="price";
						
		$f_price=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"price",$f_opts);
		$this->addField($f_price);
		//********************
		
		//*** Field zone ***
		$f_opts = array();
		$f_opts['id']="zone";
						
		$f_zone=new FieldSQLString($this->getDbLink(),$this->getDbName(),$this->getTableName(),"zone",$f_opts);
		$this->addField($f_zone);
		//********************
		
		//*** Field special_price ***
		$f_opts = array();
		$f_opts['defaultValue']='FALSE';
		$f_opts['id']="special_price";
						
		$f_special_price=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"special_price",$f_opts);
		$this->addField($f_special_price);
		//********************
		
		//*** Field price_for_driver ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['defaultValue']='0';
		$f_opts['id']="price_for_driver";
						
		$f_price_for_driver=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"price_for_driver",$f_opts);
		$this->addField($f_price_for_driver);
		//********************
		
		//*** Field near_road_lon ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="near_road_lon";
						
		$f_near_road_lon=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"near_road_lon",$f_opts);
		$this->addField($f_near_road_lon);
		//********************
		
		//*** Field near_road_lat ***
		$f_opts = array();
		$f_opts['length']=15;
		$f_opts['id']="near_road_lat";
						
		$f_near_road_lat=new FieldSQLFloat($this->getDbLink(),$this->getDbName(),$this->getTableName(),"near_road_lat",$f_opts);
		$this->addField($f_near_road_lat);
		//********************
		
		//*** Field send_route_sms ***
		$f_opts = array();
		
		$f_opts['alias']='Отправлять СМС с маршрутом';
		$f_opts['defaultValue']='TRUE';
		$f_opts['id']="send_route_sms";
						
		$f_send_route_sms=new FieldSQLBool($this->getDbLink(),$this->getDbName(),$this->getTableName(),"send_route_sms",$f_opts);
		$this->addField($f_send_route_sms);
		//********************
	
		$order = new ModelOrderSQL();		
		$this->setDefaultModelOrder($order);		
		$direct = 'ASC';
		$order->addField($f_name,$direct);
$this->setLimitConstant('doc_per_page_count');
	}


	private function get_zone_val($val){
		if($val==''){
			return 'NULL';
		}
	
		$points = explode(',',$val);
		if (count($points)){
			array_push($points,$points[0]);
			return sprintf("ST_GeomFromText('POLYGON((%s))')",
				implode(',',$points));
		}	
	}
	
	public function update(){
		$this->setQueryId(0);
		$cond_str = '';
		$assigne_str = '';
		
		$fields = $this->getFieldIterator();
		while($fields->valid()) {
			$field = $fields->current();
			if ($field->getFieldType()==FT_DATA){
				if (!is_null($field->getValue())){
					$assigne_str.= ($assigne_str=="")? "":",";
					if ($field->getId()=='zone'){
						$assigne_str.= 'zone='.$this->get_zone_val($field->getValue());
					}
					else{
						$assigne_str.= $field->getSQLAssigne();
					}
				}
				if (!is_null($field->getOldValue())){
					$cond_str.= ($cond_str=="")? "":",";
					$cond_str.= $field->getSQLAssigneOldValue();
				}
			}
			else if ($field->getFieldType()==FT_LOOK_UP){
				if (!is_null($field->getLookUpIdValue())){
					$assigne_str.= ($assigne_str=="")? "":",";
					$assigne_str.= $field->getSQLLookUpAssigne();
				}
			}
			$fields->next();
		}
		$q = sprintf(ModelSQL::SQL_UPDATE,
			$this->getTableName(),
			$assigne_str,$cond_str
			);
		//throw new Exception($q);
		$this->getDbLink()->query($q);	
	}
	public function insert($needId=FALSE){
		$this->setQueryId(0);
		$field_str = '';
		$value_str = '';
		$ids_list = '';
		$fields = $this->getFieldIterator();
		while($fields->valid()) {
			$field = $fields->current();
			$field_data_type = $field->getFieldType();
			$needed_types = ($field_data_type==FT_DATA || $field_data_type==FT_LOOK_UP);
			$is_primary = $field->getPrimaryKey();
			$skeep = (!$needed_types
				|| $field->getReadOnly()				
				|| ($is_primary && $field->getAutoInc())
				);
				
			if ($needId && $is_primary){
				$ids_list.=($ids_list=='')? '':',';
				$ids_list.=$field->getSQLNoAlias();
			}
				
			if (!$skeep){
				$field_str.= ($field_str=='')? '':',';
				$value_str.= ($value_str=='')? '':',';				
				$field_str.= $field->getSQLNoAlias();				
				if ($field->getId()=='zone'){
					$value_str.= $this->get_zone_val($field->getValue());
				}
				else{				
					$value_str.= $field->getValueForDb();
				}
			}
			$fields->next();
		}
		$q = sprintf(ModelSQL::SQL_INSERT,
			$this->getTableName(),
			$field_str,$value_str);
		if ($needId){
			$q.=' returning '.$ids_list;
		}
		//throw new Exception('ModelSQL insert q='.$q);
		
		$query_id = $this->getDbLink()->query($q);
		$this->setQueryId($query_id);
		
		if ($needId){
			$ret = $this->getDbLink()->fetch_array($query_id);
		}
		else{
			$ret = NULL;
		}
		return $ret;
	}
	
}
?>