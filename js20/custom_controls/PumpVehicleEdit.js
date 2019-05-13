/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2016
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function PumpVehicleEdit(id,options){
	options = options || {};
	options.model = new PumpVehicleWorkList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Насос:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	//options.modelDescrFields = [options.model.getField("plate"),options.model.getField("make"),options.model.getField("pump_length")];
	options.modelDescrFormatFunction = function(f){
		var res = f.plate.getValue();
		//make
		var mk = f.make.getValue();
		res+= (mk&&mk.length)? " "+mk:"";
		//owner
		var owner = f.vehicle_owners_ref.getValue();
		res+= (owner&&!owner.isNull())? " "+owner.getDescr():"";
		//length
		var l = f.pump_length.getValue();
		res+= l? " ("+l+"м.)":"";
		return res;
	}
	
	options.readPublicMethod = (new PumpVehicle_Controller()).getPublicMethod("get_work_list");
	
	PumpVehicleEdit.superclass.constructor.call(this,id,options);
	
}
extend(PumpVehicleEdit,EditSelectRef);

