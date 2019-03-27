/** Copyright (c) 2019 
 *	Andrey Mikhalevich, Katren ltd.
 */
function DestinationEdit(id,options){

	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Объект:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = DestinationList_Form;
	options.selectDescrIds = options.selectDescrIds || ["name"];
	
	//форма редактирования элемента
	options.editWinClass = Destination_Form;
	
	options.acMinLengthForQuery = (options.acMinLengthForQuery!=undefined)? options.acMinLengthForQuery:1;
	options.acController = new Destination_Controller();
	options.acPublicMethod = options.acController.getPublicMethod("complete_dest");
	options.acModel = new DestinationList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "name_pat";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	options.acDescrFields = options.acDescrFields || [options.acModel.getField("name")];
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	DestinationEdit.superclass.constructor.call(this,id,options);
}
extend(DestinationEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

