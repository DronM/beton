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

function Enum_vehicle_states(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_shift":"смена"
,"ru_free":"на базе"
,"ru_assigned":"назначен"
,"ru_busy":"отгружен"
,"ru_left_for_dest":"выехал к клиенту"
,"ru_at_dest":"у клиента"
,"ru_left_for_base":"возвращается на базу"
,"ru_out_from_shift":"уехал со смены"
,"ru_out":"уехал"
,"ru_shift_added":"добав.смена"
};
	options.options = [{"value":"shift",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"shift"],
checked:(options.defaultValue&&options.defaultValue=="shift")}
,{"value":"free",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"free"],
checked:(options.defaultValue&&options.defaultValue=="free")}
,{"value":"assigned",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"assigned"],
checked:(options.defaultValue&&options.defaultValue=="assigned")}
,{"value":"busy",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"busy"],
checked:(options.defaultValue&&options.defaultValue=="busy")}
,{"value":"left_for_dest",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"left_for_dest"],
checked:(options.defaultValue&&options.defaultValue=="left_for_dest")}
,{"value":"at_dest",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"at_dest"],
checked:(options.defaultValue&&options.defaultValue=="at_dest")}
,{"value":"left_for_base",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"left_for_base"],
checked:(options.defaultValue&&options.defaultValue=="left_for_base")}
,{"value":"out_from_shift",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"out_from_shift"],
checked:(options.defaultValue&&options.defaultValue=="out_from_shift")}
,{"value":"out",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"out"],
checked:(options.defaultValue&&options.defaultValue=="out")}
,{"value":"shift_added",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"shift_added"],
checked:(options.defaultValue&&options.defaultValue=="shift_added")}
];
	
	Enum_vehicle_states.superclass.constructor.call(this,id,options);
	
}
extend(Enum_vehicle_states,EditSelect);

