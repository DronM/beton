/** Copyright (c) 2019 
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleEdit(id,options){

	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Автомобиль:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = VehicleList_Form;
	options.selectDescrIds = options.selectDescrIds || ["plate"];
	
	//форма редактирования элемента
	options.editWinClass = Vehicle_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new Vehicle_Controller();
	options.acModel = new Vehicle_Model();
	options.acPatternFieldId = options.acPatternFieldId || "plate";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("plate")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	VehicleEdit.superclass.constructor.call(this,id,options);
}
extend(VehicleEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

