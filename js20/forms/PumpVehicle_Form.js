/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function PumpVehicle_Form(options){
	options = options || {};	
	
	options.formName = "PumpVehicleDialog";
	options.controller = "PumpVehicle_Controller";
	options.method = "get_object";
	
	PumpVehicle_Form.superclass.constructor.call(this,options);
	
}
extend(PumpVehicle_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

