/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function VehicleSelect(id,options){
	options = options || {};
	
	options.model = options.addAll?
		new ModelXML("vehicles_with_trackers",
			{"fields":{
				"id":new FieldInt("id")
				,"plate":new FieldString("plate")
				,"tracker_id":new FieldString("tracker_id")
			}})
			: new Vehicle_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "ТС:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("plate")];
	
	var contr = new Vehicle_Controller();
	options.readPublicMethod = contr.getPublicMethod(options.addAll? "vehicles_with_trackers": "get_list");
	
	VehicleSelect.superclass.constructor.call(this,id,options);
	
}
extend(VehicleSelect,EditSelectRef);

