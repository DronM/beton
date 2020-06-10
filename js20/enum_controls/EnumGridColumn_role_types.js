/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_role_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["admin"] = "Администратор";

	options.multyLangValues["ru"]["owner"] = "Администратор";

	options.multyLangValues["ru"]["boss"] = "Руководитель";

	options.multyLangValues["ru"]["operator"] = "Оператор";

	options.multyLangValues["ru"]["manager"] = "Менеджер";

	options.multyLangValues["ru"]["dispatcher"] = "Диспетчер";

	options.multyLangValues["ru"]["accountant"] = "Бухгалтер";

	options.multyLangValues["ru"]["lab_worker"] = "Лаборант";

	options.multyLangValues["ru"]["supplies"] = "Снабжение";

	options.multyLangValues["ru"]["sales"] = "Реализация";

	options.multyLangValues["ru"]["plant_director"] = "Нач.базы";

	options.multyLangValues["ru"]["supervisor"] = "Смотрящий";

	options.multyLangValues["ru"]["vehicle_owner"] = "Владелец траспорта";

	options.multyLangValues["ru"]["client"] = "Контрагент";

	
	options.ctrlClass = options.ctrlClass || Enum_role_types;
	options.searchOptions = options.searchOptions || {};
	options.searchOptions.searchType = options.searchOptions.searchType || "on_match";
	options.searchOptions.typeChange = (options.searchOptions.typeChange!=undefined)? options.searchOptions.typeChange:false;
	
	EnumGridColumn_role_types.superclass.constructor.call(this,options);		
}
extend(EnumGridColumn_role_types,GridColumnEnum);

