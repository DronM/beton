/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
 */
function OwnerEdit(id,options){
	options = options || {};

	if (options.labelCaption==undefined){
		options.labelCaption = "Владелец:";
	}
	options.maxLength = 50;
	
	options.cmdAutoComplete	= true;	
	options.acMinLengthForQuery = 1;
	options.acController = new Vehicle_Controller();
	options.acModel = new VehicleOwnerList_Model();
	options.acPublicMethod = options.acController.getPublicMethod("complete_owners")
	options.acPatternFieldId = options.acPatternFieldId || "owner";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("owner")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("owner")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
		
	OwnerEdit.superclass.constructor.call(this,id,options);
	
}
extend(OwnerEdit,EditString);

