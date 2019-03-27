/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleList_Form(options){
	options = options || {};	
	
	options.formName = "VehicleList";
	options.controller = "Vehicle_Controller";
	options.method = "get_list";
	
	VehicleList_Form.superclass.constructor.call(this,options);
		
}
extend(VehicleList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

