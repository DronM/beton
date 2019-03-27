/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
 
function PlantLoadGraphControl(id,options){	
	PlantLoadGraphControl.superclass.constructor.call(this,id,"IMG",options);
	
	this.setModel(options.model);
}
extend(PlantLoadGraphControl,Control);

PlantLoadGraphControl.prototype.setModel = function(model){
	if (model.getNextRow()){
		this.setAttr("src","data:image/png;base64,"+model.getFieldValue("pic"));
	}
}

PlantLoadGraphControl.prototype.clearGraph = function(){
	this.setAttr("src","");
}
