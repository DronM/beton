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
	options.options = [{"value":"order",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"order"],
checked:(options.defaultValue&&options.defaultValue=="order")}
,{"value":"material_procurement",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"material_procurement"],
checked:(options.defaultValue&&options.defaultValue=="material_procurement")}
,{"value":"shipment",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"shipment"],
checked:(options.defaultValue&&options.defaultValue=="shipment")}
,{"value":"material_fact_consumption",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"material_fact_consumption"],
checked:(options.defaultValue&&options.defaultValue=="material_fact_consumption")}
,{"value":"material_fact_consumption_correction",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"material_fact_consumption_correction"],
checked:(options.defaultValue&&options.defaultValue=="material_fact_consumption_correction")}
,{"value":"material_fact_balance_correction",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"material_fact_balance_correction"],
checked:(options.defaultValue&&options.defaultValue=="material_fact_balance_correction")}
,{"value":"cement_silo_reset",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"cement_silo_reset"],
checked:(options.defaultValue&&options.defaultValue=="cement_silo_reset")}
,{"value":"cement_silo_balance_reset",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"cement_silo_balance_reset"],
checked:(options.defaultValue&&options.defaultValue=="cement_silo_balance_reset")}
];
	
	Enum_doc_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_doc_types,EditSelect);

Enum_doc_types.prototype.multyLangValues = {"ru_order":"Заявка"
,"ru_material_procurement":"Поступление материалов"
,"ru_shipment":"Отгрузка"
,"ru_material_fact_consumption":"Фактический расход материалов"
,"ru_material_fact_consumption_correction":"Корректировка фактического расхода материалов"
,"ru_material_fact_balance_correction":"Корректировка остатка материала"
,"ru_cement_silo_reset":"Обнуление силоса"
,"ru_cement_silo_balance_reset":"Обнуление остатка силоса"
};


