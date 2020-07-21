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

function Enum_client_kinds(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"buyer",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"buyer"],
checked:(options.defaultValue&&options.defaultValue=="buyer")}
,{"value":"acc",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"acc"],
checked:(options.defaultValue&&options.defaultValue=="acc")}
,{"value":"else",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"else"],
checked:(options.defaultValue&&options.defaultValue=="else")}
];
	
	Enum_client_kinds.superclass.constructor.call(this,id,options);
	
}
extend(Enum_client_kinds,EditSelect);

Enum_client_kinds.prototype.multyLangValues = {"ru_buyer":"Клиент"
,"ru_acc":"Бухгалтерия"
,"ru_else":"Прочие"
};


