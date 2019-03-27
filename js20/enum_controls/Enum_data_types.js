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

function Enum_data_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_users":"Пользователи"
};
	options.options = [{"value":"users",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"users"],
checked:(options.defaultValue&&options.defaultValue=="users")}
];
	
	Enum_data_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_data_types,EditSelect);

