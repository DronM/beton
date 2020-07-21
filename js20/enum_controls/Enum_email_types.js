/**	
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2017
 * @class
 * @classdesc Enumerator class. Created from template build/templates/js/Enum_js.xsl. !!!DO NOT MODIFY!!!
 
 * @extends EditSelect
 
 * @requires core/extend.js
 * @requires controls/EditSelect.js
 
 * @param string id 
 * @param {object} options
 */

function Enum_email_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"new_account",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"new_account"],
checked:(options.defaultValue&&options.defaultValue=="new_account")}
,{"value":"reset_pwd",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"reset_pwd"],
checked:(options.defaultValue&&options.defaultValue=="reset_pwd")}
];
	
	Enum_email_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_email_types,EditSelect);

Enum_email_types.prototype.multyLangValues = {"ru_new_account":"Новая учетная запись"
,"ru_reset_pwd":"Сброс пароля пользователя"
};


