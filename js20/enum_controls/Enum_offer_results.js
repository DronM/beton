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

function Enum_offer_results(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"no",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"no"],
checked:(options.defaultValue&&options.defaultValue=="no")}
,{"value":"seems_no",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"seems_no"],
checked:(options.defaultValue&&options.defaultValue=="seems_no")}
,{"value":"will_think",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"will_think"],
checked:(options.defaultValue&&options.defaultValue=="will_think")}
,{"value":"make_order",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"make_order"],
checked:(options.defaultValue&&options.defaultValue=="make_order")}
];
	
	Enum_offer_results.superclass.constructor.call(this,id,options);
	
}
extend(Enum_offer_results,EditSelect);

Enum_offer_results.prototype.multyLangValues = {"ru_no":"Нет"
,"ru_seems_no":"Наверное нет"
,"ru_will_think":"Подумаю"
,"ru_make_order":"Оформить заявку"
};


