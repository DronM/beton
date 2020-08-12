/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_doc_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["order"] = "Заявка";

	options.multyLangValues["ru"]["material_procurement"] = "Поступление материалов";

	options.multyLangValues["ru"]["shipment"] = "Отгрузка";

	options.multyLangValues["ru"]["material_fact_consumption"] = "Фактический расход материалов";

	options.multyLangValues["ru"]["material_fact_consumption_correction"] = "Корректировка фактического расхода материалов";

	options.multyLangValues["ru"]["material_fact_balance_correction"] = "Корректировка остатка материала";

	options.multyLangValues["ru"]["cement_silo_reset"] = "Обнуление силоса";

	options.multyLangValues["ru"]["cement_silo_balance_reset"] = "Обнуление остатка силоса";

	
	options.ctrlClass = options.ctrlClass || Enum_doc_types;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_doc_types.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_doc_types,GridColumnEnum);

