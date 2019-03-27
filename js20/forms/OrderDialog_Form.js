/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderDialog_Form(options){
	options = options || {};	
	
	options.formName = "OrderDialog";
	options.controller = "Order_Controller";
	options.method = "get_object";
	
	OrderDialog_Form.superclass.constructor.call(this,options);
	
}
extend(OrderDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

