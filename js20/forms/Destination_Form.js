/** Copyright (c) 2019 
 *	Andrey Mikhalevich, Katren ltd.
 */
function Destination_Form(options){
	options = options || {};	
	
	options.formName = "DestinationDialog";
	options.controller = "Destination_Controller";
	options.method = "get_object";
	
	Destination_Form.superclass.constructor.call(this,options);
	
}
extend(Destination_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

