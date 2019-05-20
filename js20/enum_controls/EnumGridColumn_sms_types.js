/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_sms_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["order"] = "заявка";

	options.multyLangValues["ru"]["ship"] = "отгрузка";

	options.multyLangValues["ru"]["remind"] = "напоминание";

	options.multyLangValues["ru"]["procur"] = "поставка";

	options.multyLangValues["ru"]["order_for_pump_ins"] = "заявка для насоса (новая)";

	options.multyLangValues["ru"]["order_for_pump_upd"] = "заявка для насоса (изменена)";

	options.multyLangValues["ru"]["order_for_pump_del"] = "заявка для насоса (удалена)";

	options.multyLangValues["ru"]["remind_for_pump"] = "напоминание для насоса";

	options.multyLangValues["ru"]["client_thank"] = "благодарность клиенту";

	options.multyLangValues["ru"]["vehicle_zone_violation"] = "Въезд в запрещенную зону";

	options.multyLangValues["ru"]["vehicle_tracker_malfunction"] = "Нерабочий трекер";

	options.multyLangValues["ru"]["efficiency_warn"] = "Низская эффективность";

	options.multyLangValues["ru"]["material_balance"] = "Остатки материалов";

	
	options.ctrlClass = options.ctrlClass || Enum_sms_types;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_sms_types.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_sms_types,GridColumnEnum);

