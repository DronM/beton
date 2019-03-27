/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function SupplierList_Form(options){
	options = options || {};	
	
	options.formName = "SupplierList";
	options.controller = "Supplier_Controller";
	options.method = "get_list";
	
	SupplierList_Form.superclass.constructor.call(this,options);
		
}
extend(SupplierList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

