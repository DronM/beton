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

function Enum_unload_types(id,options){
	options = options || {};
	options.addNotSelected = (options.addNotSelected!=undefined)? options.addNotSelected:true;
	options.options = [{"value":"pump",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"pump"],
checked:(options.defaultValue&&options.defaultValue=="pump")}
,{"value":"band",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"band"],
checked:(options.defaultValue&&options.defaultValue=="band")}
,{"value":"none",
"descr":this.multyLangValues[window.getApp().getLocale()+"_"+"none"],
checked:(options.defaultValue&&options.defaultValue=="none")}
];
	
	Enum_unload_types.superclass.constructor.call(this,id,options);
	
}
extend(Enum_unload_types,EditSelect);

Enum_unload_types.prototype.multyLangValues = {"ru_pump":"насос"
,"ru_band":"лента"
,"ru_none":"нет"
};


