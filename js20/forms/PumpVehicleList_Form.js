/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function PumpVehicleList_Form(options){
	options = options || {};	
	
	options.formName = "PumpVehicleList";
	options.controller = "PumpVehicle_Controller";
	options.method = "get_list";
	
	PumpVehicleList_Form.superclass.constructor.call(this,options);
		
}
extend(PumpVehicleList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

