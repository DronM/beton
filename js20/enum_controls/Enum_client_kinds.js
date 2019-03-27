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
	var multy_lang_values = {"ru_buyer":"Клиент"
,"ru_acc":"Бухгалтерия"
,"ru_else":"Прочие"
};
	options.options = [{"value":"buyer",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"buyer"],
checked:(options.defaultValue&&options.defaultValue=="buyer")}
,{"value":"acc",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"acc"],
checked:(options.defaultValue&&options.defaultValue=="acc")}
,{"value":"else",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"else"],
checked:(options.defaultValue&&options.defaultValue=="else")}
];
	
	Enum_client_kinds.superclass.constructor.call(this,id,options);
	
}
extend(Enum_client_kinds,EditSelect);

