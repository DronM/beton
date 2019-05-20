/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_offer_results(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["no"] = "Нет";

	options.multyLangValues["ru"]["seems_no"] = "Наверное нет";

	options.multyLangValues["ru"]["will_think"] = "Подумаю";

	options.multyLangValues["ru"]["make_order"] = "Оформить заявку";

	
	options.ctrlClass = options.ctrlClass || Enum_offer_results;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_offer_results.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_offer_results,GridColumnEnum);

