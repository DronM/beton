/**
 * @author Andrey Mikhalevich <katrenplus@mail.ru>, 2019
 
 * @class
 * @classdesc
	
 * @param {string} id view identifier
 * @param {namespace} options
 */	
function ClientTypeEdit(id,options){
	options = options || {};
	options.model = new ClientType_Model();
	
	if (options.labelCaption!=""){
		options.labelCaption = options.labelCaption || "Вид клиента:";
	}
	
	options.keyIds = options.keyIds || ["id"];
	options.modelKeyFields = [options.model.getField("id")];
	options.modelDescrFields = [options.model.getField("name")];
	
	var contr = new ClientType_Controller();
	options.readPublicMethod = contr.getPublicMethod("get_list");
	
	ClientTypeEdit.superclass.constructor.call(this,id,options);
	
}
extend(ClientTypeEdit,EditSelectRef);

