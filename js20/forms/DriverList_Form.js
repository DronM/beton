/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function DriverList_Form(options){
	options = options || {};	
	
	options.formName = "DriverList";
	options.controller = "Driver_Controller";
	options.method = "get_list";
	
	DriverList_Form.superclass.constructor.call(this,options);
		
}
extend(DriverList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

