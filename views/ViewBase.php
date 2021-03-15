<?php
require_once(FRAME_WORK_PATH.'basic_classes/ViewHTMLXSLT.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelStyleSheet.php');
require_once(FRAME_WORK_PATH.'basic_classes/ModelJavaScript.php');

require_once(FRAME_WORK_PATH.'basic_classes/ModelTemplate.php');
require_once(USER_CONTROLLERS_PATH.'Constant_Controller.php');
require_once(USER_CONTROLLERS_PATH.'MainMenuConstructor_Controller.php');


			
if (file_exists('models/MainMenu_Model_admin.php')){
require_once('models/MainMenu_Model_admin.php');
}
			
if (file_exists('models/MainMenu_Model_owner.php')){
require_once('models/MainMenu_Model_owner.php');
}
			
if (file_exists('models/MainMenu_Model_boss.php')){
require_once('models/MainMenu_Model_boss.php');
}
			
if (file_exists('models/MainMenu_Model_operator.php')){
require_once('models/MainMenu_Model_operator.php');
}
			
if (file_exists('models/MainMenu_Model_manager.php')){
require_once('models/MainMenu_Model_manager.php');
}
			
if (file_exists('models/MainMenu_Model_dispatcher.php')){
require_once('models/MainMenu_Model_dispatcher.php');
}
			
if (file_exists('models/MainMenu_Model_accountant.php')){
require_once('models/MainMenu_Model_accountant.php');
}
			
if (file_exists('models/MainMenu_Model_lab_worker.php')){
require_once('models/MainMenu_Model_lab_worker.php');
}
			
if (file_exists('models/MainMenu_Model_supplies.php')){
require_once('models/MainMenu_Model_supplies.php');
}
			
if (file_exists('models/MainMenu_Model_sales.php')){
require_once('models/MainMenu_Model_sales.php');
}
			
if (file_exists('models/MainMenu_Model_plant_director.php')){
require_once('models/MainMenu_Model_plant_director.php');
}
			
if (file_exists('models/MainMenu_Model_supervisor.php')){
require_once('models/MainMenu_Model_supervisor.php');
}
			
if (file_exists('models/MainMenu_Model_vehicle_owner.php')){
require_once('models/MainMenu_Model_vehicle_owner.php');
}
			
if (file_exists('models/MainMenu_Model_client.php')){
require_once('models/MainMenu_Model_client.php');
}
		
class ViewBase extends ViewHTMLXSLT {	

	protected static function getMenuClass(){
		//USER_MODELS_PATH
		$menu_class = NULL;
		$fl = NULL;
		if (file_exists($fl = OUTPUT_PATH.'MainMenu_Model_'.$_SESSION['user_id'].'.php')){
			$menu_class = 'MainMenu_Model_'.$_SESSION['user_id'];
		}
		else if (file_exists($fl = OUTPUT_PATH.'MainMenu_Model_'.$_SESSION['role_id'].'_'.$_SESSION['user_id'].'.php')){
			$menu_class = 'MainMenu_Model_'.$_SESSION['role_id'].'_'.$_SESSION['user_id'];
		}
		else if (file_exists($fl = OUTPUT_PATH.'MainMenu_Model_'.$_SESSION['role_id'].'.php')){
			$menu_class = 'MainMenu_Model_'.$_SESSION['role_id'];
		}
		if (!is_null($menu_class) && !is_null($fl)){
			require_once($fl);
		}
		return $menu_class;
	}

	protected function addMenu(&$models){
		if (isset($_SESSION['role_id'])){
			//USER_MODELS_PATH
			$menu_class = self::getMenuClass();
			if (is_null($menu_class)){
				//no menu exists yet
				if (!$GLOBALS['dbLink']){
					throw new Exception('Db link for addMenu is not defined!');
				}
				
				$contr = new MainMenuConstructor_Controller($GLOBALS['dbLink']);
				$contr->genMenuForUser($_SESSION['user_id'], $_SESSION['role_id']);
				$menu_class = self::getMenuClass();
				if (is_null($menu_class)){
					throw new Exception('No menu found!');
				}				
			}
			$models['mainMenu'] = new $menu_class();
		}	
	}
	
	protected function addConstants(&$models){
		if (isset($_SESSION['role_id'])){

			if (!$GLOBALS['dbLink']){
				throw new Exception('Db link for addConstants is not defined!');
			}
		
			$contr = new Constant_Controller($GLOBALS['dbLink']);
			$list = array('doc_per_page_count','grid_refresh_interval','order_grid_refresh_interval','min_quant_for_ship_cost','def_lang');
			$models['ConstantValueList_Model'] = $contr->getConstantValueModel($list);						
		}	
	}

	public function __construct($name){
		parent::__construct($name);
		
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/icons/icomoon/styles.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/bootstrap.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/core.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/components.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/colors.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'assets/css/icons/fontawesome/styles.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'custom-css/easyTree.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.standalone.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'ext/chart.js-2.8.0/Chart.min.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'custom-css/style.css'));
		$this->addCssModel(new ModelStyleSheet(USER_JS_PATH.'custom-css/print.css'));
	
		if (!DEBUG){
			$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/libraries/jquery.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/libraries/bootstrap.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/plugins/loaders/blockui.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/app.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.ru.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/cleave/cleave.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/cleave/cleave-phone.ru.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/mustache/mustache.min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/jshash-2.2/md5-min.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/OpenLayers/OpenLayers.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/chart.js-2.8.0/Chart.min.js'));
			$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'lib.js'));
			$script_id = VERSION;
		}
		else{		
			
		
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/libraries/jquery.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/libraries/bootstrap.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/plugins/loaders/blockui.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'assets/js/core/app.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/bootstrap-datepicker/bootstrap-datepicker.ru.min.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'jquery.maskedinput.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/cleave/cleave.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/cleave/cleave-phone.ru.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/mustache/mustache.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/jshash-2.2/md5-min.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/DragnDrop/DragMaster.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/DragnDrop/DragObject.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/DragnDrop/DropTarget.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/GooglePolylineEncode.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/extend.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/App.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/AppWin.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/CommonHelper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/DOMHelper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/DateHelper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/EventHelper.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FatalException.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/DbException.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/VersException.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ConstantManager.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/SessionVarManager.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/CookieManager.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ServConnector.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/AppSrv.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/AppSrv.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Response.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ResponseXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ResponseJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/PublicMethod.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/PublicMethodServer.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ControllerObj.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ControllerObjServer.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ControllerObjClient.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelObjectXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelServRespXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelObjectJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelServRespJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelXMLTree.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelJSONTree.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Validator.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorString.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorBool.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorInterval.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorFloat.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorEnum.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorArray.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorEmail.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ValidatorXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/Field.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldString.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldEnum.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldBool.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldDateTimeTZ.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldBigInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldSmallInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldFloat.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldPassword.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldText.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldInterval.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldJSON.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldJSONB.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldArray.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldXML.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/FieldBytea.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/ModelFilter.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/RefType.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'core/rs_ru.js'));
	}

		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/DataBinding.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Command.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/CommandBinding.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Control.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/Control.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ControlContainer.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ControlContainer.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewAjx.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewAjxList.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Calculator.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/Calculator.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Button.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonCtrl.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonEditCtrl.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonEditCtrl.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonCalc.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonCalc.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonCalendar.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonCalendar.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonClear.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonClear.rs_ru.js'));
	}

		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ButtonCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonExpToExcel.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonExpToExcel.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonExpToPDF.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonExpToPDF.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonOpen.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonOpen.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonInsert.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonInsert.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonPrint.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonPrint.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonPrintList.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonPrintList.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonSelectRef.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonSelectRef.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonSelectDataType.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonSelectDataType.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonMakeSelection.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonMakeSelection.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonToggle.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonCall.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonCall.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Label.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Edit.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/Edit.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRefMultyType.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditRefMultyType.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditString.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditText.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditNum.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditInt.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditFloat.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditMoney.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPhone.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditEmail.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPercent.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditInterval.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPassword.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditCheckBox.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditContainer.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditContainer.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRadioGroup.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRadio.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditSelectRef.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditSelectRef.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditSelectOption.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditSelectOptionRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRadioGroupRef.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditRadioGroupRef.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/PrintObj.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditModalDialog.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditModalDialog.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ControlForm.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/HiddenKey.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditJSON.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditFile.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditFile.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditCompound.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditCompound.rs_ru.js'));
	}

		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ControlDate.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumn.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnBool.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnPhone.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnEmail.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnFloat.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnByte.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnEnum.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridColumnInterval.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCell.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellHead.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellFoot.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellPhone.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCellPhone.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellDetailToggle.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCellDetailToggle.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridHead.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridRow.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridFoot.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridBody.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Grid.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/Grid.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridSearchInf.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridSearchInf.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/VariantStorage.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCommands.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdContainer.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdContainer.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdContainerAjx.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdContainerObj.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdInsert.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdInsert.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdEdit.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdEdit.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdCopy.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdCopy.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdDelete.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdDelete.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdColManager.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdColManager.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdPrint.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdPrint.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdRefresh.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdRefresh.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdPrintObj.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdSearch.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdSearch.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdExport.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdExport.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdExportExcelLocal.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdExportExcelLocal.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdAllCommands.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdAllCommands.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdDOCUnprocess.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdDOCUnprocess.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdDOCShowActs.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdDOCShowActs.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdRowUp.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdRowUp.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdRowDown.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdRowDown.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdFilter.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdFilter.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdFilterView.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdFilterView.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdFilterSave.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdFilterSave.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCmdFilterOpen.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCmdFilterOpen.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridColManager.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridColManager.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridColParam.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridColParam.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridColVisibility.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridColVisibility.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridColOrder.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridColOrder.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/VariantStorageSaveView.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/VariantStorageSaveView.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/VariantStorageOpenView.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/VariantStorageOpenView.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridAjx.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridAjxScroll.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/TreeAjx.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridAjxDOCT.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridAjxMaster.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCommandsAjx.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCommandsAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCommandsDOC.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridCommandsDOC.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridPagination.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridPagination.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridFilterInfo.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridFilter.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/GridFilter.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPeriodDate.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/EditPeriodDate.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/EditPeriodDateTime.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonOK.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonOK.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonSave.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonSave.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonCancel.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonCancel.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewObjectAjx.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewObjectAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewGridEditInlineAjx.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewGridEditInlineAjx.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewDOC.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewDOC.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowPrint.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowPrint.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowQuestion.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowQuestion.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowSearch.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowSearch.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowForm.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowForm.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowFormObject.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowFormObject.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowFormModalBS.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowFormModalBS.rs_ru.js'));
	}

		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowMessage.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowTempMessage.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellHeadDOCProcessed.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellHeadDOCDate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/GridCellHeadDOCNumber.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/actb.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/actb.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/RepCommands.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/RepCommands.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewReport.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ViewReport.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/PopUpMenu.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/PopOver.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/PeriodSelect.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/PeriodSelect.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WindowAbout.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/WindowAbout.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/MainMenuTree.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/MainMenuTree.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ButtonOrgSearch.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ButtonOrgSearch.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ConstantGrid.js'));
			
	if (
	(isset($_SESSION['locale_id']) && $_SESSION['locale_id']=='ru')
	||
	(!isset($_SESSION['locale_id']) && DEF_LOCALE=='ru')
	){
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/rs/ConstantGrid.rs_ru.js'));
	}

		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/Captcha.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ViewTemplate.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/ToolTip.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controls/WaitControl.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/User_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Constant_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Enum_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Client_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Supplier_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DOCMaterialProcurement_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ConcreteType_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Destination_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Driver_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Order_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RawMaterial_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RawMaterialConsRateDate_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RawMaterialConsRate_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Shipment_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Vehicle_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/VehicleSchedule_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Graph_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Shift_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Lang_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/SMSPattern_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/LabData_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/LabEntry_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/LabEntryDetail_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RawMaterialProcurUpload_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RAMaterialConsumption_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DOCMaterialInventory_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/DOCMaterialInventoryDOCTMaterial_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RawMaterialProcurRate_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/OrderFromClient_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Caller_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RawMaterialStoreUserData_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Employee_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/EmployeeWorkTimeSchedule_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/AstCall_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/UserMacAddress_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ClientTel_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ClientType_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ClientComeFrom_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/PumpVehicle_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/PumpPrice_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/PumpPriceValue_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Quarry_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/SandQuarryVal_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/StoneQuarryVal_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/SpecialistRequest_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/SiteFeedBack_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/EmailTemplate_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ClientValidDuplicate_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/OrderPump_Controller.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/Login_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/About_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/PasswordRecovery_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConstantList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ViewList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MainMenuConstructorList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MainMenuConstructor_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/LoginList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/LoginDeviceList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/UserList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/UserDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/UserProfile_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MailForSendingList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MailForSending_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/UserMacAddressList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/EmployeeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientComeFromList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientTypeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentTimeNormList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DriverList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/SupplierDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/SupplierList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleScheduleDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleScheduleList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/QuarryList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/LangList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OrderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OrderForSelectList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentForVehOwnerList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentForClientVehOwnerList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentForClientList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OrderForClientList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentTimeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentDateList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/AstCallList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DOCMaterialProcurementList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DOCMaterialProcurementDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DOCMaterialProcurementShiftList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentForOrderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialConsRateDateList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialConsRateList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OrderPumpList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OrderDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OrderMakeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConcreteTypeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DestinationList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DestinationDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/PumpVehicleList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/PumpPriceList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/PumpPriceValueList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleScheduleMakeOrderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialProcurUpload_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialProcurRateList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/Map_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleStopsReport_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleScheduleReportAll_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ScheduleGen_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/DriverCheatReport_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RouteToDestAvgTimeRep_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleEfficiency_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OperatorList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleRun_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ProductionSiteList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ProductionSiteForEditList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipQuantForCostGradeList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/SupplierOrderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialProcurUploadList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RAMaterialConsumptionDateList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RAMaterialConsumptionDocList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/AstIncomeCall_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/AstIncomeUnknownCall_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/SMSForSendingList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/SMSPatternList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/SMSPatternDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/SMSPatternUserPhoneList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/TrackerZoneControlList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/AssignedVehicleList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/AstCallClientCallHistoryList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/AstCallClientShipHistoryList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OrderCalc_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientTelList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/EmployeeWorkTimeScheduleList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ClientValidDuplicateList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/LabEntryReportList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/AstCallManagerReport_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentDialog_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/SandQuarryValList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/StoneQuarryValList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/LabEntryItemOnRatePeriodReport_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/LabEntryItemReport_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/LabEntryAvgReport_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentForDriverCostHeaderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentForDriverCostList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentForOwnerCostHeaderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentForOwnerCostList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConcreteCostHeaderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConcreteCostList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConcreteCostForOwnerHeaderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConcreteCostForOwnerList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleOwnerList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleOwnerConcretePriceList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleOwnerClientList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentCancelationList.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentPumpList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ShipmentPumpForVehOwnerList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/UserOperatorList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/VehicleOwnerTotReport_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MatTotalList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MatCorrectList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ConcreteTypeMapToProductionList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/UserMapToProductionList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialMapToProductionList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MaterialFactConsumptionUpload_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MaterialFactConsumptionList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MaterialFactConsumptionRolledList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MaterialFactConsumptionCorretionList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MaterialFactBalanceCorretionList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/LabEntryList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/LabEntryDetailList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/OrderMakeForLabList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/CementSiloList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/CementSiloForOrderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/MaterialStoreForOrderList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ProductionList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ProductionVehicleCorrectionList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ProductionMaterialList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/ELKONLogList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/CementSiloBalanceResetList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RepMaterialFactConsumption_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RepMaterialAction_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RepMaterialConsToleranceViolation_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialPriceList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RawMaterialPriceForNormList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/RepMaterialAvgConsumptionOnCtp_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/GPSTrackerList_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/StoreMapToProductionSiteList_View.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ViewList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/MainMenuConstructor_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/User_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/UserList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/SupplierDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/VehicleDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/VehicleScheduleDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DriverList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/OrderDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/Client_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ClientList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DestinationList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/Destination_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/PumpVehicleList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/PumpVehicle_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/VehicleList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/Vehicle_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/VehicleScheduleMakeOrderList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/SupplierList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/SMSPatternDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ClientDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ShipmentDialog_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/QuarryList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/VehicleOwnerList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/OrderList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/ShipmentList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/RawMaterial_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/RawMaterialConsRateDateList_Form.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'forms/DOCMaterialProcurementDialog_Form.js'));
		
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'tmpl/App.templates.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/App.enums.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/App.predefinedItems.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ErrorControl.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/AppBeton.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/Pagination.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ViewSectionSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/UserEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ViewEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/UserNameEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/UserPwdEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/rs/UserPwdEdit.rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DriverEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleOwnerEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/MakeEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/FeatureEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/TrackerEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/LangEditRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/GPSTrackerRef.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditPeriodShift.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditPeriodMonth.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditPeriodWeek.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditPeriodDateShift.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/PlantLoadGraphControl.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientTypeEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientComeFromEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientNameEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientNameFullEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ConcreteTypeEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DestinationEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DestinationForClientEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DestinationForOrderEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DestinationSearchEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/PumpVehicleEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleScheduleEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/PumpPriceEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/OrderDescrEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/OrderTimeSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/AvailOrderTimeControl.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/SupplierEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleScheduleGridCmdSetFree.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleScheduleGridCmdSetOut.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleScheduleGridCmdShowPosition.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/PrintInvoiceBtn.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ShipmentGridCmdPrintInvoice.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ShipmentGridCmdChangeOrder.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ShipmentGridCmdDelete.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/RawMaterialConsRateCalcBtn.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/RawMaterialConsRateDateGridCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/RawMaterialConsRateGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/Statistics_View.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleRunGridCmdShowMap.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditMoneyEditable.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/OrderMakeGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ProductionSiteEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/DOCMaterialProcurementShiftGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/MaterialSelect.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/RAMaterialConsumptionDateGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/RAMaterialConsumptionDocGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/PeriodSelectBeton.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EditColorPalette.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/AssignedVehicleGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/Weather.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleDriverForSchedGenGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/EmployeeWorkTimeScheduleGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/QuarryEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/OrderEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ShipmentEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ConcreteCostForOwnerHeadEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ShipmentForVehOwnerCmdSetAgreed.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ShipmentPumpForVehOwnerCmdSetAgreed.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/MatTotalGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/MatCorrectGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/TelListGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleScheduleMakeOrderGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/MaterialMakeOrderGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/OwnerListGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ClientLocalListGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/PumpVehiclePriceListGrid.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/CementSiloEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ProductionSiteCmdLoadProduction.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ProductionMaterialListGridInsertCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ProductionMaterialListGridDelCmd.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/RawMaterialConsRateDateEdit.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs_ru.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'views/rs_common_ru.js'));
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/OpenLayers/OpenLayers.js'));
		
		
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'ext/chart.js-2.8.0/Chart.min.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/TrackConstants.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ObjMapLayer.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/GeoZones.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/ZoneDrawingControl.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/VehicleLayer.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/Markers.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'custom_controls/TrackLayer.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ShipmentTimeNorm_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/MainMenu_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/MainMenuConstructor_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/MainMenuContent_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/View_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/VariantStorage_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConstantList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/View_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ViewList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ViewSectionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MainMenuConstructor_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MainMenuConstructorList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MainMenuConstructorDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MainMenuContent_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VariantStorage_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VariantStorageList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/About_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/User_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Client_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Destination_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DestinationList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DestinationDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteType_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Vehicle_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Driver_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterial_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialProcurRate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialProcurRateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialProcurUpload_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialProcurUploadView_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialMinQuant_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialConsRateDate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialConsRate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialConsRateDateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/PumpPrice_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/PumpPriceValue_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/PumpVehicle_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/PumpVehicleList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Order_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderPump_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderPumpList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Offer_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderMakeList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Shipment_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentDialog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentForOrderList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentPumpList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentDateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentTimeList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentOperator_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleSchedule_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OutComment_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleScheduleList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleScheduleComplete_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleScheduleState_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentRep_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Supplier_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SupplierList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialProcurement_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialProcurementList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialInventory_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialInventoryList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialInventoryDOCTMaterial_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialInventoryDOCTMaterialList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialInventoryDOCTFMaterial_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RGMaterialConsuption_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RAMaterialConsumption_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RAMaterialConsumptionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RGMaterial_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RAMaterial_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Shift_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Lang_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SMSPattern_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SMSPatternList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleFeatureList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleMakeList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleOwnerList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LabData_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LabDataList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LabEntry_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LabEntryList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LabEntryDetail_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LabEntryDetailList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderFromClient_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderFromClientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SupplierOrder_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialStoreUserData_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialStoreUserDataList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Employee_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/EmployeeWorkTimeSchedule_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/EmployeeWorkTimeScheduleList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AstCall_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AstCallList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AstCallClientHistList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AstCallClientShipHistList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserMacAddress_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserMacAddressList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientTel_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientType_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientComeFrom_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientDebt_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Quarry_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SandQuarryVal_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SandQuarryValList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/StoneQuarryVal_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/StoneQuarryValList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialObnul_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SpecialistRequest_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SpecialistRequestList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SiteFeedBack_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SiteFeedBackList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/CarTrackingMalfucntion_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MailForSending_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SMSForSending_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/EmailTemplate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/EmailTemplateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientValidDuplicate_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientValidDuplicateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentTimeNorm_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcretePrice_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_locales.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_locales.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_role_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_role_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_data_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_data_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_role_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_role_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_unload_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_unload_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_vehicle_states.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_vehicle_states.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_sms_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_sms_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_email_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_email_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_doc_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_doc_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_reg_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_reg_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_call_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_call_types.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_client_kinds.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_client_kinds.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/Enum_offer_results.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'enum_controls/EnumGridColumn_offer_results.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/About_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MailForSendingAttachment_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MatTotals_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleScheduleMakeOrderList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehFeaturesOnDateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderClient_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderAvailSpots_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderDescr_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OperatorList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleRun_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/TimeZoneLocale_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserProfile_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Captcha_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ProductionSite_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ProductionSite_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipQuantForCostGrade_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ShipQuantForCostGrade_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialProcurementShiftList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RAMaterialConsumptionDateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/SMSForSending_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SMSForSendingList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SMSPatternUserPhone_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/SMSPatternUserPhone_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/SMSPatternUserPhoneList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/TrackerZoneControl_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/TrackerZoneControl_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/TrackerZoneControlList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AssignedVehicleList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Weather_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Weather_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AstCallActiveList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AstCallClientCallHistoryList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AstCallClientShipHistoryList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/AstCallCurrent_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientTelList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/VehicleDriverForSchedGen_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleDriverForSchedGen_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/PumpVehicleWorkList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentForDriverCostHeader_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentForDriverCost_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentForOwnerCostHeader_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentForOwnerCost_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ShipmentForDriverCostHeader_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ShipmentForDriverCost_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ShipmentForOwnerCostHeader_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ShipmentForOwnerCost_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteCostHeader_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteCost_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ConcreteCostHeader_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ConcreteCost_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteCostList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteTypeList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleOwner_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/VehicleOwner_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentCancelations_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ShipmentCancelation_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentCancelation_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentCancelationList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentPumpForVehOwnerList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentForVehOwnerList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserOperatorList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentForClientVehOwnerList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ConcreteCostForOwnerHeader_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ConcreteCostForOwner_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteCostForOwnerHeader_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteCostForOwner_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteCostForOwnerList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleOwnerConcretePrice_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/VehicleOwnerConcretePrice_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleOwnerConcretePriceList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleOwnerClient_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/VehicleOwnerClient_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleOwnerClientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Login_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Login_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LoginList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Session_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShippedVehicleList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/TelList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RAMaterialConsumptionDocList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/TelList_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteTypeMapToProduction_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialMapToProduction_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialFactConsumption_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ConcreteTypeMapToProduction_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RawMaterialMapToProduction_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialMapToProductionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ConcreteTypeMapToProductionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/MaterialFactConsumption_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialFactConsumptionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialFactConsumptionRolledList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialConsRateList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderMakeForLabList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LabEntry30DaysList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/CementSilo_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RGCement_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RACement_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RGMaterialFact_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RAMaterialFact_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/CementSilo_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/CementSiloList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleOwnerHistory_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleOwnerHistoryList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/OwnerList_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OwnerList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/PumpVehiclePriceList_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/PumpVehiclePriceList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/CementSiloForOrderList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ELKONServer_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ELKONServer_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ELKONLog_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ELKONLog_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Production_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/Production_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ProductionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ProductionSiteList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ProductionSiteForEditList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ELKONLogList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserMapToProduction_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/UserMapToProductionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/UserMapToProduction_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/MaterialFactConsumptionCorretion_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialFactConsumptionCorretion_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialFactConsumptionCorretionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ProductionMaterialList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialFactBalanceCorretion_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialFactBalanceCorretionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/MaterialFactBalanceCorretion_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/CementSiloBalanceReset_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/CementSiloBalanceReset_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/CementSiloBalanceResetList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialActionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ProductionVehicleCorrection_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ProductionVehicleCorrection_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ProductionVehicleCorrectionList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ProductionComment_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialConsToleranceViolationList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ProductionComment_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/ClientLocalList_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ClientLocalList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/ShipmentForClientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/OrderForClientList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RawMaterialPrice_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialPrice_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialPriceList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/RawMaterialPriceForNorm_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialPriceForNorm_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/RawMaterialPriceForNormList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/GPSTracker_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/GPSTracker_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/StoreMapToProductionSite_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/StoreMapToProductionSite_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/StoreMapToProductionSiteList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/MaterialStoreForOrderList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/SessionVar_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DestinationForOrderList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/VehicleRouteCashe_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/LoginDevice_Controller.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LoginDeviceList_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/LoginDeviceBan_Model.js'));
		$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'controllers/LoginDeviceBan_Controller.js'));
	$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/Event_Model.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialProcurementDriverList_Model.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialProcurementVehicleList_Model.js'));$this->addJsModel(new ModelJavaScript(USER_JS_PATH.'models/DOCMaterialProcurementStoreList_Model.js'));			
			if (isset($_SESSION['scriptId'])){
				$script_id = $_SESSION['scriptId'];
			}
			else{
				$script_id = VERSION;
			}			
		}
		
		$this->getVarModel()->addField(new Field('role_id',DT_STRING));
		$this->getVarModel()->addField(new Field('user_id',DT_INT));
		$this->getVarModel()->addField(new Field('user_name',DT_STRING));		
		
		if (isset($_SESSION['role_id'])){
			$this->getVarModel()->addField(new Field('tel_ext',DT_STRING));
			
			//app server
			$this->getVarModel()->addField(new Field('app_srv_host',DT_STRING));
			$this->getVarModel()->addField(new Field('app_srv_port',DT_STRING));
			//$this->getVarModel()->addField(new Field('app_srv_protocol',DT_STRING));								
			
			$this->getVarModel()->addField(new Field('app_id',DT_STRING));		
			
			if(isset($_SESSION['token'])){
				$this->getVarModel()->addField(new Field('token',DT_STRING));
				if(defined('SESSION_EXP_SEC') && intval(SESSION_EXP_SEC)){
					$this->getVarModel()->addField(new Field('tokenr',DT_STRING));					
				}	
				$this->getVarModel()->addField(new Field('tokenExpires',DT_STRING));
			}
			
		}
		
		
		$this->getVarModel()->insert();
		$this->setVarValue('scriptId',$script_id);
		
		$currentPath = $_SERVER['PHP_SELF'];
		$pathInfo = pathinfo($currentPath);
		$hostName = $_SERVER['HTTP_HOST'];
		$protocol = isset($_SERVER['HTTPS'])? 'https://':'http://';
		$dir = $protocol.$hostName.$pathInfo['dirname'];
		if (substr($dir,strlen($dir)-1,1)!='/'){
			$dir.='/';
		}
		$this->setVarValue('basePath', $dir);
		
		$this->setVarValue('version',VERSION);		
		$this->setVarValue('debug',DEBUG);
		if (isset($_SESSION['locale_id'])){
			$this->setVarValue('locale_id',$_SESSION['locale_id']);
		}
		else if (!isset($_SESSION['locale_id']) && defined('DEF_LOCALE')){
			$this->setVarValue('locale_id', DEF_LOCALE);
		}		
		
		if (isset($_SESSION['role_id'])){
			$this->setVarValue('role_id',$_SESSION['role_id']);
			$this->setVarValue('user_id',$_SESSION['user_id']);
			$this->setVarValue('user_name',$_SESSION['user_name']);
			$this->setVarValue('curDate',round(microtime(true) * 1000));
			$this->setVarValue('tel_ext',$_SESSION['tel_ext']);
			
			$this->setVarValue('app_srv_host',APP_SERVER_HOST);
			$this->setVarValue('app_srv_port',APP_SERVER_PORT);
			//$this->setVarValue('app_srv_protocol',APP_SERVER_SECURED? 'wss':'ws');
			$this->setVarValue('app_id',APP_NAME);
			
			if(isset($_SESSION['token'])){
				$this->setVarValue('token',$_SESSION['token']);
				if(defined('SESSION_EXP_SEC') && intval(SESSION_EXP_SEC)){
					$this->setVarValue('tokenr',$_SESSION['tokenr']);					
				}
				$this->setVarValue('tokenExpires',date('Y-m-d H:i:s',$_SESSION['tokenExpires']));
			}			
			
		}
		
		
		//Global Filters
		
	}
	public function write(ArrayObject &$models,$errorCode=NULL){
		$this->addMenu($models);
		
		
		$this->addConstants($models);
		
		//titles form Config
		$models->append(new ModelVars(
			array('name'=>'Page_Model',
				'sysModel'=>TRUE,
				'id'=>'Page_Model',
				'values'=>array(
					new Field('DEFAULT_COLOR_PALETTE',DT_STRING,array('value'=>DEFAULT_COLOR_PALETTE))					
				)
			)
		));
		
		parent::write($models,$errorCode);
	}	
}	
?>