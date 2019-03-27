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

function Enum_reg_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_material":"Учет материалов"
,"ru_material_consumption":"Расход материалов"
};
	options.options = [{"value":"material",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"material"],
checked:(options.defaultValue&&options.defaultValue=="material")}
,{"value":"material_consumption",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"material_consumption"],
checked:(options.defaultValue&&options.defaultValue=="material_consumption")}
];
	
	Enum_reg_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_reg_types,EditSelect);

