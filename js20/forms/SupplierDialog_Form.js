/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function SupplierDialog_Form(options){
	options = options || {};	
	
	options.formName = "SupplierDialog";
	options.controller = "Supplier_Controller";
	options.method = "get_object";
	
	SupplierDialog_Form.superclass.constructor.call(this,options);
	
}
extend(SupplierDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

