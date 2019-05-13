/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleOwnerList_Form(options){
	options = options || {};	
	
	options.formName = "VehicleOwnerList";
	options.controller = "VehicleOwner_Controller";
	options.method = "get_list";
	
	VehicleOwnerList_Form.superclass.constructor.call(this,options);
		
}
extend(VehicleOwnerList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

