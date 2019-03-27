/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function DestinationList_Form(options){
	options = options || {};	
	
	options.formName = "DestinationList";
	options.controller = "Destination_Controller";
	options.method = "get_list";
	
	DestinationList_Form.superclass.constructor.call(this,options);
		
}
extend(DestinationList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

