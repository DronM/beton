/** Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function ClientDialog_Form(options){
	options = options || {};	
	
	options.formName = "ClientDialog";
	options.controller = "Client_Controller";
	options.method = "get_object";
	
	ClientDialog_Form.superclass.constructor.call(this,options);
	
}
extend(ClientDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

