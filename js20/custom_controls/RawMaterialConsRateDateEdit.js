/** Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function RawMaterialConsRateDateEdit(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Подбор:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["rate_date_id"];
	
	//форма выбора из списка
	options.selectWinClass = RawMaterialConsRateDateList_Form;
	options.selectDescrIds = options.selectDescrIds || ["code","period"];
	
	//форма редактирования элемента
	options.editWinClass = null;
	
	options.acMinLengthForQuery = 1;
	options.acController = new RawMaterialConsRateDate_Controller();
	options.acModel = new RawMaterialConsRateDateList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "code";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("code"),options.acModel.getField("period")];
	options.acICase = options.acICase || "0";
	options.acMid = options.acMid || "0";
	
	RawMaterialConsRateDateEdit.superclass.constructor.call(this,id,options);
}
extend(RawMaterialConsRateDateEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

