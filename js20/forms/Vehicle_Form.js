/** Copyright (c) 2019 
 *	Andrey Mikhalevich, Katren ltd.
 */
function Vehicle_Form(options){
	options = options || {};	
	
	options.formName = "VehicleDialog";
	options.controller = "Vehicle_Controller";
	options.method = "get_object";
	
	Vehicle_Form.superclass.constructor.call(this,options);
	
}
extend(Vehicle_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

