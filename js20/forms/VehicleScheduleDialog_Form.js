/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleScheduleDialog_Form(options){
	options = options || {};	
	
	options.formName = "VehicleScheduleDialog";
	options.controller = "VehicleSchedule_Controller";
	options.method = "get_object";
	
	VehicleScheduleDialog_Form.superclass.constructor.call(this,options);
	
}
extend(VehicleScheduleDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

