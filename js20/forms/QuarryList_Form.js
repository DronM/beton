/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function QuarryList_Form(options){
	options = options || {};	
	
	options.formName = "QuarryList";
	options.controller = "Quarry_Controller";
	options.method = "get_list";
	
	QuarryList_Form.superclass.constructor.call(this,options);
		
}
extend(QuarryList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

