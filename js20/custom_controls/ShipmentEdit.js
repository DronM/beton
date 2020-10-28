/* Copyright (c) 2020
 *	Andrey Mikhalevich, Katren ltd.
 */
function ShipmentEdit(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Отгрузка:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = ShipmentList_Form;
	options.selectDescrIds = options.selectDescrIds || ["id"];
	
	//форма редактирования элемента
	options.editWinClass = ShipmentDialog_Form;
	
	options.acMinLengthForQuery = 1;
	options.acController = new Shipment_Controller();
	options.acModel = new ShipmentList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "id";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	//options.acDescrFields = options.acDescrFields || [options.acModel.getField("number"),options.acModel.getField("ship_date_time")];
	options.acDescrFunction = function(fields){
		return fields.id.getValue()+" от "+DateHelper.format(fields.ship_date_time.getValue(),"d/m/y H:i")+" ("+fields.clients_ref.getValue().getDescr()+")";
	}
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	ShipmentEdit.superclass.constructor.call(this,id,options);
}
extend(ShipmentEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

