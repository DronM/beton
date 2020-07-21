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
	options.options = [{"value":"users",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"users"],
checked:(options.defaultValue&&options.defaultValue=="users")}
];
	
	Enum_data_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_data_types,EditSelect);

Enum_data_types.prototype.multyLangValues = {"ru_users":"Пользователи"
};


