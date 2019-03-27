/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleScheduleMakeOrderList_Form(options){
	options = options || {};	
	
	options.formName = "VehicleScheduleMakeOrderList";
	options.controller = "VehicleSchedule_Controller";
	options.method = "get_current_veh_list";
	
	VehicleScheduleMakeOrderList_Form.superclass.constructor.call(this,options);
		
}
extend(VehicleScheduleMakeOrderList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

