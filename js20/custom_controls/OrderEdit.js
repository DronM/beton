/* Copyright (c) 2019
 *	Andrey Mikhalevich, Katren ltd.
 */
function OrderEdit(id,options){
	options = options || {};	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Заявка:";
	}
	options.cmdInsert = (options.cmdInsert!=undefined)? options.cmdInsert:false;
	
	options.keyIds = options.keyIds || ["id"];
	
	//форма выбора из списка
	options.selectWinClass = OrderList_Form;
	options.selectDescrIds = options.selectDescrIds || ["number"];
	
	//форма редактирования элемента
	options.editWinClass = null;
	
	options.acMinLengthForQuery = 1;
	options.acController = new Order_Controller();
	options.acModel = new OrderList_Model();
	options.acPatternFieldId = options.acPatternFieldId || "number";
	options.acKeyFields = options.acKeyFields || [options.acModel.getField("id")];
	//options.acDescrFields = options.acDescrFields || [options.acModel.getField("number"),options.acModel.getField("date_time")];
	options.acDescrFunction = function(fields){
		return fields.number.getValue()+" от "+DateHelper.format(fields.date_time.getValue(),"d/m/y H:i")+" ("+fields.clients_ref.getValue().getDescr()+")";
	}
	options.acICase = options.acICase || "1";
	options.acMid = options.acMid || "1";
	
	OrderEdit.superclass.constructor.call(this,id,options);
}
extend(OrderEdit,EditRef);

/* Constants */


/* private members */

/* protected*/


/* public methods */

