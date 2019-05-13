/** Copyright (c) 2019 
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleOwnerEdit(id,options){

	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Владелец:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = VehicleOwnerList_Form;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	
	//форма редактирования элемента
	options.editWinClass = null;
	
	options.acMinLengthForQuery = 1;
	options.acController = new VehicleOwner_Controller();
	options.acModel = new VehicleOwner_Model();
	options.acPatternFieldId = options.acPatternFieldId || "name";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	VehicleOwnerEdit.superclass.constructor.call(this,id,options);
}
extend(VehicleOwnerEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

