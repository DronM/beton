/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
 */
function FeatureEdit(id,options){
	options = options || {};

	if (options.labelCaption==undefined){
		options.labelCaption = "Свойство:";
	}
	options.maxLength = 50;
	
	options.cmdAutoComplete	= true;
	options.acMinLengthForQuery = 1;
	options.acController = new Vehicle_Controller();
	options.acModel = new VehicleFeatureList_Model();
	options.acPublicMethod = options.acController.getPublicMethod("complete_features")
	options.acPatternFieldId = options.acPatternFieldId || "feature";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("feature")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("feature")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
		
	FeatureEdit.superclass.constructor.call(this,id,options);
	
}
extend(FeatureEdit,EditString);

