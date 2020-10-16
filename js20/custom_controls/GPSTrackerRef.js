/** Copyright (c) 2020
	Andrey Mikhalevich, Katren ltd.
 */
function GPSTrackerRef(id,options){
	options = options || {};

	if (options.labelCaption==undefined){
		options.labelCaption = "GPS трэкер:";
	}
	options.maxLength = 50;
	
	options.cmdAutoComplete	= true;
	options.acMinLengthForQuery = 1;
	options.acController = new GPSTracker_Controller();
	options.acModel = new GPSTracker_Model();
	options.acPublicMethod = options.acController.getPublicMethod("complete")
	options.acPatternFieldId = options.acPatternFieldId || "id";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("id")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
		
	GPSTrackerRef.superclass.constructor.call(this,id,options);
	
}
extend(GPSTrackerRef,EditString);

