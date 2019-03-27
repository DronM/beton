/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Grid column Enumerator class. Created from template build/templates/js/EnumGridColumn_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends GridColumnEnum
 
 * @requires core/extend.js
 * @requires controls/GridColumnEnum.js
 
 * @param {object} options
 */

function EnumGridColumn_email_types(options){
	options = options || {};
	
	options.multyLangValues = {};
	
	options.multyLangValues["ru"] = {};

	options.multyLangValues["ru"]["new_account"] = "Новая учетная запись";

	options.multyLangValues["ru"]["reset_pwd"] = "Сброс пароля пользователя";
EnumGridColumn_email_types.superclass.constructor.call(this,options);
	
}
extend(EnumGridColumn_email_types,GridColumnEnum);

