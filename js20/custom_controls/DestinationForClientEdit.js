/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2020
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function DestinationForClientEdit(id,options){
	options = options || {};
	options.model = new DestinationList_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Объект:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new Destination_Controller();
	
	options.readPublicMethod = contr.getPublicMethod("get_for_client_list");
	
	DestinationForClientEdit.superclass.constructor.call(this,id,options);
	
}
extend(DestinationForClientEdit,EditSelectRef);

