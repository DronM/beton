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



require_once(FRAME_WORK_PATH.'basic_classes/SessionVarManager.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelVars.php');

class SessionVar_Controller extends ControllerSQL{
	public function __construct($dbLinkMaster=NULL,$dbLink=NULL){
		parent::__construct($dbLinkMaster,$dbLink);
			
		$pm = new PublicMethod('set_value');
		
				
	$opts=array();
	
		$opts['required']=TRUE;				
		$pm->addParam(new FieldExtString('id',$opts));
	
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('val',$opts));
	
			
		$this->addPublicMethod($pm);

			
		$pm = new PublicMethod('get_values');
		
				
	$opts=array();
					
		$pm->addParam(new FieldExtString('id_list',$opts));
	
				
	$opts=array();
	
		$opts['length']=1;				
		$pm->addParam(new FieldExtString('field_sep',$opts));
	
			
		$this->addPublicMethod($pm);

		
	}	
	
	/**
	 * getting value for client
	 */
	public function get_values($pm){
	
		$id_list = $this->getExtVal($pm,'id_list');
		$field_sep = $this->getExtVal($pm,'field_sep');
		
		$model = new Model(
			array('name'=>'SessionVarList_Model',
				'id'=>'SessionVarList_Model'
			)
		);
		$model->addField(new Field('id',DT_STRING));
		$model->addField(new Field('val',DT_STRING));
		
		if (isset($id_list)){
		
			if(!isset($field_sep)){
				$field_sep = ',';
			}
		
			$ar = explode($field_sep,$id_list);
			
			foreach($ar as $id) {
				$val = SessionVarManager::getValue($id,TRUE);
				if(is_object($val)){
					$val_str = json_encode($val);
				}
				else{
					$val_str = $val;
				}
				
				//add to return model
				$model->insert(array(
					new Field('id',DT_STRING,array('value'=>$id))
					,new Field('val',DT_STRING,array('value'=>$val_str))	
				));
			}
		}
		
		$this->addModel($model);		
	}
	
	/**
	 * setting value from client
	 */
	public function set_value($pm){
		$id = $this->getExtVal($pm,'id');
		$val_str = $this->getExtVal($pm,'val');
		$n = strlen($val_str);
		if($n && substr($val_str,0,1)=='{' && substr($val_str,$n-1,1)=='}'){
			//object
			$val = json_decode($val_str);
		}
		else if($n){
			$val = $val_str;
		}
		SessionVarManager::setValue($id,$val,FALSE);
	}
	
}
?>