/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleDialog_Form(options){
	options = options || {};	
	
	options.formName = "VehicleDialog";
	options.controller = "Vehicle_Controller";
	options.method = "get_object";
	
	VehicleDialog_Form.superclass.constructor.call(this,options);
	
}
extend(VehicleDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

