/** Copyright (c) 2019 
 *	Andrey Mikhalevich, Katren ltd.
 */
function VehicleScheduleEdit(id,options){

	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Экипаж:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = VehicleScheduleMakeOrderList_Form;
	options.selectDescrIds = options.selectDescrIds || ["vehicle_schedules_ref"];
	
	//форма редактирования элемента
	options.editWinClass = Vehicle_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new VehicleSchedule_Controller();
	options.acModel = new VehicleScheduleComplete_Model();
	options.acPatternFieldId = options.acPatternFieldId || "vehicle_schedule_descr";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("vehicle_schedule_descr")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	VehicleScheduleEdit.superclass.constructor.call(this,id,options);
}
extend(VehicleScheduleEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

