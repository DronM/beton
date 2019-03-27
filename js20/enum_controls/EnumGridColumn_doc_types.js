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

	options.multyLangValues["ru"]["material_procuremen"] = "Поступление материалов";

	options.multyLangValues["ru"]["shipment"] = "Отгрузка";
EnumGridColumn_doc_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_doc_types,GridColumnEnum);

