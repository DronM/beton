/** Copyright (c) 2020 
 *	Andrey Mikhalevich, Katren ltd.
 */
function RawMaterial_Form(options){
	options = options || {};	
	
	options.formName = "RawMaterialDialog";
	options.controller = "RawMaterial_Controller";
	options.method = "get_object";
	
	RawMaterial_Form.superclass.constructor.call(this,options);
	
}
extend(RawMaterial_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

