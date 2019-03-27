/** Copyright (c) 2019
	Andrey Mikhalevich, Katren ltd.
 */
function TrackerEdit(id,options){
	options = options || {};

	if (options.labelCaption==undefined){
		options.labelCaption = "Трэкер:";
	}
	options.maxLength = 15;
		
	TrackerEdit.superclass.constructor.call(this,id,options);
	
}
extend(TrackerEdit,EditString);

