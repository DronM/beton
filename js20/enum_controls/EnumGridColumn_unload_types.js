/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_unload_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["pump"] = "насос";

	options.multyLangValues["ru"]["band"] = "лента";

	options.multyLangValues["ru"]["none"] = "нет";
EnumGridColumn_unload_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_unload_types,GridColumnEnum);

