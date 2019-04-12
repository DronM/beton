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

function Enum_sms_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_order":"заявка"
,"ru_ship":"отгрузка"
,"ru_remind":"напоминание"
,"ru_procur":"поставка"
,"ru_order_for_pump_ins":"заявка для насоса (новая)"
,"ru_order_for_pump_upd":"заявка для насоса (изменена)"
,"ru_order_for_pump_del":"заявка для насоса (удалена)"
,"ru_remind_for_pump":"напоминание для насоса"
,"ru_client_thank":"благодарность клиенту"
,"ru_vehicle_zone_violation":"Въезд в запрещенную зону"
,"ru_vehicle_tracker_malfunction":"Нерабочий трекер"
,"ru_efficiency_warn":"Низская эффективность"
,"ru_material_balance":"Остатки материалов"
};
	options.options = [{"value":"order",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"order"],
checked:(options.defaultValue&&options.defaultValue=="order")}
,{"value":"ship",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"ship"],
checked:(options.defaultValue&&options.defaultValue=="ship")}
,{"value":"remind",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"remind"],
checked:(options.defaultValue&&options.defaultValue=="remind")}
,{"value":"procur",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"procur"],
checked:(options.defaultValue&&options.defaultValue=="procur")}
,{"value":"order_for_pump_ins",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"order_for_pump_ins"],
checked:(options.defaultValue&&options.defaultValue=="order_for_pump_ins")}
,{"value":"order_for_pump_upd",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"order_for_pump_upd"],
checked:(options.defaultValue&&options.defaultValue=="order_for_pump_upd")}
,{"value":"order_for_pump_del",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"order_for_pump_del"],
checked:(options.defaultValue&&options.defaultValue=="order_for_pump_del")}
,{"value":"remind_for_pump",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"remind_for_pump"],
checked:(options.defaultValue&&options.defaultValue=="remind_for_pump")}
,{"value":"client_thank",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"client_thank"],
checked:(options.defaultValue&&options.defaultValue=="client_thank")}
,{"value":"vehicle_zone_violation",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"vehicle_zone_violation"],
checked:(options.defaultValue&&options.defaultValue=="vehicle_zone_violation")}
,{"value":"vehicle_tracker_malfunction",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"vehicle_tracker_malfunction"],
checked:(options.defaultValue&&options.defaultValue=="vehicle_tracker_malfunction")}
,{"value":"efficiency_warn",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"efficiency_warn"],
checked:(options.defaultValue&&options.defaultValue=="efficiency_warn")}
,{"value":"material_balance",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"material_balance"],
checked:(options.defaultValue&&options.defaultValue=="material_balance")}
];
	
	Enum_sms_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_sms_types,EditSelect);

