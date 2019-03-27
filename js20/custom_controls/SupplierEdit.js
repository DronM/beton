/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function SupplierEdit(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Поставщик:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = SupplierList_Form;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	
	//форма редактирования элемента
	options.editWinClass = SupplierDialog_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new Supplier_Controller();
	options.acModel = new SupplierList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "name";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	SupplierEdit.superclass.constructor.call(this,id,options);
}
extend(SupplierEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

