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

function Enum_doc_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_material_procuremen":"Поступление материалов"
,"ru_shipment":"Отгрузка"
};
	options.options = [{"value":"material_procuremen",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"material_procuremen"],
checked:(options.defaultValue&&options.defaultValue=="material_procuremen")}
,{"value":"shipment",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"shipment"],
checked:(options.defaultValue&&options.defaultValue=="shipment")}
];
	
	Enum_doc_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_types,EditSelect);

