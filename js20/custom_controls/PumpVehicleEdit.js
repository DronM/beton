/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function PumpVehicleEdit(id,options){
	options = options || {};
	options.model = new PumpVehicleList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Насос:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("plate"),options.model.getField("make"),options.model.getField("owner")];
	
	var contr = new PumpVehicle_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	PumpVehicleEdit.superclass.constructor.call(this,id,options);
	
}
extend(PumpVehicleEdit,EditSelectRef);

