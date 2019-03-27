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

function Enum_call_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_in":"Входящий"
,"ru_out":"Исходящий"
};
	options.options = [{"value":"in",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"in"],
checked:(options.defaultValue&&options.defaultValue=="in")}
,{"value":"out",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"out"],
checked:(options.defaultValue&&options.defaultValue=="out")}
];
	
	Enum_call_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_call_types,EditSelect);

