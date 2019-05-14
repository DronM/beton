/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderList_Form(options){
	options = options || {};	
	
	options.formName = "OrderList";
	options.controller = "Order_Controller";
	options.method = "get_list";
	
	OrderList_Form.superclass.constructor.call(this,options);
		
}
extend(OrderList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

