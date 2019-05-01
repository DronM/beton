/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ShipmentDialog_Form(options){
	options = options || {};	
	
	options.formName = "ShipmentDialog";
	options.controller = "Shipment_Controller";
	options.method = "get_object";
	
	ShipmentDialog_Form.superclass.constructor.call(this,options);
	
}
extend(ShipmentDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

