/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleScheduleList_Form(options){
	options = options || {};	
	
	options.formName = "VehicleScheduleList";
	options.controller = "VehicleSchedule_Controller";
	options.method = "get_list";
	
	VehicleScheduleList_Form.superclass.constructor.call(this,options);
		
}
extend(VehicleScheduleList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

