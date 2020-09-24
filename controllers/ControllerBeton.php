<?php
require_once(FRAME_WORK_PATH.'basic_classes/Controller.php');
require_once('controllers/AstCall_Controller.php');
require_once(FRAME_WORK_PATH.'basic_classes/PublicMethod.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelServResponse.php');

class ControllerBeton extends Controller {
	private $dbLink;
	
	public function __construct($dbLinkMaster,$dbLink){
		$this->dbLink = $dbLink;
		parent::__construct();
	}
	
	/* Output function
	*/
	public function write($viewClassId,$viewId,$errorCode=NULL){
		//!!!ЗВОНКИ!!!
		if (isset($_SESSION['tel_ext'])){
			
			$call = new AstCall_Controller($this->dbLink);
			$call->active_call(NULL);
			if ($call->getModelById('AstCallCurrent_Model')){
				$this->addModel($call->getModelById('AstCallCurrent_Model'));
			}
		}
		parent::write($viewClassId,$viewId,$errorCode);
		/*
		$view = new $viewClassId($viewId);
		if ($this->getStatelessClient()){
			$this->setStateVars($view);
		}
		//!!!ЗВОНКИ!!!
		if (isset($_SESSION['tel_ext'])){
			
			$call = new AstCall_Controller($this->dbLink);
			$call->active_call(NULL);
			if ($call->getModelById('AstCallCurrent_Model')){
				$this->addModel($call->getModelById('AstCallCurrent_Model'));
			}
		}
		
		$view->write($this->getModels());
		*/
	}
}
?>
