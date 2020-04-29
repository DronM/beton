/* Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function ShipmentList_Form(options){
	options = options || {};	
	
	options.formName = "ShipmentList";
	options.controller = "Shipment_Controller";
	options.method = "get_list";
	
	ShipmentList_Form.superclass.constructor.call(this,options);
		
}
extend(ShipmentList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

