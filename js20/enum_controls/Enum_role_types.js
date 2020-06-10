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

function Enum_role_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	var multy_lang_values = {"ru_admin":"Администратор"
,"ru_owner":"Администратор"
,"ru_boss":"Руководитель"
,"ru_operator":"Оператор"
,"ru_manager":"Менеджер"
,"ru_dispatcher":"Диспетчер"
,"ru_accountant":"Бухгалтер"
,"ru_lab_worker":"Лаборант"
,"ru_supplies":"Снабжение"
,"ru_sales":"Реализация"
,"ru_plant_director":"Нач.базы"
,"ru_supervisor":"Смотрящий"
,"ru_vehicle_owner":"Владелец траспорта"
,"ru_client":"Контрагент"
};
	options.options = [{"value":"admin",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"admin"],
checked:(options.defaultValue&&options.defaultValue=="admin")}
,{"value":"owner",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"owner"],
checked:(options.defaultValue&&options.defaultValue=="owner")}
,{"value":"boss",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"boss"],
checked:(options.defaultValue&&options.defaultValue=="boss")}
,{"value":"operator",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"operator"],
checked:(options.defaultValue&&options.defaultValue=="operator")}
,{"value":"manager",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"manager"],
checked:(options.defaultValue&&options.defaultValue=="manager")}
,{"value":"dispatcher",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"dispatcher"],
checked:(options.defaultValue&&options.defaultValue=="dispatcher")}
,{"value":"accountant",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"accountant"],
checked:(options.defaultValue&&options.defaultValue=="accountant")}
,{"value":"lab_worker",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"lab_worker"],
checked:(options.defaultValue&&options.defaultValue=="lab_worker")}
,{"value":"supplies",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"supplies"],
checked:(options.defaultValue&&options.defaultValue=="supplies")}
,{"value":"sales",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"sales"],
checked:(options.defaultValue&&options.defaultValue=="sales")}
,{"value":"plant_director",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"plant_director"],
checked:(options.defaultValue&&options.defaultValue=="plant_director")}
,{"value":"supervisor",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"supervisor"],
checked:(options.defaultValue&&options.defaultValue=="supervisor")}
,{"value":"vehicle_owner",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"vehicle_owner"],
checked:(options.defaultValue&&options.defaultValue=="vehicle_owner")}
,{"value":"client",
"descr":multy_lang_values[window.getApp().getLocale()+"_"+"client"],
checked:(options.defaultValue&&options.defaultValue=="client")}
];
	
	Enum_role_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_role_types,EditSelect);

