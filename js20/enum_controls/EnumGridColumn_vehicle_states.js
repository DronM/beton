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

	options.multyLangValues["ru"]["at_dest"] = "на объекте";

	options.multyLangValues["ru"]["left_for_base"] = "едет на базу";

	options.multyLangValues["ru"]["out_from_shift"] = "сошёл со см.";

	options.multyLangValues["ru"]["out"] = "сошёл";

	options.multyLangValues["ru"]["shift_added"] = "доб.смена";

	
	options.ctrlClass = options.ctrlClass || Enum_vehicle_states;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_vehicle_states.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_vehicle_states,GridColumnEnum);

