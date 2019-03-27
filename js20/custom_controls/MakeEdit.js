/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
 */
function MakeEdit(id,options){
	options = options || {};

	if (options.labelCaption==undefined){
		options.labelCaption = "Марка:";
	}
	options.maxLength = 20;
	
	options.cmdAutoComplete	= true;	
	options.acMinLengthForQuery = 1;
	options.acController = new Vehicle_Controller();
	options.acModel = new VehicleMakeList_Model();
	options.acPublicMethod = options.acController.getPublicMethod("complete_makes")
	options.acPatternFieldId = options.acPatternFieldId || "make";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("make")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("make")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
		
	MakeEdit.superclass.constructor.call(this,id,options);
	
}
extend(MakeEdit,EditString);

