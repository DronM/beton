/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
 */
function OrderDescrEdit(id,options){
	options = options || {};

	if (options.labelCaption==undefined){
		options.labelCaption = "Прораб:";
	}
	options.maxLength = 50;
	
	options.cmdAutoComplete	= true;
	options.acMinLengthForQuery = 1;
	options.acController = new Order_Controller();
	options.acModel = new OrderDescr_Model();
	options.acPublicMethod = options.acController.getPublicMethod("complete_descr")
	options.acPatternFieldId = options.acPatternFieldId || "descr";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("descr")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("descr")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
		
	OrderDescrEdit.superclass.constructor.call(this,id,options);
	
}
extend(OrderDescrEdit,EditString);

