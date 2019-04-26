/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_vehicle_states(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["shift"] = "смена";

	options.multyLangValues["ru"]["free"] = "на базе";

	options.multyLangValues["ru"]["assigned"] = "назначен";

	options.multyLangValues["ru"]["busy"] = "отгружен";

	options.multyLangValues["ru"]["left_for_dest"] = "едет на объект";

	options.multyLangValues["ru"]["at_dest"] = "у клиента";

	options.multyLangValues["ru"]["left_for_base"] = "едет на базу";

	options.multyLangValues["ru"]["out_from_shift"] = "уехал со смены";

	options.multyLangValues["ru"]["out"] = "уехал";

	options.multyLangValues["ru"]["shift_added"] = "доб.смена";
EnumGridColumn_vehicle_states.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_vehicle_states,GridColumnEnum);

