/** Copyright (c) 2019 
 *	Andrey Mikhalevich, Katren ltd.
 */
function SMSPatternDialog_Form(options){
	options = options || {};	
	
	options.formName = "SMSPatternDialog";
	options.controller = "SMSPattern_Controller";
	options.method = "get_object";
	
	SMSPatternDialog_Form.superclass.constructor.call(this,options);
	
}
extend(SMSPatternDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

