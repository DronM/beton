/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function RawMaterialConsRateDateList_Form(options){
	options = options || {};	
	
	options.formName = "RawMaterialConsRateDateList";
	options.controller = "RawMaterialConsRateDate_Controller";
	options.method = "get_list";
	
	RawMaterialConsRateDateList_Form.superclass.constructor.call(this,options);
		
}
extend(RawMaterialConsRateDateList_Form,WindowFormObject);

/* Constants */


/* private members */

/* protected*/


/* public methods */

