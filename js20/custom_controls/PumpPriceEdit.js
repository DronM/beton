/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function PumpPriceEdit(id,options){
	options = options || {};
	options.model = new PumpPrice_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Ценовая схема насоса:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new PumpPrice_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	PumpPriceEdit.superclass.constructor.call(this,id,options);
	
}
extend(PumpPriceEdit,EditSelectRef);

