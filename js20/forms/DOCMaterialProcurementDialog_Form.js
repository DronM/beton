/** Copyright (c) 2021
 *	Andrey Mikhalevich, Katren ltd.
 */
function DOCMaterialProcurementDialog_Form(options){
	options = options || {};	
	
	options.formName = "DOCMaterialProcurementDialog";
	options.controller = "DOCMaterialProcurement_Controller";
	options.method = "get_object";
	
	DOCMaterialProcurementDialog_Form.superclass.constructor.call(this,options);
	
}
extend(DOCMaterialProcurementDialog_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

