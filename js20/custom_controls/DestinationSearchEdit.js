/** Copyright (c) 2020
	Andrey Mikhalevich, Katren ltd.
 */
function DestinationSearchEdit(id,options){
	options = options || {};
	options.cmdAutoComplete = true;
	if (options.labelCaption==undefined){
		options.labelCaption = "Объект:";
	}
	options.maxLength = 250;
		
	options.acMinLengthForQuery = 1;
	options.acController = new Destination_Controller();
	options.acPublicMethod = options.acController.getPublicMethod("complete_for_order");
	options.acModel = new DestinationForOrderList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "name_pat";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
		
	DestinationSearchEdit.superclass.constructor.call(this,id,options);
	
}
extend(DestinationSearchEdit,EditString);

